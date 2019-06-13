FROM debian:stretch
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
RUN apt-get install wget gnupg gnupg2 gnupg1 -y

# install google chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update
RUN apt-get install -y google-chrome-stable

# install chromedriver
RUN apt-get install -yqq unzip curl
RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip
RUN unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

# install selenium
RUN apt-get install -yqq python-setuptools python-dev python-pip
RUN pip install --upgrade pip
RUN python -m pip install selenium psutil pyvirtualdisplay unittest-xml-reporting requests pysftp

RUN apt-get install -yqq git

# update limit
RUN ulimit -s 1082768

# set display port to avoid crash
ENV DISPLAY=:99

COPY entrypoint.sh /
COPY report.py /

#ensure entrypoint is executable (force flags update, because file flags may change if a commit is made under Windows)
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh
