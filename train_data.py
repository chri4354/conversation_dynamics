# -*- coding: utf-8 -*-
"""
Created on Fri Jun 15 14:47:41 2018

@author: niccolop
"""
import itertools
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import nltk 

#%% load data 
"""
This data was collected on 15th June 2018. They represent the first 10 websites 
suggested by Google from the query "pro life arguments" and "pro choice 
arguments", plus an 11th entry for the each argument as summarized by Wikipedia.
Websites were filtered based on their content: e.g. some pro life arguments 
came after querying for pro choice. Or e.g. some websites had both arguments 
summarized."""
against=[]
pro=[]
for w in range(10):
    against.append(open('./data_files/abortion/against/web' + str(w+1) + '.txt', 'r').read())
    pro.append(open('./data_files/abortion/pro/web' + str(w+1) + '.txt', 'r').read())
    
#%% clean doc
from nltk.corpus import stopwords
from nltk.stem.wordnet import WordNetLemmatizer
import string
import re

# strip trailing symbols
against = [doc.replace('\n','') for doc in against]
pro = [doc.replace('\n','') for doc in pro]
# remove double quotes
against = [doc.replace('“','"').replace('”','"').replace('"','').replace('’',' ').replace('—',' ') for doc in against]
pro = [doc.replace('“','"').replace('”','"').replace('"','').replace('’',' ').replace('—',' ') for doc in pro]
# remove numbers
against = [re.sub(r'\d+', '', doc) for doc in against]
pro = [re.sub(r'\d+', '', doc) for doc in pro]

stop = set(stopwords.words('english'))
exclude = set(string.punctuation)
lemma = WordNetLemmatizer()
def clean(doc):
    stop_free = " ".join([i for i in doc.lower().split() if i not in stop])
    punc_free = ''.join(ch for ch in stop_free if ch not in exclude)
    normalized = " ".join(lemma.lemmatize(word) for word in punc_free.split())
    return normalized

against_clean = [clean(doc).split() for doc in against]  
pro_clean = [clean(doc).split() for doc in pro]  

# remove non english words
words = set(nltk.corpus.words.words())
for i,doc in enumerate(against_clean):
    against_clean[i] = [w for w in doc if w in words or not w.isalpha()]
for i,doc in enumerate(pro_clean):
    pro_clean[i] = [w for w in doc if w in words or not w.isalpha()]

# this is useless...
against_corpus = list(itertools.chain.from_iterable(against_clean))
pro_corpus = list(itertools.chain.from_iterable(pro_clean))

#%% 
# Importing Gensim
from gensim import corpora

#Creating the term dictionary of our courpus, where every unique term 
#is assigned an index. 
dictionary = corpora.Dictionary([[against_corpus],[pro_corpus]]) # THIS IS NOT WORKING
# Converting list of documents (corpus) into Document Term Matrix using 
# dictionary prepared above.
doc_term_matrix = [dictionary.doc2bow(doc) for doc in against_clean]

#%% WORK TO DO HERE
# Holds token ids which appears only once.
unique_ids = [
    token_id for token_id, frequency in dictionary.dfs.items() if frequency == 1
]
freqs = [frequency for token_id, frequency in dictionary.dfs.items()]

# Filters out tokens which appears only once.
dictionary.filter_tokens(unique_ids)

# Compactifies.
dictionary.compactify()

#%% TO DO
"""
- kl divergence (or other similarity measure) between against and pro corpora
- automate reddit scraping
"""