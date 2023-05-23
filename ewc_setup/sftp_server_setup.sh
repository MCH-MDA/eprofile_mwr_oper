# This script sets up SFTP config and group. Add users with distinct script

SFTP_ROOTDIR='/sftp'
SFTP_GROUPNAME='sftp'

## create SFTP directory
sudo mkdir -p $SFTP_ROOTDIR
sudo chmod 701 $SFTP_ROOTDIR

## SSHD config for SFTP group
sudo tee -a /etc/ssh/sshd_config > /dev/null <<EOT 

# Set up SFTP
Match group $SFTP_GROUPNAME
    ChrootDirectory $SFTP_ROOTDIR/%u
    ForceCommand internal-sftp
    PermitRootLogin no
    RSAAuthentication yes
    PubkeyAuthentication yes
    AuthorizedKeysFile $SFTP_ROOTDIR/%u/.ssh/authorized_keys
    #PasswordAuthentication no
EOT


## restart SSH
sudo systemctl restart ssh


## add group for sftp
sudo groupadd $SFTP_GROUPNAME

