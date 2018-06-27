# -*- coding: utf-8 -*-
"""
Created on Mon Jun 25 12:07:05 2018

@author: niccolop
"""
"""
Requires:
    pyaudio:
        download from here: http://www.portaudio.com/download.html
        Then Extract the downloaded file.
        cd to the extracted folder.
        Then ./configure && make
        Now do sudo make install
        Then upgrade pyaudio by sudo pip3 install pyaudio --upgrade
    speech_recognition:
        follow instructions from https://realpython.com/python-speech-recognition/        
        sudo pip3 install SpeechRecognition

"""

import time
import speech_recognition as sr
import pandas as pd

#%%
r = sr.Recognizer()
mic = sr.Microphone()
mics = sr.Microphone.list_microphone_names() # print list of mics
mic = sr.Microphone(device_index=mics.index('sysdefault'))

with mic as source:    
    print('silence please.') 
    r.adjust_for_ambient_noise(source, )

text = []
stop = False
df = pd.DataFrame()
# start recording until silence is detected
while stop==False:
    with mic as source:
        try:
            print('Listening...')
            audio = r.listen(source)
        except (KeyboardInterrupt, SystemExit):
            print('Keyboard iterrupt')
            stop=True
    # translate recording to text 
    try:
        text.append(r.recognize_google(audio))
        pd.DataFrame(text).to_csv('realtime_conversation.csv')
        print('got it.')
    except sr.UnknownValueError:
        # speech was unintelligible
        print("Sorry, Unable to recognize speech")

print(text)
