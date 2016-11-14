# Base image 
#FROM ruby:2.2.5
FROM ruby:2.3.1

MAINTAINER jeremy.pumphrey@nih.gov

RUN apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

ENV INSTALL_PATH /usr/app
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

# Install gems 
COPY Gemfile $INSTALL_PATH/
RUN gem install bundler
RUN bundle install 

COPY . . 
RUN ruby -v; rails -v; bundler -v; gem -v
RUN pwd;ls -alt $INSTALL_PATH

ENV RAILS_ENV test

#Insert script to change localhost to docker-compose names
ADD https://raw.githubusercontent.com/CBIIT/match-docker/master/docker-compose-env.sh .
RUN chmod 755 docker-compose-env.sh && ls -alt $INSTALL_PATH

# Default command 
CMD ./docker-compose-env.sh && rails server
#CMD ["rails", "server", "--binding", "0.0.0.0"]
