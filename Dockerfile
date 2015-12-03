FROM ubuntu:14.04
MAINTAINER Milo van der Linden <milo@dogodigi.net>

# Install base packages
RUN apt-get -qq update && \
    apt-get -yq install \
        git

# Defaults, modify with environment variable to change
ENV PG_HOST db
ENV PG_PORT 5432
ENV PG_DATABASE fms
ENV PG_USER fms
ENV PG_PASSWORD fms
ENV BASE_URL 'http://localhost:3000'
ENV EMAIL_DOMAIN example.org
ENV CONTACT_EMAIL contact@example.org
ENV CONTACT_NAME fixmystreet
ENV NOREPLY_EMAIL no_reply@example.org
ENV STREET_EXAMPLE1 'High Street'
ENV STREET_EXAMPLE2 'Main Street'
ENV LANGUAGES 'en-gb,English,en_GB'
ENV MAPIT_URL 'http://global.mapit.mysociety.org/'
ENV MAPIT_TYPES 'O06'
ENV MAPIT_ID_WHITELIST ''
ENV SMTP_SMARTHOST localhost
ENV SMTP_TYPE ''
ENV SMTP_PORT ''
ENV SMTP_USERNAME ''
ENV SMTP_PASSWORD ''
ENV GAZE_URL 'http://gaze.mysociety.org/gaze'
ENV AREA_LINKS_FROM_PROBLEMS '0'
ENV TESTING_COUNCILS ''
ENV MESSAGE_MANAGER_URL ''


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
