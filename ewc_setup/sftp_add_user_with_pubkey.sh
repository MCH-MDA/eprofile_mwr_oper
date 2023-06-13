# This script adds a new user to a previously configured SFTP usergroup.
#
# ./sftp_add_user_with_pubkey.sh USERNAME PUBKEY_FILE

uname=$1
pubkey=$2

SFTP_ROOTDIR='/sftp'
SFTP_GROUPNAME='sftp'

## add user to sftp group
sudo useradd -g $SFTP_GROUPNAME -d /upload -s /sbin/nologin $uname  #don't use -p option, rather go for subsequent call to passwd


## generate his home, add public key and adapt permissions
sudo mkdir -p $SFTP_ROOTDIR/$uname/.ssh
cat $pubkey >> $SFTP_ROOTDIR/$uname/.ssh/authorized_keys

sudo mkdir -p $SFTP_ROOTDIR/$uname/upload
sudo chown -R root:$SFTP_GROUPNAME $SFTP_ROOTDIR/$uname
sudo chown -R $uname:$SFTP_GROUPNAME $SFTP_ROOTDIR/$uname/upload


