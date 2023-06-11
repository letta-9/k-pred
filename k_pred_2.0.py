import requests
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import re

def get_lineups():
    url = "https://www.baseball-reference.com/teams/BOS/2023-batting-orders.shtml"
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    table = soup.find_all('table')
    table = table[0]

    # # Get lineup df
    b_rows = table.find_all('tr')
    lineups = pd.DataFrame([[str(x.string) for x in row.find_all('a')] for row in b_rows])

    # # Get pitcher df
    p_rows = []
    header_row = []

    for th in table.find_all('th'):
        header_row.append(th.text.strip())

    p_rows.append(header_row)
    pitchers = pd.DataFrame(p_rows[0])

    # Clean lineup df
    lineups = lineups.drop(0, axis=1)
    lineups = lineups.drop(0, axis=0)
    lineups = lineups.rename(columns={1:'Date', 2:'Opp',
                                    3:'One', 4:'Two',
                                    5:'Three', 6:'Four',
                                    7:'Five', 8:'Six',
                                    9:'Seven', 10:'Eight', 11:'Nine'})

    lineups = lineups.astype(str)
    lineups = lineups.reset_index()

    # Clean pitcher df
    pitchers = pitchers[10:].reset_index(drop=True)
    pitchers = pitchers.rename(columns={pitchers.columns[0]: 'Pit'})
    pitchers.Pit = pitchers.Pit.apply(lambda x: 'LHP' if '#' in x else 'RHP')


    # Combine and clean
    lineups['Pit'] = pitchers
    lineups = lineups.loc[:,['Date','Opp','Pit','One','Two','Three','Four','Five','Six','Seven','Eight','Nine']]
    lineups = lineups.replace(to_replace='None', value=np.nan)
    lineups = lineups[lineups['Date'].notna()]
    vRHP = lineups[lineups['Pit'] == 'RHP']
    vRHP = vRHP.iloc[vRHP.shape[0]-1]
    vLHP = lineups[lineups['Pit'] == 'LHP']
    vLHP = vLHP.iloc[vLHP.shape[0]-1]
    lineups = pd.concat([vRHP, vLHP], axis=1)
    lineups = lineups.transpose().reset_index(drop=True)
    lineups = lineups.iloc[:,2:12].set_index('Pit')
    return lineups


def get_pit():
    url = "https://www.baseball-reference.com/previews/index.shtml"
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    table = soup.find_all('table')

    probables = pd.DataFrame()
    teams = pd.DataFrame()

    for x in range(0,len(table)):
        if (x % 2) == 0:
            tbl = table[x]
            rows = tbl.find_all('tr')
            pit = pd.DataFrame([[str(x.string) for x in row.find_all('a')] for row in rows])
            teams = pd.concat([teams, pit])
        else:
            tbl = table[x]
            rows = tbl.find_all('tr')
            pit = pd.DataFrame([[str(x.string) for x in row.find_all('a')] for row in rows])
            probables = pd.concat([probables, pit])

    probables[['Team','Junk']] = teams
    probables = probables.rename(columns={probables.columns[0]: 'Pit'}).reset_index(drop=True)
    probables = probables.iloc[:,0:2]

    return probables




lineups = get_lineups()
print(lineups.head())

probables = get_pit()
print(probables.head())