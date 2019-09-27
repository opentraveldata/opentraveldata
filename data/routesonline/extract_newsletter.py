#!/usr/bin/env python3
import requests
import datetime
from bs4 import BeautifulSoup
import re
import sys


SEP = "â"


def is_schedule_line(line):
    if not SEP in line:
        return False
    # remove double spaces
    line = re.sub(' +', ' ', line)
    blocks = [block.strip() for block in line.split(SEP)]
    # we expect a first component with 2 tokens
    if len(blocks[0].split(' ')) != 2:
        return False
    for b in blocks:
        tokens = b.strip().split(' ')
        for t in tokens:
            if t.upper() != t:
                return False
    return True


def clean_schedule_line(line):
    line = re.sub(' +', ' ', line)
    return '-'.join([block.strip() for block in line.split(SEP)])


def extract_schedule(html):
    soup = BeautifulSoup(html, 'html.parser')
    body = soup.body
    articles = map(
        lambda x: x.find_parent().find_next_sibling().find_next_sibling(),
        body(attrs={'name': re.compile("article")})
        )
    for a in articles:
        text = a.prettify().split('\n')
        for line in text:
            if is_schedule_line(line):
                print(clean_schedule_line(line))


def extract_newsletter(url):
    r = requests.get(url)
    extract_schedule(r.text)


if __name__ == "__main__":
    url = 'https://content.routesonline.com/newsletters/53-2019-08-19.html'
    if len(sys.argv) > 1:
        url = sys.argv[1]
    extract_newsletter(url)
