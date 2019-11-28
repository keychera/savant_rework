
source runconfig

mkdir -p $TEMP/

# step 1: get all tests, get all class
git --git-dir=$TARGETPROJECT/.git/ --work-tree=$TARGETPROJECT clean -f -d
defects4j test -w $TARGETPROJECT
python $PYSCRIPT_PATH/get_all_test_methods.py $TARGETPROJECT/all_tests "$TEMP/all_tests"

    # if using export (but it only output the test classes)
    # defects4j export -w $TARGETPROJECT -p tests.all -o $TEMP/all_tests

# step 2: read the 'failing_tests'
cp $TARGETPROJECT/failing_tests $TEMP/failing_tests_report
python $PYSCRIPT_PATH/get_failing_test_methods.py $TEMP/failing_tests_report "$TEMP/failing_tests"

# step 3: get all classes
python $PYSCRIPT_PATH/get_java_classes_from_directory.py "$TARGETPROJECT/$(defects4j export -w "$TARGETPROJECT" -p dir.src.classes)" "$TEMP/all_classes"

# step 4-5: run and get coverage all failing tests
CVR_OUTPUT_FOLDER="$TEMP/single_test_coverage_out"
./run_single_test_coverage.pl -w $TARGETPROJECT -t "$TEMP/failing_tests" -i "$TEMP/all_classes" -o "$CVR_OUTPUT_FOLDER"

# step 6: get all methods run by the failing tests
MTD_OUTPUT_FOLDER="$TEMP/method_coverage_out"
mkdir -p $MTD_OUTPUT_FOLDER

counter=0
number_of_out=$(find $CVR_OUTPUT_FOLDER/* -maxdepth 0 -type d | wc -l)
while [ $counter -le `expr $number_of_out - 1` ]
do
    cvr_folder="$CVR_OUTPUT_FOLDER/$counter/cobertura"
    python $PYSCRIPT_PATH/get_methods_coverage.py $cvr_folder/coverage.xml "$MTD_OUTPUT_FOLDER/covered_methods-$counter"
    ((counter++))
done
python $PYSCRIPT_PATH/aggregate_results.py $MTD_OUTPUT_FOLDER/ "$TEMP/all_covered_methods"

# step 7 get all covered classes
python $PYSCRIPT_PATH/get_classes_coverage.py "$TEMP/all_covered_methods" "$TEMP/all_covered_classes"
# step 7.5 get all tests and then the passing tests
python $PYSCRIPT_PATH/get_passing_test_methods.py "$TEMP/all_tests" "$TEMP/failing_tests" "$TEMP/passing_tests"

# step 8-9 run coverage of passing tests with covered class instrumented
PASS_OUTPUT_FOLDER="$TEMP/passing_test_coverage_out"
./run_single_test_coverage.pl -w $TARGETPROJECT -t "$TEMP/passing_tests" -i "$TEMP/all_covered_classes" -o "$PASS_OUTPUT_FOLDER"

# step 9.5 get all method for each cvr results
counter=0
number_of_out=$(find $PASS_OUTPUT_FOLDER/* -maxdepth 0 -type d | wc -l)
while [ $counter -le `expr $number_of_out - 1` ]
do
    cvr_folder="$PASS_OUTPUT_FOLDER/$counter/cobertura"
    python $PYSCRIPT_PATH/get_methods_coverage.py $cvr_folder/coverage.xml "$cvr_folder/covered_methods"
    ((counter++))
done

# step 10-11 generate matrix
python $PYSCRIPT_PATH/generate_method_and_test_matrix.py "$PASS_OUTPUT_FOLDER/" "$TEMP/all_covered_methods" "$TEMP/passing_tests" "$TEMP/res.csv"
