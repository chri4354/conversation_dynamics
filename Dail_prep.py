#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 22 12:47:11 2018

@author: yuki
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

df = pd.read_csv('Dail_debates_data/Dail_debates_1919-2013.tab', sep='\t')

""" # columns
[u'speechID', u'memberID', u'partyID', u'constID', u'title', u'date',
       u'member_name', u'party_name', u'const_name', u'speech']
"""
titles = np.unique(df.title)
parties = np.unique(df.partyID)
keywords = ['abortion', "abortions",'pregnancy', 'pregnancies', 'baby', 'babies']
df.partyID = df.partyID.astype('str')
df.date = df.date.astype(pd.datetime)

#%%
binary = df.speech==0
for kw in keywords:
    binary += df.speech.apply(lambda x: kw in x)

selected = df[binary]
selected = selected.set_index(pd.DatetimeIndex(selected['date']))
selected.to_pickle('Dail_debates_data/selected.pkl')
#%% SOME EXPLORATORY ANALYSIS ##############################################################################
ax = selected.groupby('partyID').count().speech.plot.bar()
ax.set_ylabel('number of relevant speeches')
#%%
ax = selected.groupby(pd.Grouper(freq='6M')).count().speech.plot()
ax.set_ylabel('number of relevant speeches')
#%%
for p in np.unique(selected.partyID):
    ax = selected[selected['partyID']==p].groupby(pd.Grouper(freq='6M')).count().speech.plot(label=p)
ax.set_ylabel('number of relevant speeches')
ax.legend()

