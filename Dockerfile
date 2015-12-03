FROM ubuntu:14.04
MAINTAINER Milo van der Linden "milo@dogodigi.net"

RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q git

RUN locale-gen en_US.utf8 && \
	cachebuster=b953b35 git clone --recursive https://github.com/mysociety/fixmystreet.git

ENV LANG nl_NL.UTF-8

WORKDIR /fixmystreet

# Install packages
RUN xargs -a conf/packages.ubuntu-precise apt-get install -y -q

# Install prerequisite Perl modules
RUN bin/install_perl_modules

# Install compass and generate CSS
RUN gem install --user-install --no-ri --no-rdoc bundler
RUN $(ruby -rubygems -e 'puts Gem.user_dir')/bin/bundle install --deployment --path ../gems --binstubs ../gem-bin
RUN bin/make_css

# Copy shell script
ADD install-database.sh /tmp/install-database.sh
RUN chmod +x /tmp/install-database.sh
ADD pgpass /root/.pgpass
RUN chmod 0600 /root/.pgpass

# Reports
#RUN bin/update-all-reports

# Setup config
ADD general.yml /fixmystreet/conf/general.yml

EXPOSE 3000

CMD ["/bin/bash"]
ENTRYPOINT ["script/fixmystreet_app_server.pl", "-d", "--fork"]
