#this run.sh is for development and example purposes, the commented out is what would probably used for later

source runconfig
#java -cp "target/classes:$JUNITJAR:$HAMCRESTJAR:$TARGETCLASSESPATH:$TARGETTESTSPATH" resavant.testrunner.App $TESTCLASS $TESTMETHOD testrunner
#defects4j test -w "$TARGETPROJECT" -t "$TESTCLASS::$TESTMETHOD"
#defects4j coverage -w "$TARGETPROJECT" -t "$TESTCLASS::$TESTMETHOD" -i instrument_classes
python scripts/get_methods_coverage.py $TARGETPROJECT/coverage.xml

#the steps
#step 1:
#defects4j test -w "$TARGETPROJECT"
#step 2: read the 'failingtests'
#step 3

#defects4j export -w "$TARGETPROJECT" -p dir.src.classes
python scripts/get_java_classes_from_directory.py $TARGETPROJECT/src/main/java