# check prereq
. $(dirname "$0")/run.config
. $(dirname "$0")/modules.structure
. $(dirname "$0")/check_py.sh


# process args
print_usage() {
  printf "Usage: -i L2R_DATA_FILE_PATH -m MODEL_FILE_PATH -o OUTPUT_FOLDER_PATH"
}

while getopts 'i:m:o:' flag; do
  case "${flag}" in
    i) L2R_DATA_FILE="${OPTARG}" ;;
    m) MODEL_FILE="${OPTARG}" ;;
    o) OUTPUT_FOLDER="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done
mkdir -p $OUTPUT_FOLDER

# predict something
$RANKSVM_FOLDER/predict $L2R_DATA_FILE $MODEL_FILE "$OUTPUT_FOLDER/output"
