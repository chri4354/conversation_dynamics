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
from pprint import pprint  # pretty-printer

# remove urls
texts = [re.sub(r"http\S+", "", doc) for doc in texts]
texts = [' '.join(item for item in doc.split() if not (item.startswith('www.')))  for doc in texts]
# strip trailing symbols
texts = [doc.replace('\n','') for doc in texts]
# remove double quotes
texts = [doc.replace('—',' ').replace('–',' ') for doc in texts]
# remove numbers
texts = [re.sub(r'\d+', '', doc) for doc in texts]
    
# remove punctuation and stopwords
stop = set(stopwords.words('english'))
exclude = set(string.punctuation) | set('“”"’')
lemma = WordNetLemmatizer()
def clean(doc):
    stop_free = " ".join([i for i in doc.lower().split() if i not in stop])
    punc_free = ''.join(ch for ch in stop_free if ch not in exclude)
    normalized = " ".join(lemma.lemmatize(word) for word in punc_free.split())
    return normalized

# tokenize docs
texts_clean = [clean(doc).split() for doc in texts]  

# remove non english words
words = set(nltk.corpus.words.words())
for i,doc in enumerate(texts_clean):
    texts_clean[i] = [w for w in doc if w in words or not w.isalpha()]

# this is useless...
texts_corpus = list(itertools.chain.from_iterable(texts_clean))

#%% 
# Importing Gensim
from gensim import corpora, models, similarities

#Creating the term dictionary of our courpus, where every unique term 
#is assigned an index. 
dictionary_against = corpora.Dictionary(texts_clean[0:10]) 
dictionary_pro = corpora.Dictionary(texts_clean[11:-1]) 
# Converting list of documents (corpus) into Document Term Matrix using 
# dictionary prepared above.
corpus_against = [dictionary.doc2bow(doc) for doc in texts_clean[0:10]]
corpus_pro = [dictionary.doc2bow(doc) for doc in texts_clean[11:-1]]

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
- automate reddit scraping
"""