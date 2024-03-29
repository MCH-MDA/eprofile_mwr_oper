# clone mwr_l12l2 and install it with its dependencies. Needs pip>21.3 installed, hence first run update_python.sh

base_dir="$HOME"  # directory where to install code in as a subdirectory mwr_l12l2


echo 
echo "installing mwr_l12l2 from github"
echo "================================"
echo


act_path=$(pwd)
cd $base_dir
git clone https://github.com/MeteoSwiss/mwr_l12l2
cd mwr_l12l2
pip3 install -e .  # don't need a virtual environment here, as this is the only python code running on this VM
cd $act_path
