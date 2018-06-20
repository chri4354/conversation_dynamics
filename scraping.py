# -*- coding: utf-8 -*-
"""
Created on Tue Jun 19 13:49:37 2018

@author: niccolop
"""
import selenium.webdriver
import bs4 as bs
import time 
import re
import numpy as np
#%% define functions
def load_page(url="https://www.reddit.com/r/prolife"):
    driver.get(url)
    SCROLL_PAUSE_TIME = 0.5
    time.sleep(5)
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
    soup = bs.BeautifulSoup(driver.page_source,"html.parser")
    links = []
    for link in soup.find_all("a",{"data-click-id":"body"}):
        if link.has_attr('href'):
            if "/prolife/comments" in link["href"]:
                links.append(link['href'])
    return links
    
    
def get_data(text,f):
    html = bs.BeautifulSoup(text,"lxml")
    title = html.find_all("h2",{"class": re.compile(".*fvdpbH.*")})
    submission = 
    comments =  html.find_all("div",{'class': re.compile(".*s136il31-0.*")})
    for i,com in enumerate(comments):
        #print(com)
        level = len(com.find_all("div",{"class": re.compile(".*efNcNS.*")}))
        com = com.find("div",{'class': re.compile('.*bbMwOF')})
        try:
            user = com.find("a",{"href": re.compile(".*user.*")}).text
        except :
            user = np.nan        
        try:
            comment = " ".join([_.text for _ in com.find_all("p",{"class": re.compile(".*iEJDri.*")})])
        except:
            comment=''        
        try:
            points = com.find("span",{"class": re.compile(".*cFQOcm.*")}).text[:-7]
        except:
            points=np.nan

        f.write("{}\t{}\t{}\t{}\n".format(user,level,points,comment.replace("\t"," ").replace("\n"," ").replace("\r"," ")))
        
# %% run 
#driver = selenium.webdriver.Firefox()
driver = selenium.webdriver.Chrome(executable_path="/usr/local/bin/chromedriver")
links = load_page("https://www.reddit.com/r/prolife")

with open("./results.csv","w+") as f:
    for i,link in enumerate(links):
        url = "https://www.reddit.com" + link
        driver.get(url)
        get_data(driver.page_source,f)
#        break
