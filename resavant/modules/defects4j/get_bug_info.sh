# process args
w_flag=''
o_flag=''
TARGET_PROJECT=''
OUTPUT_FOLDER=''

print_usage() {
  printf "Usage: ..."
}

while getopts 'w:o:' flag; do
  case "${flag}" in
    w) TARGET_PROJECT="${OPTARG}" ;;
    o) OUTPUT_FOLDER="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

# get src.classes
defects4j export -w "$TARGET_PROJECT" -p dir.src.classes -o "$OUTPUT_FOLDER/dir.src.classes"

# get src.tests
defects4j export -w "$TARGET_PROJECT" -p dir.src.tests -o "$OUTPUT_FOLDER/dir.src.tests"

# get all tests
git --git-dir=$TARGET_PROJECT/.git/ --work-tree=$TARGET_PROJECT clean -f -d
defects4j test -w $TARGET_PROJECT
$PY_COMMAND $SCRIPTS_PY/get_all_tests.py $TARGET_PROJECT/all_tests "$OUTPUT_FOLDER/all_tests"

# read the 'failing_tests'
cp "$TARGET_PROJECT/failing_tests" "$OUTPUT_FOLDER/failing_tests_log"
$PY_COMMAND $SCRIPTS_PY/get_failing_tests.py "$OUTPUT_FOLDER/failing_tests_log" "$OUTPUT_FOLDER/failing_tests"

# get all classes
$PY_COMMAND $SCRIPTS_PY/get_java_classes_from_directory.py "$TARGET_PROJECT/$(echo $(<$OUTPUT_FOLDER/dir.src.classes))" "$OUTPUT_FOLDER/all_classes"

# get passing tests
$PY_COMMAND $SCRIPTS_PY/get_passing_tests.py "$OUTPUT_FOLDER/all_tests" "$OUTPUT_FOLDER/failing_tests" "$OUTPUT_FOLDER/passing_tests"
