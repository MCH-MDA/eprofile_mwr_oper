path_script=$(dirname "$0")

SFTP_ROOTDIR='/sftp'
SFTP_GROUPNAME='sftp'
SFTP_USER='eprof_oper'
LOCAL_KEY="$HOME/.ssh/id_ecdsa_sftp"
PUBKEY_UKMO="$path_script/ssh_pubkeys/dummy_key_ukmo.pub"

# configure a SFTP server
$path_script/sftp_server_setup.sh $SFTP_ROOTDIR $SFTP_GROUPNAME


# generate local key if it does not already exist
if [ ! -f "$LOCAL_KEY" ]; then
    ssh-keygen -f $LOCAL_KEY -t ecdsa -b 521 -N ""
fi

# generate sftp user
$path_script/sftp_add_user_with_pubkey.sh $SFTP_USER $LOCAL_KEY.pub $SFTP_ROOTDIR $SFTP_GROUPNAME

# add MetOffice key to sftp user
cat "$PUBKEY_UKMO" | sudo tee -a $SFTP_ROOTDIR/$SFTP_USER/.ssh/authorized_keys

