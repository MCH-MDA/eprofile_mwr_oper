# This script sets up SFTP config and group. For adding users use distinct scripts
# It takes 2 optional arguments
# 
# sftp_server_setup.sh [SFTP_ROOTDIR SFTP_GROUPNAME]


SFTP_ROOTDIR=${1:-/sftp}
SFTP_GROUPNAME=${2:-sftp}

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
    PasswordAuthentication yes
EOT


## restart SSH
sudo systemctl restart ssh


## add group for sftp
sudo groupadd $SFTP_GROUPNAME

