#!/bin/bash

# Script to lock down a Fedora based Linux system

#    Copyright 2011, Jon Mentzell <siliconjesus@gmail.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

### FUNCTIONS ###

# errorExit does exactly that
errorExit(){
	echo It appears you are trying to use this on a system that is not Fedora.
	echo Get out your favorite editor and start contributing to this project!
	exit 999
}

# lockdown - the script that does the heavy lifting.  Will call other functions as needed.

lockdown(){
	# Add rpms in case they're needed.
	yum install -y openssh openssh_server iptables iptables-ipv6 
	
	# first lock down iptables
	cp /etc/sysconfig/iptables /etc/sysconfig/iptables.orig
	cp /etc/sysconfig/iptables.ipv6 /etc/sysconfig/iptables.ipv6.orig

	/sbin/service iptables stop
	/sbin/service iptables-ipv6 stop
	
	# We need to get the ip address of the primary network interface
	# plus its network information.  Luckily ifconfig does a lot of that for us.
	
	##### TODO: add stuff to get additional network interfaces.
	
	eth0_addr=`ifconfig eth0 | grep Mask: | awk -F: '{print $2}'`
	eth0_bcast=`ifconfig eth0 | grep Mask: | awk -F: '{print $4}'`
	eth0_netmask=`ifconfig eth0 | grep Mask: | awk -F: '{print $6}'`
		
	cat > /etc/sysconfig/iptables << EOF
# Custom rules created by the lockdown script
# Copyright Jon Mentzell 2013
# Licensed under the GPL
*filter
:INPUT DROP [0:0]
:FORWARD REJECT [0:0]
:OUTPUT ACCEPT [0:0]
:CHECKIP ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p icmp -j REJECT --reject-with icmp-host-prohibited
-A INPUT -p tcp --dport 22 -j CHECKIP
-A INPUT -p tcp --dport 443 -j CHECKIP
#### Put in the CHECKIP stuff and logging along with the DROP stuff.
EOF
	# Lockdown sshd server.
sed -e 's/#PermitRootLogin yes/PermitRootLogin no/'
sed -e 's/#Banner none/Banner \/etc\/ssh\/ssh.banner/'

cat > /etc/ssh.banner << EOF
######################## W A R N I N G #########################
#                                                              #
# Use of this computing resource is restricted to authorized   #
# users.  Unauthorized access to this system is forbidden and  #
# will be prosecuted to the fullest extent of the law.  All    #
# information contained within this system are subject to      #
# review, monitoring and recording at any time.  DISCONNECT    #
# NOW IF YOU DO NOT AGREE TO THE ABOVE TERMS AND CONDITIONS.   #
# Users of this computing resource should have no expectation  #
# of privacy.                                                  #
#                                                              #
################################################################
EOF
}

### MAIN ###

echo This script has been created to help lock down Fedora based Linux systems.
if [ -f /etc/redhat-release ]
	then
		grep Fedora /etc/redhat-relase
		if [ $? -eq 0 ]
			then
				errorExit
		else 
			lockdown
		fi
	else
	errorExit
fi
