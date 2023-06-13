# install libraries from ecmwf to treat with grib files (preferably run before install_mwr_l12l2)

echo 
echo "installing ECMWF libraries for GRIB"
echo "==================================="
echo

sudo apt install -y libeccodes0
sudo apt install -y libeccodes-tools