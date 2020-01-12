CLUSTERS="/home/square/Documents/projects/savant_rework/resavant/temp/3-cluster/Chart/1"
CVR_PATH="/home/square/Documents/projects/savant_rework/resavant/temp/2-coverage/Chart/1"
OUTDIR="$CLUSTERS/daikon_data"

python $(dirname "$0")/build_daikon_data.py --clusters $CLUSTERS --coverage_stat $CVR_PATH --out_dir $OUTDIR
