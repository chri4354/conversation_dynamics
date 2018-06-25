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


import speech_recognition as sr

#%%

r = sr.Recognizer()
mic = sr.Microphone()
mics = sr.Microphone.list_microphone_names() # print list of mics
mic = sr.Microphone(device_index=mics.index('default'))

# start recording until silence is detected
with mic as source:
    try:
        r.adjust_for_ambient_noise(source)
        audio = r.listen(source)
        transcribed text = r.recognize_google(audio)
    except sr.UnknownValueError:
        # speech was unintelligible
        print("Sorry, Unable to recognize speech")


