service ssh start

useradd $USERNAME
mkdir /home/$USERNAME
chown -R $USERNAME:$USERNAME /home/$USERNAME

ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -t ed25519 -N '' -f /etc/ssh/ssh_host_ed25519_key
ssh-keygen -t ecdsa -N '' -f /etc/ssh/ssh_host_ecdsa_key

echo -e -n "$PASSWORD\n$PASSWORD\n" | passwd $USERNAME

sleep infinity

