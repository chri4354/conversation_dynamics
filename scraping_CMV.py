# -*- coding: utf-8 -*-
"""
Created on Tue Jun 19 13:49:37 2018

@author: niccolop
"""
import os
os.chdir('/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/conversation_dynamics')

import selenium.webdriver
import bs4 as bs
import time
import re
import numpy as np
import pandas as pd

from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import StaleElementReferenceException

            
#%% define functions
def scroll_down(url):
    driver.get(url)
    SCROLL_PAUSE_TIME = 1
    time.sleep(SCROLL_PAUSE_TIME)
    # Get scroll height
    last_height = driver.execute_script("return document.body.scrollHeight")


    while True:
        # Scroll down to bottom
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        # Wait to load page
        time.sleep(SCROLL_PAUSE_TIME)
        # Calculate new scroll height and compare with last scroll height
        new_height = driver.execute_script("return document.body.scrollHeight")
        if new_height == last_height:
            break
        last_height = new_height
        
    attempts = 0
    while attempts < 5:
        try:
            element = driver.find_element_by_css_selector("[id*=moreComments]")
            element.click()
            attempts = 0
            time.sleep(SCROLL_PAUSE_TIME)
        except:
            attempts += 1

def load_page(subreddit):
    url = "https://www.reddit.com/r/" + subreddit
    scroll_down(url)
    soup = bs.BeautifulSoup(driver.page_source,"html.parser")
    links = []
    for link in soup.find_all("a",{"data-click-id":"body"}):
        if link.has_attr('href'):
            if "/" + subreddit + "/comments" in link["href"]:
                links.append(link['href'])
    return links
    
    
def get_data(text,df_old):
    cols = ["iscom", "title", "user", "level", "points", "body"]
    html = bs.BeautifulSoup(text,"lxml")
    
    # concatenate main submission
    try:
        title = html.find("h2",{"class": re.compile(".*fvdpbH.*")}).text
    except:
        title=''
    iscom = False
    level = 0
    try:
        submission = html.find("div",{"class": re.compile(".*itoCnT.*")})
        submission_text = submission.find("div",{"class": re.compile(".*gOQskj.*")}).text
        submission_text = submission_text.replace("\t"," ").replace("\n"," ").replace("\r"," ")
    except:
        submission_text = ''
    try:
        user = submission.find("a",{"href": re.compile(".*user.*")}).text[2:-1]
    except:
        user = np.nan
    try:
        points = submission.find("span",{"class": re.compile(".*_2cxR1YcQUgsimt7WSmt8FI.*")}).text
    except:
        points=np.nan
#    f.write("{}\t{}\t{}\t{}\t{}\t{}\n".format(iscom,title,user,level,points,submission_text.replace("\t"," ").replace("\n"," ").replace("\r"," ")))

    row = [iscom, title, user, level, points, submission_text]
    df = pd.concat([df_old, pd.DataFrame([row], columns=cols)])
    
    # concatenate comments
    comments =  html.find_all("div",{'class': re.compile(".*s136il31-0.*")})
    for i,c in enumerate(comments):
        #print(com)
        level = len(c.find_all("div",{"class": re.compile(".*efNcNS.*")}))
        com = c.find("div",{'class': re.compile('.*bbMwOF')})
        iscom = True
        try:
            user = com.find("a",{"href": re.compile(".*user.*")}).text
        except :
            user = np.nan        
        try:
            quotes = com.find_all("blockquote",{"class": re.compile(".*kzSHll.*")})
            for match in quotes:
                match.decompose()                
            comment = " ".join([_.text for _ in com.find_all("p",{"class": re.compile(".*iEJDri.*")})])
            comment = comment.replace("\t"," ").replace("\n"," ").replace("\r"," ")
        except:
            comment=''
        try:
            points = com.find("span",{"class": re.compile(".*cFQOcm.*")}).text[:-7]
        except:
            points=np.nan
            
#        f.write("{}\t{}\t{}\t{}\t{}\t{}\n".format(iscom,title,user,level,points,comment.replace("\t"," ").replace("\n"," ").replace("\r"," ")))
        row = [iscom, title, user, level, points, comment]
        df = pd.concat([df, pd.DataFrame([row], columns=cols)])
    return df
    
# %% run 
#driver = selenium.webdriver.Firefox()
driver = selenium.webdriver.Chrome(executable_path="/usr/local/bin/chromedriver")
driver.implicitly_wait(10)
wait = WebDriverWait(driver,10)
subreddit = 'changemyview'
filename = "./results_" + subreddit + ".pkl"
#links = load_page(subreddit)
#add ?sort=new to links
links = ['/r/changemyview/comments/5m17gg/cmv_prochoice_and_prolife_stances_are_both/?sort=new']

df = pd.DataFrame()
for i,link in enumerate(links):
    url = "https://www.reddit.com" + link
    scroll_down(url)
    df = get_data(driver.page_source,df)
    print('size in MB ', df.memory_usage().sum()/1e6)
        
pd.to_pickle(df, filename)
driver.quit()





