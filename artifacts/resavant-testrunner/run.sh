#this run.sh is for development and example purposes, the commented out is what would probably used for later

source runconfig
#java -cp "target/classes:$JUNITJAR:$HAMCRESTJAR:$TARGETCLASSESPATH:$TARGETTESTSPATH" resavant.testrunner.App $TESTCLASS $TESTMETHOD testrunner

#the steps

#step 1: run all tests, get all class
#defects4j test -w $TARGETPROJECT
#defects4j info -p Lang -b 1
#python scripts/get_all_test_methods.py $TARGETPROJECT/all_tests $TEMP/

#step 2: read the 'failing_tests'
#cp $TARGETPROJECT/failing_tests $TEMP/failing_tests_report
python scripts/get_failing_test_methods.py $TEMP/failing_tests_report $TEMP/

#step 3: get all classes
python scripts/get_java_classes_from_directory.py "$TARGETPROJECT/$(defects4j export -w "$TARGETPROJECT" -p dir.src.classes)" $TEMP/

#step4+5+6 instrument all classes and run coverage of the failed test
FILE=$TEMP/failing_test_methods
while read LINE
do
    echo $LINE
    defects4j coverage -w $TARGETPROJECT -t $LINE -i $TEMP/all_classes
    python scripts/get_methods_coverage.py $TARGETPROJECT/coverage.xml $TEMP/ $LINE
    #TODO aggregate the report
done < $FILE

#step7 get all covered classes
#python scripts/get_classes_coverage.py ./covered_methods .

#step8+9 coverage with instrumentation only the covered classes
#defects4j coverage -w $TARGETPROJECT -t $TESTCLASS::$TESTMETHOD -i covered_classes

#step 9.5 get all tests and then the passing tests
#python scripts/get_all_test_methods.py $TARGETPROJECT/all_tests .
#python scripts/get_passing_test_methods.py ./all_test_methods ./failing_test_methods .
