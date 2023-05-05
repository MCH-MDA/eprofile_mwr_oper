# INPUT

# measurement cycle specification
cycle_start_min=1  # minute when first new cycle of the day starts
cycle_duration_min=10  # duration of one measurement cycle in minutes
consider_last_n_min=525600 #just for testing #10  # consider files generated in the last minutes normally equal to cycle duration. For longer periods make sure to use timestamp_style=cycle_start 
echo "testversion with consider_last_n_min=525600 for sending all files generated in last year. Undo to =10 once test is done"

# instrument file and data dir specification
data_dir=../data/rpg_rename_3/  # folder where original files are located (include tailing slash)
eprof_dir=../data/rpg_rename/out/  # folder where E-PROFILE files are saved to before being sent to FTP  (include tailing slash)
prefix_orig=test_
prefix_eprof=MWR_GRE_A_

#ftp settings
do_ftp=0  # 1: send via ftp to target specified below; 0:don't send, just test
ftp_host=ftpweb.metoffice.gov.uk
ftp_folder=/deposit/mwr/
ftp_user=YOUR_USER
ftp_pw=YOUR_PW

# the following are E-PROFILE/RPG defaults. Don't change unless having a good reason
timestamp_style=cycle_start  # style of output timestamp. cycle_start: assumed start of measurement cycle; min_in: smallest input timestamp found matching period. CARE: min_in only works if consider_last_n_min makes sure that files from only one obs cycle are consdiered 
len_timestamp_orig=13  # number of characters in timestamp including underlines, dashes etc. CARE: No fractions of seconds foreseen in timestamp
len_sep_date_time=1  # length of separator between date and time in timestamp (usually 1 or 0). No separator foreseen between year/month/day and hour/minute/second 
century=20  # century the timestamp is corresponding to

# you cannot change the following assumption unless modifying the search pattern in the code
len_ext=4  # length of extension including the dot

# END OF INPUT






# FUNCTION DEFINITIONS
function filename2epoch {
    local filename=$1
    
    #init date (yymmdd HH MM SS)
    date_array=(000000 00 00 00)
    
    local start_ind=$((-len_ext-len_timestamp_orig))
    for i in "${!date_array[@]}"
    do
        # define start indices and length of date, hour, minute, second string
        local len_chars=${#date_array[$i]}
        if [ "$i" -eq 0 ]
        then
            # potential separator sign (e.g. underline) between date and time
            local next_start_ind=$((start_ind+len_chars+len_sep_date_time))
        else
            # no separator expected between hour/minute/second
            local next_start_ind=$((start_ind+len_chars))
        fi
        
        # break if length of timestamp has been consumed
        if [ "$next_start_ind" -gt "-$len_ext" ]
        then
            break
        fi
        
        # update date array and prepare for next loop
        date_array[$i]=${filename:$start_ind:$len_chars}
        start_ind=$next_start_ind
    done
    
    ts_epoch=$(date --utc -d "$century${date_array[0]} ${date_array[1]}:${date_array[2]}:${date_array[3]}" +"%s")

}

function epoch2timestamp {
	local ts_epoch=$1
	stamp=$(date --utc -d "@$ts_epoch" +"%Y%m%d%H%M")
}
# END OF FUNCTION DEFINITIONS





# PREPARATION OF FILES FOR SUBMISSION

# this part can be repeated for multiple instruments with same cycle duration and starts if wanting to use the same FTP send folder and command
# in this case alter the variables data_dir, prefix_orig, prefix_eprof here. 

# preparing
umask 002  # give read and write permission to you and your group for output files (execute disablled by default)
len_prefix_orig=${#prefix_orig}

# getting data
files=$(find $data_dir -maxdepth 1 \( -name "$prefix_orig*.BRT" -o -name "$prefix_orig*.BLB" -o -name "$prefix_orig*.HKD" -o -name "$prefix_orig*.MET" -o -name "$prefix_orig*.IRT" \) -mmin -$consider_last_n_min)

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

# copying and renaming files to eprof_dir
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
    bn_file=$(basename $file)
    ext_file=${file##*.}
    file_out=$eprof_dir$prefix_eprof${bn_file:$len_prefix_orig:$((-$len_ext-$len_timestamp_orig))}$stamp.$ext_file
	cp -v $file $file_out
done

# END OF PREPARATION OF FILES FOR SUBMISSION




# PUSH TO FTP AND EMPTY DIR
if [ "$do_ftp" -ne 0 ]
then
    echo "pushing data in $eprof_dir to E-PROFILE"

    path_here=$(pwd)
    cd $eprof_dir

    ftp -n $ftp_host <<END_SCRIPT
    quote USER $ftp_user
    quote PASS $ftp_pw
    prompt off
    binary
    cd $ftp_folder
    mput *.BRT
    mput *.BLB
    mput *.HKD
    mput *.MET
    mput *.IRT

    quit
END_SCRIPT

    cd $path_here

    echo "emptying $eprof_dir"
    rm -v "$eprof_dir*.BRT $eprof_dir*.BLB $eprof_dir*.HKD $eprof_dir*.MET $eprof_dir*.IRT"  # rely on fact that only this script is writing to $eprof_dir
else
    echo "did not push to ftp as do_ftp was set to 0"
fi

# FTP AND CLEANUP DONE