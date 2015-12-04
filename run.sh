#! /bin/bash

echo $PG_HOST:$PG_PORT:$PG_DATABASE:$PG_USER:$PG_PASSWORD > /root/.pgpass
chmod 0600 /root/.pgpass

psql -h $PG_HOST -U $PG_USER $PG_DATABASE < /fixmystreet/db/schema.sql
psql -h $PG_HOST -U $PG_USER $PG_DATABASE < /fixmystreet/db/generate_secret.sql
psql -h $PG_HOST -U $PG_USER $PG_DATABASE  < /fixmystreet/db/alert_types.sql

sed -i "s/__DB_HOST__/$PG_HOST/g" /fixmystreet/conf/general.yml
sed -i "s/__DB_PORT__/$PG_PORT/g" /fixmystreet/conf/general.yml
sed -i "s/__DB_NAME__/$PG_DATABASE/g" /fixmystreet/conf/general.yml
sed -i "s/__DB_USER__/$PG_USER/g" /fixmystreet/conf/general.yml
sed -i "s/__DB_PASS__/$PG_PASSWORD/g" /fixmystreet/conf/general.yml
sed -i "s#__BASE_URL__#$BASE_URL#g" /fixmystreet/conf/general.yml
sed -i "s/__EMAIL_DOMAIN__/$EMAIL_DOMAIN/g" /fixmystreet/conf/general.yml
sed -i "s/__CONTACT_EMAIL__/$CONTACT_EMAIL/g" /fixmystreet/conf/general.yml
sed -i "s/__CONTACT_NAME__/$CONTACT_NAME/g" /fixmystreet/conf/general.yml
sed -i "s/__NOREPLY_EMAIL__/$NOREPLY_EMAIL/g" /fixmystreet/conf/general.yml
sed -i "s/__SMTP_SMARTHOST__/$SMTP_SMARTHOST/g" /fixmystreet/conf/general.yml
sed -i "s#__GAZE_URL__#$GAZE_URL#g" /fixmystreet/conf/general.yml
sed -i "s#__MAPIT_URL__#$MAPIT_URL#g" /fixmystreet/conf/general.yml
MAPIT_URL
# reports
/fixmystreet/bin/update-all-reports
# run
/fixmystreet/script/fixmystreet_app_server.pl -d --fork
