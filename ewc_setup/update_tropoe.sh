# This script gets the image of the TROPoe container from dockerhub

TROPOE_IMG=docker.io/davidturner53/tropoe:latest


echo 
echo "Installing/Updating TROPoe"
echo "=========================="
echo

podman pull $TROPOE_IMG