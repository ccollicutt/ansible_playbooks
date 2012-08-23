echo "# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
	address 192.168.255.108
	netmask 255.255.255.0

auto eth2
iface eth2 inet manual
	bond-master bond0

auto eth3
iface eth3 inet manual
	bond-master bond0

auto bond0
iface bond0 inet manual
	bond-slaves none
	bond-mode 802.3ad
	bond-miimon 100

auto vlan422
iface vlan422 inet static
	address 199.116.233.20
	netmask 255.255.255.240
	gateway 199.116.233.17
	dns-nameservers 8.8.8.8
	vlan-raw-device bond0

auto vlan423
iface vlan423 inet static
	address 192.168.1.108
	netmask 255.255.255.0
	vlan-raw-device bond0" > /etc/network/interfaces