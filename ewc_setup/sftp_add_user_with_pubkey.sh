# This script adds a new user to a previously configured SFTP usergroup. 
# It takes 2 mandatory and 2 optiona arguments
#
# sftp_add_user_with_pubkey.sh USERNAME PUBKEY_FILE [SFTP_ROOTDIR SFTP_GROUPNAME]

uname=$1
pubkey=$2
SFTP_ROOTDIR=${3:-/sftp}
SFTP_GROUPNAME=${4:-sftp}

## add user to sftp group
sudo useradd -g $SFTP_GROUPNAME -d /upload -s /sbin/nologin $uname  #don't use -p option, rather go for subsequent call to passwd


## generate his home, add public key and adapt permissions
sudo mkdir -p $SFTP_ROOTDIR/$uname/.ssh
cat $pubkey | sudo tee -a $SFTP_ROOTDIR/$uname/.ssh/authorized_keys

sudo mkdir -p $SFTP_ROOTDIR/$uname/upload
sudo chown -R root:$SFTP_GROUPNAME $SFTP_ROOTDIR/$uname
sudo chown -R $uname:$SFTP_GROUPNAME $SFTP_ROOTDIR/$uname/upload


