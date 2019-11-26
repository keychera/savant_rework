
source runconfig
mkdir -p $TEMP/

# step 1: get all tests, get all class
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
./get_method_coverage.pl -w $TARGETPROJECT -t "$TEMP/failing_tests" -i "$TEMP/all_test_classes" -o $TEMP
