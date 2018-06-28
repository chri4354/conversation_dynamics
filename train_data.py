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
from gensim import corpora, models

#%% load data 
"""
This data was collected on 15th June 2018. They represent the first 10 websites 
suggested by Google from the query "pro life arguments" and "pro choice 
arguments", plus an 11th entry for the each argument as summarized by Wikipedia.
Websites were filtered based on their content: e.g. some pro life arguments 
came after querying for pro choice. Or e.g. some websites had both arguments 
summarized."""
texts=[]
for w in range(10):
    texts.append(open('./data_files/abortion/against/web' + str(w+1) + '.txt', 'r').read())
for w in range(10):
    texts.append(open('./data_files/abortion/pro/web' + str(w+1) + '.txt', 'r').read())
    
#%% clean doc
from nltk.corpus import stopwords
from nltk.stem.wordnet import WordNetLemmatizer
import string
import re

def clean_data(texts):
    # remove punctuation and stopwords
    stop = set(stopwords.words('english')) | set(['would','could', 'it', 'thats'])
    exclude = set(string.punctuation) | set('“”"’')
    lemma = WordNetLemmatizer()
    # english words
    words = set(nltk.corpus.words.words())

    texts_clean = []
    tokens = []
    for i,doc in enumerate(texts):
#        break
        # remove urls
        doc = re.sub(r"http\S+", "", doc) 
        doc = ' '.join(item for item in doc.split() if not (item.startswith('www.')))
        # strip trailing symbols
        doc = doc.replace('\n','')
        # remove double hyphens
        doc = doc.replace('—',' ').replace('–',' ')
        # remove numbers
        doc = re.sub(r'\d+', '', doc)
        # remove punctuation
        doc = " ".join([i for i in doc.lower().split() if i not in stop])
        doc = ''.join(ch for ch in doc if ch not in exclude)
        doc = " ".join(lemma.lemmatize(word) for word in doc.split())
        # clean text
        texts_clean.append(doc)
        # tokenize docs
        tokens.append(doc.split())
        tokens[i] = [w for w in tokens[i] if w in words or not w.isalpha()]
    
    return texts_clean, tokens
    
#%% 
texts_clean, tokens = clean_data(texts)

#Creating the term dictionary of our courpus, where every unique term 
#is assigned an index. 
dictionary_against = corpora.Dictionary(tokens[0:10]) 
dictionary_pro = corpora.Dictionary(tokens[11:-1]) 
# Converting list of documents (corpus) into Document Term Matrix using 
# dictionary prepared above.
dictionary = dictionary_against
corpus_against = [dictionary.doc2bow(doc) for doc in tokens[0:10]]
corpus_pro = [dictionary.doc2bow(doc) for doc in tokens[11:-1]]

# topic modelling
corpus = corpus_against # switch this to pro depending on what opinion you want to model
dictionary = dictionary_against # switch this to pro depending on what opinion you want to model
# initialize a model
tfidf = models.TfidfModel(corpus) 
corpus_tfidf = tfidf[corpus]
#for doc in corpus_tfidf:
#    print(doc)

# initialize an LSI transformation
lsi = models.LsiModel(corpus_tfidf, id2word=dictionary, num_topics=1)
# create a double wrapper over the original corpus: bow->tfidf->fold-in-lsi
corpus_lsi = lsi[corpus_tfidf]
lsi.print_topics(1)

#%% TO DO
"""
- kl divergence (or other similarity measure) between against and pro corpora
"""