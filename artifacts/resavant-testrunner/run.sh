#this run.sh is for development and example purposes, the commented out is what would probably used for later

source runconfig
#java -cp "target/classes:$JUNITJAR:$HAMCRESTJAR:$TARGETCLASSESPATH:$TARGETTESTSPATH" resavant.testrunner.App $TESTCLASS $TESTMETHOD testrunner

#the steps

#step 1:
#defects4j test -w $TARGETPROJECT

#step 2: read the 'failing_tests'
#cp $TARGETPROJECT/failing_tests ./failing_tests_report
#python scripts/get_failing_test_methods.py ./failing_tests_report .

#step 3

#python scripts/get_java_classes_from_directory.py "$TARGETPROJECT/$(defects4j export -w "$TARGETPROJECT" -p dir.src.classes)" .

#step4+5+6 instrument all classes and run coverage of the failed test
#defects4j coverage -w $TARGETPROJECT -t $TESTCLASS::$TESTMETHOD -i all_classes
#cripts/get_methods_coverage.py $TARGETPROJECT/coverage.xml .

#step7 get all classes
#python scripts/get_classes_coverage.py ./covered_methods .

#step8+9 coverage with instrumentation only the covered classes
#defects4j coverage -w $TARGETPROJECT -t $TESTCLASS::$TESTMETHOD -i covered_classes

#step 9.5 get all tests and then the passing tests
#defects4j export -w "$TARGETPROJECT" -p tests.all
python scripts/get_all_test_methods.py ./all_tests "$TARGETPROJECT/$(defects4j export -w "$TARGETPROJECT" -p dir.src.tests)" .
python scripts/get_passing_test_methods.py ./all_test_methods ./failing_test_methods
