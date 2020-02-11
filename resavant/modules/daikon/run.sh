# process args
print_usage() {
  printf "Usage: ..."
}

while getopts 'p:c:v:o:' flag; do
  case "${flag}" in
    p) TARGET_PROJECT="${OPTARG}" ;;
    c) CLUSTERS="${OPTARG}" ;;
    v) CVR_PATH="${OPTARG}" ;;
    o) OUTPUT_DIR="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

if [ -d "$OUTPUT_DIR" ]; then
    rm -r $OUTPUT_DIR
fi

DAIKON_DATA_DIR="$OUTPUT_DIR/1_daikon_data"
mkdir -p $DAIKON_DATA_DIR

python $(dirname "$0")/build_daikon_data.py --clusters $CLUSTERS --coverage_stat $CVR_PATH --out_dir $DAIKON_DATA_DIR

DAIKON_OUT_DIR="$OUTPUT_DIR/2_daikon_result"
mkdir -p $DAIKON_OUT_DIR

# compile target project
CUR_DIR=$(pwd)
cd $TARGET_PROJECT
git clean -fd
defects4j compile
cd $CUR_DIR

$(dirname "$0")/run_daikon_iteration.sh -t $TARGET_PROJECT -d $DAIKON_DATA_DIR -o $DAIKON_OUT_DIR

DAIKON_DIFF_DIR="$OUTPUT_DIR/3_daikon_diff"
mkdir -p $DAIKON_DIFF_DIR

$(dirname "$0")/run_diff_iteration.sh -d $DAIKON_OUT_DIR  -o $DAIKON_DIFF_DIR
