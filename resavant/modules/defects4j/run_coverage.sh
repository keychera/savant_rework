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
CVR_OUTPUT_FOLDER="$OUTPUT_FOLDER/failing_test_coverage"
mkdir -p $CVR_OUTPUT_FOLDER
echo "hey $TARGET_PROJECT"
$(dirname "$0")/run_test_coverage.pl -w $TARGET_PROJECT -t "$BUGINFO_FOLDER/failing_tests" -i "$BUGINFO_FOLDER/all_classes" -o "$CVR_OUTPUT_FOLDER"

counter=0
number_of_out=$(find $CVR_OUTPUT_FOLDER/* -maxdepth 0 -type d | wc -l)
while [ $counter -le `expr $number_of_out - 1` ]
do
    cvr_folder="$CVR_OUTPUT_FOLDER/$counter/cobertura"
    $PY_COMMAND $SCRIPTS_PY/get_methods_coverage.py $cvr_folder/coverage.xml "$cvr_folder/covered_methods"
    ((counter++))
done
# $PY_COMMAND $SCRIPTS_PY/aggregate_results.py $MTD_OUTPUT_FOLDER/ "$OUTPUT_FOLDER/all_covered_methods"

# step 7 get all covered classes
# $PY_COMMAND $SCRIPTS_PY/get_classes_coverage.py "$OUTPUT_FOLDER/all_covered_methods" "$OUTPUT_FOLDER/all_covered_classes"
