# process args
print_usage() {
  printf "Usage: -i ITERATION_FOLDER_PATH -o OUTPUT_FOLDER_PATH"
}

while getopts 'i:o:' flag; do
  case "${flag}" in
    i) ITERATION_FOLDER="${OPTARG}" ;;
    o) OUTPUT_FOLDER="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done
mkdir -p $OUTPUT_FOLDER

# run evaluation on all iteration
for d in $ITERATION_FOLDER/*/ ; do
    echo $d
    test_data="$(basename $(find $d -name "*testdata"))"
    python $(dirname "$0")/evaluate.py --result_file "$d/out/output" --test_file "$d/$test_data" --output "$OUTPUT_FOLDER/${test_data}_res"
done

# aggregate score
python $(dirname "$0")/aggregate.py --eval_scores_dir "$OUTPUT_FOLDER" > "$OUTPUT_FOLDER/total"

