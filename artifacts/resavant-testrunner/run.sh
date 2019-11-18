source runconfig
java -cp "target/classes:$JUNITJAR:$HAMCRESTJAR:$TARGETCLASSESPATH:$TARGETTESTSPATH" resavant.testrunner.App $TESTCLASS $TESTMETHOD testrunner
defects4j test -w "$TARGETPROJECT" -t "$TESTCLASS::$TESTMETHOD"
defects4j coverage -w "$TARGETPROJECT" -t "$TESTCLASS::$TESTMETHOD" -i instrument_classes
python scripts/get_methods_coverage.py $TARGETPROJECT