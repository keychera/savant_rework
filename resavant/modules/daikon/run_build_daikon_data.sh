PROJECT="Lang"
CLUSTERS="/home/square/Documents/projects/savant_rework/resavant/temp/3-cluster/$PROJECT/1"
CVR_PATH="/home/square/Documents/projects/savant_rework/resavant/temp/2-coverage/$PROJECT/1"
JAVA7_PATH="/usr/java/jdk1.7.0_80/jre/bin/java"

OUT_DIR="$(dirname "$0")/temp$PROJECT"
if [ -d "$OUT_DIR" ]; then
    rm -r $OUT_DIR
fi
DAIKON_DATA_DIR="$OUT_DIR/temp_daikon_data"
mkdir -p $DAIKON_DATA_DIR

python $(dirname "$0")/build_daikon_data.py --clusters $CLUSTERS --coverage_stat $CVR_PATH --out_dir $DAIKON_DATA_DIR

TARGET_PROJECT="/home/square/Documents/projects/savant_rework/resavant/temp/0-checkout/$PROJECT/1/b"
DAIKON_OUT_DIR="$OUT_DIR/temp_daikon_result"
mkdir -p $DAIKON_OUT_DIR

# compile target project
CUR_DIR=$(pwd)
cd $TARGET_PROJECT
git clean -fd
defects4j compile
cd $CUR_DIR

$(dirname "$0")/run_daikon.sh -t $TARGET_PROJECT -d $DAIKON_DATA_DIR -o $DAIKON_OUT_DIR
