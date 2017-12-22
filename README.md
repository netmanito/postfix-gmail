# postfix + gmail smtp relay docker image

This docker image installs postfix and configures it to send mails through a gmail smtp account.

## HOWTO

Edit **Dockerfile** in order to put your gmail credentials on the environment variables.

	ENV USERNAME="your_gmail_username"
	ENV PASSWORD="your_gmail_password"

Dockerfile will do the following:

Edit **/etc/postfix/generic** file and use your gmail account details as sender before the image is built.

	root@localhost   my_mail_account@gmail.com 

It will also edit **/etc/postfix/sasl/passwd** and use your username and password to access gmail servers before the images is built. 

	[smtp.gmail.com]:587    my_mail_account@gmail.com:my_password


Then build the image

	docker build -t postfix-gmail:v0 .

Run and test
	
	docker run -it postfix-gmail:v0

The *start.sh* init script will send a test mail once the container runs.

## TODO

Modify main.cf to accept internal docker networks.

Check wether exposing port 25 and try send mails from another host through the docker image.
