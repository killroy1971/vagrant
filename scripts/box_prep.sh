#!/bin/bash
# This script will prepare a vagrant box for packaging.
# The following tasks are performed:
# Update yum managed packages
# Remove old kernels
# CENTOS6/RHEL6 - Remove persistent udev rules
# Remove the ssh host keys
# Reset vagrant's authorized_keys file to the vagrant-insecure public key
# Clear yum's cache
# Remove root's and vagrant's .bash_history files
# Reset audit and rsyslog files
# Clean up /tmp and /var/tmp
# Clear bash history

# Update software
if [ -x /usr/bin/dnf ]; then
  /usr/bin/dnf -y update
else
  /bin/yum -y update
fi

# Remove old kernels
if [ -x /bin/package-cleanup ]; then
  /bin/package-cleanup --oldkernels --count=1
fi

# Halt rsyslog
if [ -x /bin/systemctl ]; then
  /bin/systemctl stop rsyslog
else
  service rsyslog stop
fi

# RHEL6/CENTOS6 remove network udev rules
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
  /bin/rm -f /etc/udev/rules.d/70-persistent-net.rules
fi

# Remove SSH host keys
/bin/rm -f /etc/ssh/*key*

# Clear system audits and remove archived logs
/usr/sbin/logrotate -f /etc/logrotate.conf
/bin/rm -f /var/log/*-???????? /var/log/*.gz 
/bin/rm -f /var/log/audit*-???????? /var/log/audit/*.gz
/bin/rm -f /var/log/dmesg.old

# Truncate system logs
/bin/cat /dev/null > /var/log/audit/audit.log
/bin/cat /dev/null > /var/log/wtmp
/bin/cat /dev/null > /var/log/lastlog
/bin/cat /dev/null > /var/log/grubby
/bin/cat /dev/null > /var/log/messages
/bin/cat /dev/null > /var/log/secure
/bin/cat /dev/null > /var/log/maillog
/bin/cat /dev/null > /var/log/btmp
/bin/cat /dev/null > /var/log/cron
/bin/cat /dev/null > /var/log/boot.log
if [ -f /var/log/wap_supplicant.log ]; then 
  /bin/cat /dev/null > /var/log/wpa_supplicant.log
fi

# Clean up /tmp and /var/tmp
/bin/rm -f /tmp/*
/bin/rm -Rf /tmp/yum*
/bin/rm -Rf /var/tmp/*

# Reset vagrant's authorized_keys file
cp -f /root/vagrant_insecure.pub /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys

# Remove root's and vagrant's bash_history files
if [ -f /root/.bash_history ]; then /bin/rm -f /root/.bash_history; fi
if [ -f /home/vagrant/.bash_history ]; then /bin/rm -f /home/vagrant/.bash_history; fi

# Clear this user's bash history
history -c

