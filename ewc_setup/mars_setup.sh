# This script mainly instructs the user what to do for setting up mars"

echo 
echo "To set up mars follow the steps below:"
echo "======================================"
echo

echo "Setting up mars"
echo "  !!! CARE: Make sure to have your API key registered on this machine !!!"
echo "      get it in your ECMWF account at https://apps.ecmwf.int/v1/key"
echo "      then do the following: mars --token MY_API_KEY --email MY_EMAIL"

echo "Setting up webmars"
echo "  !!! CARE: make sure to remove webmars settings once EWC has moved to Bologna !"
echo "export MARS_ENVIRON_ORIGIN=webmars" >> ~/.profile
echo "export MARS_ENVIRON_ORIGIN=webmars" >> ~/.bashrc

