# This script interactively adds a new user to a previously configured SFTP usergroup

SFTP_ROOTDIR='/sftp'
SFTP_GROUPNAME='sftp'

## add user to sftp group
read -p 'SFTP User Name: ' uname
sudo useradd -g $SFTP_GROUPNAME -d /upload -s /sbin/nologin $uname  #don't use -p option, rather go for subsequent call to passwd
echo "Please specify password for SFTP user $uname"
sudo passwd $uname

## generate his home and adapt permissions
sudo mkdir -p $SFTP_ROOTDIR/$uname/upload
sudo chown -R root:$SFTP_GROUPNAME $SFTP_ROOTDIR/$uname
sudo chown -R $uname:$SFTP_GROUPNAME $SFTP_ROOTDIR/$uname/upload

