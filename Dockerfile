FROM ubuntu:14.04
MAINTAINER Milo van der Linden <milo@dogodigi.net>

# Install base packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && apt-get -yq install git
RUN locale-gen en_US.utf8
# Defaults, modify with environment variable to change
ENV LANG en_US.utf8
ENV PG_HOST db
ENV PG_PORT 5432
ENV PG_DATABASE fms
ENV PG_USER fms
ENV PG_PASSWORD fms
ENV BASE_URL http://localhost:3000
ENV EMAIL_DOMAIN example.org
ENV CONTACT_EMAIL contact@example.org
ENV CONTACT_NAME fixmystreet
ENV NOREPLY_EMAIL no_reply@example.org
ENV MAPIT_URL http://global.mapit.mysociety.org/
ENV SMTP_SMARTHOST localhost
ENV GAZE_URL http://gaze.mysociety.org/gaze

# Add image configuration and scripts
ADD run.sh /run.sh
RUN chmod 755 /*.sh

# Configure /fixmystreet folder
RUN mkdir -p /fixmystreet
RUN git clone --recursive https://github.com/mysociety/fixmystreet.git /fixmystreet

WORKDIR /fixmystreet

RUN xargs -a conf/packages.ubuntu-precise apt-get install -y -q
RUN bin/install_perl_modules
RUN gem install --user-install --no-ri --no-rdoc bundler
RUN $(ruby -rubygems -e 'puts Gem.user_dir')/bin/bundle install --deployment --path ../gems --binstubs ../gem-bin
RUN bin/make_css

# Setup config
COPY general.yml /fixmystreet/conf/general.yml

EXPOSE 3000
CMD ["/run.sh"]
