PROJECT="Lang"
TARGET_PROJECT="/home/square/Documents/projects/savant_rework/resavant/temp/0-checkout/$PROJECT/1/b"
CLUSTERS="/home/square/Documents/projects/savant_rework/resavant/temp/3-cluster/$PROJECT/1"
CVR_PATH="/home/square/Documents/projects/savant_rework/resavant/temp/2-coverage/$PROJECT/1"
OUTPUT_DIR="$(dirname "$0")/temp$PROJECT"

$(dirname "$0")/run.sh -p $TARGET_PROJECT -c $CLUSTERS -v $CVR_PATH -o $OUTPUT_DIR
