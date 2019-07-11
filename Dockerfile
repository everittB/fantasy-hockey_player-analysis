# Dockerfile to pull NHL stats and create R Shiny application locally
# Brenden Everitt
# July 2019

# Use rocker/shiny-verse as the base image
FROM rocker/shiny-verse

# Install additional R package dependencies
RUN install2.r --error \
  DT \
  plotly \
  lubridate

# Install python
RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip
