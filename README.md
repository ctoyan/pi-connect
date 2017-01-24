# pi-connect
A bash script that helps to SSH into a remot3.it device

![](https://media.giphy.com/media/26gsaqUrkL5oKfxOU/source.gif)

remot3.it is a service which allows you to manage remote devices. For example a raspberry pi. The idea for the script came when I read [this article](https://www.raspberrypi.org/documentation/remote-access/access-over-Internet/)

Basically remot3.it provides a web interface to help you manage your devices. It's also a way to access your pi over the internet without opening a port on your network. One of the service's features is to get the SSH host and port(which change every 30 minutes for the free version) for your device - for example RaspberryPi.

With this script you can SSH into your device without having to login into remot3.it to get the host and port.


#Usage

The only thing you have to configure is the username/email on *line 5*. The api key is universal(for now).
After that there are 4 steps to connect to your device:

1. First the script will ask you for your remot3.it password
2. Then it will list your devices
3. Next you choose which device you want to SSH into. If you have only one device it will automatically connect to it
4. The final step is to enter your SSH user.

If an error occurs while you try to SSH into your device you can always turn verbose mode on, by adding `-v` at *line 39*.

If you find any issues or have any questions, please don't hesitate to ask.
