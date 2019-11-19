#this run.sh is for development and example purposes, the commented out is what would probably used for later

source runconfig
#java -cp "target/classes:$JUNITJAR:$HAMCRESTJAR:$TARGETCLASSESPATH:$TARGETTESTSPATH" resavant.testrunner.App $TESTCLASS $TESTMETHOD testrunner

#the steps

#step 1:
defects4j test -w $TARGETPROJECT

#step 2: read the 'failing_tests'
cp $TARGETPROJECT/failing_tests ./failing_tests_report
python scripts/get_failing_tests.py ./failing_tests_report .

#step 3
defects4j export -w "$TARGETPROJECT" -p dir.src.classes
python scripts/get_java_classes_from_directory.py $TARGETPROJECT/src/main/java .

#step4+5 instrument all classes and run coverage of the failed test
defects4j coverage -w $TARGETPROJECT -t $TESTCLASS::$TESTMETHOD -i all_classes
python scripts/get_methods_coverage.py $TARGETPROJECT/coverage.xml .