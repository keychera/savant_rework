
source runconfig

# check daikon
if [ -z "$DAIKONDIR" ]
then
    echo 'Error: Daikon is either not installed' >&2
    echo 'or the $DAIKONDIR to is not set!' >&2
    exit 1
else
    DAIKON_JAR="$DAIKONDIR/daikon.jar"
fi

# compile target project
CUR_DIR=$(pwd)
cd $TARGETPROJECT
defects4j compile
cd $CUR_DIR

CLASSES_TO_CMPL=$(find ./src/ -name "*.java")
mkdir -p target
$JAVAC7_PATH -g -cp "$LIB_FOLDER" -d "./target/" $CLASSES_TO_CMPL

CLS_DIR=$(defects4j export -p dir.bin.classes -w $TARGETPROJECT)
TEST_DIR=$(defects4j export -p dir.bin.tests -w $TARGETPROJECT)

CLASS_PATHS="$TARGETPROJECT/$CLS_DIR:$TARGETPROJECT/$TEST_DIR:$LIB_FOLDER:./target"
SINGLETESTRUN="$JAVA7_PATH -cp $CLASS_PATHS SingleTestRunner"

#should fail
$SINGLETESTRUN org.apache.commons.lang3.math.NumberUtilsTest::TestLang747

#should pass
$SINGLETESTRUN org.apache.commons.lang3.AnnotationUtilsTest::testBothArgsNull

#should pass
$SINGLETESTRUN org.apache.commons.lang3.LocaleUtilsTest::testParseAllLocales

TEST_RUNNER="SingleTestRunner"
TEST_TO_RUN="org.apache.commons.lang3.math.NumberUtilsTest::TestLang747"

$JAVA7_PATH -cp $CLASS_PATHS:$DAIKON_JAR daikon.DynComp  $TEST_RUNNER $TEST_TO_RUN

$JAVA7_PATH -cp $CLASS_PATHS:$DAIKON_JAR daikon.Chicory --daikon --comparability-file=$TEST_RUNNER.decls-DynComp --ppt-select-pattern="org.apache.commons.lang3" $TEST_RUNNER $TEST_TO_RUN
