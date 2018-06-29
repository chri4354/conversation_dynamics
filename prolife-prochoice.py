# -*- coding: utf-8 -*-

#------ Processing the labels of the raw abortion data --------+
import os

from sentence_varying import vary_sentence

import numpy as np
np.random.seed(10000)


abortion_dir = 'data_files/abortion'
train_dir = os.path.join(abortion_dir, 'train2')

labels = []
texts = []

for label_type in ['pro', 'against']:
    dir_name = os.path.join(train_dir, label_type)
    for fname in os.listdir(dir_name):
        if fname[-4:] == '.txt':
            f = open(os.path.join(dir_name, fname), encoding="utf-8")
            for line in f:
                texts.append(line)
                if label_type == 'against':
                    labels.append(0)
                else:
                    labels.append(1)
            f.close()
                
print("length of the texts ", len(texts))
print("length of the labels ", len(labels))

for i in range(len(texts)):
    varied_sentence1 = vary_sentence(texts[i])
    varied_sentence2 = vary_sentence(texts[i])
    
    texts.append(varied_sentence1)
    labels.append(labels[i])
    
    texts.append(varied_sentence2)
    labels.append(labels[i])
    
    
print("length of the texts ", len(texts))
print("length of the labels ", len(labels))


#------------ TOKENIZING THE DATA -----------_+
"""Tokenizing the text of the raw IMDB data
"""
from keras.preprocessing.text import Tokenizer
from keras.preprocessing.sequence import pad_sequences

from keras.models import Sequential
from keras.layers import Embedding, SimpleRNN, Dense



# cuts off reviews after 100 words
maxlen = 500

# trains on 10000 samples
training_samples = len(texts)

# validates on 10000 samples
#validation_samples = 10183

# considers only the top 20000 words in the dataset
max_words = 20000


tokenizer = Tokenizer()#(num_words=max_words)
tokenizer.fit_on_texts(texts)
sequences = tokenizer.texts_to_sequences(texts)

labels = np.asarray(labels)

word_index = tokenizer.word_index
print('Found %s unique tokens.' % len(word_index))

data = pad_sequences(sequences, maxlen=maxlen)

labels = np.asarray(labels)
print('Shape of data tensor:', data.shape)
print('Shape of label tensor:', labels.shape)

# Split the data into a training set and a validation set
# But first, shuffle the data, since we started from data
# where sample are ordered (all negative first, then all positive).
indices = np.arange(data.shape[0])
#print(indices)
np.random.shuffle(indices)
#print(indices)
data = data[indices]
labels = labels[indices]

x_train = data[:training_samples]
y_train = labels[:training_samples]
#x_val = data[training_samples: training_samples + validation_samples]
#y_val = labels[training_samples: training_samples + validation_samples]
#x_val = data[:training_samples]
#y_val = labels[:training_samples]

from keras.layers import LSTM

model = Sequential()
model.add(Embedding(len(texts), 32))
model.add(LSTM(32))
#model.add(LSTM(32))
model.add(Dense(1, activation='sigmoid'))

model.compile(optimizer='rmsprop',
              loss='binary_crossentropy',
              metrics=['acc'])
history = model.fit(x_train, y_train,
                    epochs=10,
                    batch_size=128,
                    validation_split=0.2)



import matplotlib.pyplot as plt

acc = history.history['acc']
val_acc = history.history['val_acc']
loss = history.history['loss']
val_loss = history.history['val_loss']

epochs = range(len(acc))

plt.plot(epochs, acc, 'bo', label='Training acc')
plt.plot(epochs, val_acc, 'b', label='Validation acc')
plt.title('Training and validation accuracy')
plt.legend()

plt.figure()

plt.plot(epochs, loss, 'bo', label='Training loss')
plt.plot(epochs, val_loss, 'b', label='Validation loss')
plt.title('Training and validation loss')
plt.legend()

plt.show()