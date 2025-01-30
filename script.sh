
#!/bin/bash

echo "------------------------[TASK 1] Enabling ssh password authentication--------------------"
sudo apt install openssh-server -y
sed -i -e 's/^PasswordAuthentication no/PasswordAuthentication yes/' \
       -e '$a\PasswordAuthentication yes' /etc/ssh/sshd_config
service ssh reload


echo "------------------------[TASK 2] Setting up root password----------------------"
echo -e "etcdadmin\netcdadmin" | passwd root >/dev/null 2>&1
