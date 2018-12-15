General
-------
This project is intended to be used during development only to easily create certificates signed by a custom certificate authority. The aim is to lower the bar of using HTTPS in development, so it will be more accessible to anyone. The main focus is to provide an easy way to create certificates to be used in all major browsers, Android and iOS emulators. We will try to provide detailed instructions for most Linux flavours, and OSX. Unfortunately, Windows Phone emulators and Windows machines are out of scope at the moment; feel free to create a pull request to remedy this _shortcoming_.

How to create your root certificate
------------------------------------
First clone the project and create the root certificate.

* `cd /etc`
* `sudo git clone https://github.com/onepesu/easyCA.git`
* `cd easyCA`
* if you have make 4.2+, you can optionally add a default email, by `echo <email> | sudo tee /etc/easyCA/email_default` > /dev/null
* `sudo make ca/certs/ca.crt`

This needs to be done only once.

How to create a server certificate
----------------------------------
Then proceed by creating a certificate for each different server you would like to use. The first time you'll try to create a certificate, a key for your host will be created as well.
* `sudo make servers/certs/<server_name>.crt`

How to install your certificates
--------------------------------
Please follow the [wiki](https://github.com/onepesu/easyCA/wiki) instructions for your OS/server/browser combination
