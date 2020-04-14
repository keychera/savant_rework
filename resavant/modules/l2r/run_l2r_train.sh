# process args
OUTPUT_FOLDER='./temp-l2r-train-out'

print_usage() {
  printf "Usage: ..."
}

while getopts 'i:o:' flag; do
  case "${flag}" in
    i) FEATURES_FILE="${OPTARG}" ;;
    o) OUTPUT_FOLDER="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done
mkdir -p $OUTPUT_FOLDER

# normalize the input
$PY_COMMAND $(dirname "$0")/normalize_input.py "$FEATURES_FILE" "$OUTPUT_FOLDER/normalized_features" "$OUTPUT_FOLDER/maxmin_info"

# run the libsvm
$RANKSVM_FOLDER/train "$OUTPUT_FOLDER/normalized_features" "$OUTPUT_FOLDER/model"