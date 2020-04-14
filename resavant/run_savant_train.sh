# check prereq
. $(dirname "$0")/run.config
. $(dirname "$0")/modules.structure
. $(dirname "$0")/check_py.sh

# process args
print_usage() {
  printf "Usage: -i L2R_DATA_FOLDER_PATH -o OUTPUT_FOLDER_PATH\n"
}

while getopts 'i:o:' flag; do
  case "${flag}" in
    i) L2R_DATA_FOLDER="${OPTARG}" ;;
    o) OUTPUT_FOLDER="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done
mkdir -p $OUTPUT_FOLDER

# prep the timer
. $(dirname "$0")/timelog.sh "$OUTPUT_FOLDER/train_timelog"

# aggregate features and names
$PY_COMMAND $L2R_MODULE/aggregate_input.py "$L2R_DATA_FOLDER" "$OUTPUT_FOLDER/aggregate_features"
if [ -d "$L2R_DATA_FOLDER/methodnames" ]
then
  $PY_COMMAND $L2R_MODULE/aggregate_input.py "$L2R_DATA_FOLDER/methodnames" "$OUTPUT_FOLDER/aggregate_names"
fi
savant_timelog "aggregation"

# normalize the value and train them
$L2R_MODULE/run_l2r_train.sh -i "$OUTPUT_FOLDER/aggregate_features" -o "$OUTPUT_FOLDER"
savant_timelog "normalization + l2r training"
