cycle_start_min=1  # minute when first new cycle of the day starts
cycle_duration_min=10  # duration of one measurement cycle in minutes
consider_last_n_min=10  # consider files generated in the last minutes normally equal to cycle duration. For longer periods make sure to use timestamp_style=cycle_start 
data_dir=../data/rpg_rename/
outdir=../data/rpg_rename/out/
timestamp_style=cycle_start  # cycle_start: assumed start of measurement cycle; min_in: smallest input timestamp matching period. CARE: min_in only works if consider_last_n_min makes sure that files from only one obs cycle are consdiered 

# START OF FUNCTION DEFINITIONS
function filename2epoch {
    local filename=$1
    local len_ext=${2:-4}
    
    local ts_sec=00
    local ts_min=${filename:(-$(($len_ext+2))):2}
    local ts_hour=${filename:(-$(($len_ext+4))):2}
    local ts_date=${filename:(-$(($len_ext+12))):8}  
    
    ts_epoch=$(date --utc -d "$ts_date $ts_hour:$ts_min:$ts_sec" +"%s")
}

function epoch2timestamp {
	local ts_epoch=$1
	stamp=$(date --utc -d "@$ts_epoch" +"%Y%m%d%H%M")
}
# END OF FUNCTION DEFINITIONS


# START OF SCRIPT

# getting data
files=$(find $data_dir -maxdepth 1 \( -name "*.BRT" -o -name "*.BLB" -o -name "*.HKD" -o -name "*.MET" -o -name "*.IRT" \) -mmin -$consider_last_n_min)
echo $files

# preparing for different timestamp options
if [ "$timestamp_style" = "min_in" ]
then
	min_time=$(date --utc +"%s")  #initialise minimum time with actual time
	for file in $files
	do
		filename2epoch $file
		min_time=$(( min_time < ts_epoch ? min_time : ts_epoch))
	done
	time_for_stamp=$min_time
elif [ "$timestamp_style" = "cycle_start" ]
then
	cycle_duration_sec=$((cycle_duration_min*60))
	cycle_start_sec=$((cycle_start_min*60))
else
	echo "timestamp_style is only allowed ot be set to cycle_start or min_in"
	exit 1
fi

# copying and renaming files to outdir
for file in $files
do
	# calculate timestamp if still needed
    if [ "$timestamp_style" = "cycle_start" ]
	then
		filename2epoch $file
		ts_shifted=$((ts_epoch-cycle_start_sec))
        # use property that in bash "/" is integer division to round to multiples of cycle duration
		time_for_stamp=$((ts_shifted/cycle_duration_sec*cycle_duration_sec+cycle_start_sec))
	fi
	epoch2timestamp $time_for_stamp
	echo $stamp
	# TODO: copy to outdir and use stamp to replace filename at copy destination. For this need to find out length of stamps in initial and final filename
done

#TODO: replace prefix filename of files in outdir (use emermet script as example)
#TODO: send to FTP (use emermet script as example)

