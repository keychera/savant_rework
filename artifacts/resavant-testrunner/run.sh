#this run.sh is for development and example purposes, the commented out is what would probably used for later

source runconfig
mkdir -p $TEMP/
#java -cp "target/classes:$JUNITJAR:$HAMCRESTJAR:$TARGETCLASSESPATH:$TARGETTESTSPATH" resavant.testrunner.App $TESTCLASS $TESTMETHOD testrunner

#the steps

#step 1: run all tests, get all class
defects4j test -w $TARGETPROJECT
defects4j info -p Lang -b 1
python scripts/get_all_test_methods.py $TARGETPROJECT/all_tests "$TEMP/all_test_methods"

#step 2: read the 'failing_tests'
cp $TARGETPROJECT/failing_tests $TEMP/failing_tests_report
python scripts/get_failing_test_methods.py $TEMP/failing_tests_report "$TEMP/failing_test_methods"

#step 3: get all classes
python scripts/get_java_classes_from_directory.py "$TARGETPROJECT/$(defects4j export -w "$TARGETPROJECT" -p dir.src.classes)" "$TEMP/all_classes"

#step4+5+6 instrument all classes and run coverage of the failed test
FILE=$TEMP/failing_test_methods
COVERED_OUT=$TEMP/covered_methods
mkdir -p $COVERED_OUT
while read TEST_METHOD
do
    echo $TEST_METHOD
    defects4j coverage -w $TARGETPROJECT -t $TEST_METHOD -i $TEMP/all_classes    
    python scripts/get_methods_coverage.py $TARGETPROJECT/coverage.xml "$COVERED_OUT/covered_methods-$TEST_METHOD"
done < $FILE
python scripts/aggregate_results.py $COVERED_OUT/ "$TEMP/aggregate_covered_methods"

#step7 get all covered classes
python scripts/get_classes_coverage.py $TEMP/aggregate_covered_methods $TEMP/covered_classes
#step 7.5 get all tests and then the passing tests
python scripts/get_passing_test_methods.py $TEMP/all_test_methods $TEMP/failing_test_methods $TEMP/passing_test_methods

#step8+9 coverage with instrumentation only the covered classes
FILE=$TEMP/passing_test_methods
PASSING_CVR=$TEMP/passing_coverage
mkdir -p $PASSING_CVR
while read TEST_METHOD
do
    echo $TEST_METHOD
    defects4j coverage -w $TARGETPROJECT -t $TEST_METHOD -i $TEMP/covered_classes
    python scripts/get_methods_coverage.py $TARGETPROJECT/coverage.xml "$PASSING_CVR/covered_classes-$TEST_METHOD"
done < $FILE
# build method x passing test matrix

