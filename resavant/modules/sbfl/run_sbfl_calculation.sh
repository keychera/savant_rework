# process args
MATRIX_PASSING_PATH=''
MATRIX_FAILING_PATH=''
OUTPUT_FOLDER=''

print_usage() {
  printf "Usage: ..."
}

while getopts 'p:f:o:' flag; do
  case "${flag}" in
    p) MATRIX_PASSING_PATH="${OPTARG}" ;;
    f) MATRIX_FAILING_PATH="${OPTARG}" ;;
    o) OUTPUT_FOLDER="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

# calculate raw statistic
$PY_COMMAND $(dirname "$0")/calculate_sbfl_raw_statistic.py "$MATRIX_PASSING_PATH" "$MATRIX_FAILING_PATH" "$OUTPUT_FOLDER/raw_stat"

# calculate given sbfl formula
$PY_COMMAND $(dirname "$0")/calculate_sbfl_suspiciousness_score.py "$OUTPUT_FOLDER/raw_stat" "$OUTPUT_FOLDER/susp_scores"
