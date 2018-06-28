#------------------------------------------------------------------------------+
#
#
#   Varying a sentence by synonyms
#   2018-June.
#   Contributors:
#   1. Nam Le -- University College Dublin
#   2. 
#   3. 
#
#------------------------------------------------------------------------------+



import nltk
from nltk.corpus import wordnet as wn

concerns = {'NN': wn.NOUN,'JJ':wn.ADJ,'VB':wn.VERB,'RB':wn.ADV}


import numpy as np

def synonimize(word, pos=None):
    """ Get synonyms of the word / lemma """ 
    try:
        # map part of speech tags to wordnet
#        pos = {'NN': wn.NOUN,'JJ':wn.ADJ,'VB':wn.VERB,'RB':wn.ADV}[pos[:2]]
        pos = {'NN': wn.NOUN,'JJ':wn.ADJ}[pos[:2]]
    except:
        # or just return the original word
#        print(word)
        return [word]
    
    
    synsets = wn.synsets(word)#, pos)
    synonyms = []
    for synset in synsets:
        names = synset.lemma_names()
        for sim in  names:
            synonyms.append(sim)
    
    # return list of synonyms or just the original word
    return synonyms or [word]

def vary_sentence(sentence):
    """ Create variations of a sentence using synonyms """
    words = nltk.word_tokenize(sentence)
    pos_tags = nltk.pos_tag(words)

    words = []
    for (word, pos) in pos_tags:
        synonyms = synonimize(word, pos)
        picked = np.random.choice(synonyms)
     
        words.append(picked)

    return " ".join(words)

def vary_by_noun(sentence):
    """ Create variations of a sentence using synonyms """
    words = nltk.word_tokenize(sentence)
    pos_tags = nltk.pos_tag(words)

    words = []
    for (word, pos) in pos_tags:
        if pos[:2] == 'NN':
            synonyms = synonimize(word, pos)
            picked = np.random.choice(synonyms)
            words.append(picked)
        else:
            words.append(word)

    return " ".join(words)

def vary_by_adjective(sentence):
    words = nltk.word_tokenize(sentence)
    pos_tags = nltk.pos_tag(words)

    words = []
    for (word, pos) in pos_tags:
        if pos[:2] == 'JJ':
            synonyms = synonimize(word, pos)
            picked = np.random.choice(synonyms)
            words.append(picked)
        else:
            words.append(word)

    return " ".join(words)

def vary_by_noun_or_adj(sentence, noun_prob=0.5):
    if np.random.random() < noun_prob:
        return vary_by_noun(sentence)
    else:
        return vary_by_adjective(sentence)


if __name__ == "__main__":
    print(vary_by_noun_or_adj("I like every lovely program"))