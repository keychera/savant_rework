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
$(dirname "$0")/run_test_coverage.pl -w $TARGET_PROJECT -t "$BUGINFO_FOLDER/failing_tests" -i "$BUGINFO_FOLDER/all_classes" -o "$CVR_OUTPUT_FOLDER"

# get covered methods for each cvr results (failing tests cvr)
MTD_OUTPUT_FOLDER="$OUTPUT_FOLDER/all_methods_coverage_folder"
mkdir -p $MTD_OUTPUT_FOLDER

counter=0
number_of_out=$(find $CVR_OUTPUT_FOLDER/* -maxdepth 0 -type d | wc -l)
while [ $counter -le `expr $number_of_out - 1` ]
do
    cvr_folder="$CVR_OUTPUT_FOLDER/$counter/cobertura"
    $PY_COMMAND $SCRIPTS_PY/get_methods_coverage.py $cvr_folder/coverage.xml "$cvr_folder/methods_coverage"
    cp "$cvr_folder/methods_coverage" "$MTD_OUTPUT_FOLDER/methods_coverage-$counter"
    ((counter++))
done

$PY_COMMAND $SCRIPTS_PY/aggregate_results.py $MTD_OUTPUT_FOLDER/ "$OUTPUT_FOLDER/all_methods_coverage"

# get all covered classes by failing tests
$PY_COMMAND $SCRIPTS_PY/get_classes_coverage.py "$OUTPUT_FOLDER/all_methods_coverage" "$OUTPUT_FOLDER/all_classes_coverage"

# get coverage of passing tests with covered classes by failing tests instrumented
PASS_OUTPUT_FOLDER="$OUTPUT_FOLDER/passing_test_coverage_folder"
mkdir -p $PASS_OUTPUT_FOLDER
$(dirname "$0")/run_test_coverage.pl -w $TARGET_PROJECT -t "$BUGINFO_FOLDER/passing_tests" -i "$OUTPUT_FOLDER/all_classes_coverage" -o "$PASS_OUTPUT_FOLDER"

# get covered method for each cvr results (passing tests cvr)
counter=0
number_of_out=$(find $PASS_OUTPUT_FOLDER/* -maxdepth 0 -type d | wc -l)
while [ $counter -le `expr $number_of_out - 1` ]
do
    cvr_folder="$PASS_OUTPUT_FOLDER/$counter/cobertura"
    $PY_COMMAND $SCRIPTS_PY/get_methods_coverage.py $cvr_folder/coverage.xml "$cvr_folder/methods_coverage"
    ((counter++))
done

# generate method/test matrix
$PY_COMMAND $SCRIPTS_PY/generate_method_and_test_matrix.py "$PASS_OUTPUT_FOLDER/" "$OUTPUT_FOLDER/all_methods_coverage" "$OUTPUT_FOLDER/passing_tests" "$OUTPUT_FOLDER/res.csv"

$PY_COMMAND $SCRIPTS_PY/generate_method_and_test_matrix.py "$CVR_OUTPUT_FOLDER/" "$OUTPUT_FOLDER/all_methods_coverage" "$OUTPUT_FOLDER/failing_tests" "$OUTPUT_FOLDER/res_fail.csv"
