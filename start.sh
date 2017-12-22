#!/bin/bash
# 
# start postfix and send a test mail

## handle termination gracefully

_term() {
  echo "Terminating stack"
  service postfix stop
  service rsyslog stop
  exit 0
}

trap _term SIGTERM

## initialise list of log files to stream in console (initially empty)
OUTPUT_LOGFILES=""

## start services as needed

service rsyslog start

## start postfix

service postfix start

OUTPUT_LOGFILES+="/var/log/mail.log"

touch $OUTPUT_LOGFILES
tail -f $OUTPUT_LOGFILES &

echo "sending test mail"
sleep 3s
echo "Test mail from postfix" | mail -s "Test Postfix" jaci@seriousman.org
echo "Done, now look at your inbox"
wait

