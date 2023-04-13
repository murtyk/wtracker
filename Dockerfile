FROM ruby:3.1.4
RUN apt-get update -qq && apt-get install -y --force-yes nodejs
RUN apt install -y --force-yes  nodejs npm

RUN apt-get install -y libgconf-2-4

#chrome
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt-get install ./google-chrome-stable_current_amd64.deb -y

COPY install_chrorme_driver.sh ./install_chrorme_driver.sh
RUN chmod +x ./install_chrorme_driver.sh
RUN ./install_chrorme_driver.sh

#chrome driver
# RUN wget http://chromedriver.storage.googleapis.com/111.0.5563.64/chromedriver_linux64.zip
# RUN unzip chromedriver_linux64.zip
# RUN mv chromedriver /usr/local/bin
# RUN chown root:root /usr/local/bin/chromedriver
# RUN chmod +x /usr/local/bin/chromedriver


# RUN npm install -g phantomjs
RUN mkdir /wtracker
WORKDIR /wtracker
COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
RUN bundle install
COPY . /wtracker
