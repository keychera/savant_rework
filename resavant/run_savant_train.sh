# check prereq
. $(dirname "$0")/run.config
. $(dirname "$0")/modules.structure
. $SCRIPTS_PY/check_py.sh


# process args
print_usage() {
  printf "Usage: ..."
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

# l2r, aggregate the results and train
$L2R_MODULE/run_l2r_train.sh -i "$L2R_DATA_FOLDER" -o "$OUTPUT_FOLDER"
savant_timelog "aggregation + normalization + l2r training"
