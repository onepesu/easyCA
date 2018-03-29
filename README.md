General
-------
This project is intended to be used during development only to easily create certificates signed by a custom certificate authority. The aim is to lower the bar of using HTTPS in development, so it will be more accessible to anyone. The main focus is to provide an easy way to create certificates to be used in all major browsers, Android and iOS emulators. We will try to provide detailed instructions for most Linux flavours, and OSX. Unfortunately, Windows Phone emulators and Windows machines are out of scope at the moment; feel free to create a pull request to remedy this _shortcoming_.

How to create your first certificate
------------------------------------
First clone the project and create the root certificate.
* `cd /root`
* `sudo git clone https://github.com/onepesu/easyCA.git`
* `sudo make ca/certs/ca.crt`

`/root/ca/certs/ca.crt` is the only certificate you need to install to your system/emulators/browsers. Detailed description on how to do so is found in the project's wiki. This must be done only once per device.

Then proceed by creating a certificate for each different server you would like to use. The first time you'll try to create a certificate, a key for this host will be created as well.
* `sudo make servers/certs/example.dev.crt`
