# process args
w_flag=''
b_flag=''
o_flag=''
TARGET_PROJECT=''
BUGINFO_FOLDER=''
OUTPUT_FOLDER=''

print_usage() {
  printf "Usage: ..."
}

while getopts 'w:b:o:' flag; do
  case "${flag}" in
    w) TARGET_PROJECT="${OPTARG}" ;;
    b) BUGINFO_FOLDER="${OPTARG}" ;;
    o) OUTPUT_FOLDER="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

# get coverage for all failing tests
CVR_OUTPUT_FOLDER="$OUTPUT_FOLDER/failing_test_coverage_folder"
mkdir -p $CVR_OUTPUT_FOLDER

input="$BUGINFO_FOLDER/failing_tests"
counter=0
while IFS= read -r line
do
  echo "$counter : $line"
  git --git-dir=$TARGET_PROJECT/.git/ --work-tree=$TARGET_PROJECT clean -f -d
  $(dirname "$0")/run_clover_coverage.pl -w "$TARGET_PROJECT" -t "$line" -o "$CVR_OUTPUT_FOLDER/clover-cvr-$counter.xml"
  ((counter++))
done < "$input"

# get coverage of all passing tests
PASS_OUTPUT_FOLDER="$OUTPUT_FOLDER/passing_test_coverage_folder"
mkdir -p $PASS_OUTPUT_FOLDER

input="$BUGINFO_FOLDER/passing_tests"
counter=0
while IFS= read -r line
do
  echo "$counter : $line"
  git --git-dir=$TARGET_PROJECT/.git/ --work-tree=$TARGET_PROJECT clean -f -d
  $(dirname "$0")/run_clover_coverage.pl -w "$TARGET_PROJECT" -t "$line" -o "$PASS_OUTPUT_FOLDER/clover-cvr-$counter.xml"
  ((counter++))
done < "$input"

# generate method/test matrix
# $PY_COMMAND $SCRIPTS_PY/generate_method_and_test_matrix.py "$PASS_OUTPUT_FOLDER/" "$OUTPUT_FOLDER/all_methods_coverage" "$OUTPUT_FOLDER/passing_tests" "$OUTPUT_FOLDER/res.csv"

# $PY_COMMAND $SCRIPTS_PY/generate_method_and_test_matrix.py "$CVR_OUTPUT_FOLDER/" "$OUTPUT_FOLDER/all_methods_coverage" "$OUTPUT_FOLDER/failing_tests" "$OUTPUT_FOLDER/res_fail.csv"
