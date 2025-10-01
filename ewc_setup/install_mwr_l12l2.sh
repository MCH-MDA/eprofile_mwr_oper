# clone mwr_l12l2 and install it with its dependencies. Needs pip>21.3 installed, hence first run update_python.sh

repo_name=mwr_l12l2
repo_url=https://github.com/MeteoSwiss/mwr_l12l2
base_dir="$HOME"  # directory where to install code in as a subdirectory

echo 
echo "installing mwr_l12l2 from github"
echo "================================"
echo


act_path=$(pwd)
cd $base_dir
git clone $repo_url
cd $repo_name
source $base_dir/.env_mwr/bin/activate
pip3 install -e .
cd $act_path
