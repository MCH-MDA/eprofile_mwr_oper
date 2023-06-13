# this is the main script orchestrating the whole set up of a new VM from scratch

path_scripts=$(dirname "$0")
echo $path_scripts


$path_scripts/update_python.sh
$path_scripts/install_ecmwf_libs.sh
$path_scripts/install_podman.sh
$path_scripts/update_tropoe.sh
$path_scripts/install_mwr_l12l2.sh
$path_scripts/sftp_setup.sh  # finalise
$path_scripts/mars_setup.sh

