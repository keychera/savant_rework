# check daikon
if [ -z "$DAIKONDIR" ]
then
    echo 'Error: Daikon is either not installed' >&2
    echo 'or the $DAIKONDIR to is not set!' >&2
    exit 1
else
    DAIKON_JAR="$DAIKONDIR/daikon.jar"
fi

# temp
source $(dirname "$0")/runconfig

# compile testrunners
CLASSES_TO_CMPL=$(find $(dirname "$0")/TestRunner/src/ -name "*.java")
LIB_FOLDER="$(dirname "$0")/TestRunner/lib/*"
TEST_RUNNER_DIR="$(dirname "$0")/TestRunner/target"
mkdir -p $TEST_RUNNER_DIR
$JAVAC7_PATH -g -cp "$LIB_FOLDER" -d $TEST_RUNNER_DIR $CLASSES_TO_CMPL

# compile target project
CUR_DIR=$(pwd)
cd $TARGETPROJECT
git clean -fd
defects4j compile
cd $CUR_DIR

# prepare classpath and means to call SingleTestRunner
CLS_DIR=$(defects4j export -p dir.bin.classes -w $TARGETPROJECT)
TEST_DIR=$(defects4j export -p dir.bin.tests -w $TARGETPROJECT)

CLASS_PATHS="$TARGETPROJECT/$CLS_DIR:$TARGETPROJECT/$TEST_DIR:$LIB_FOLDER:$TEST_RUNNER_DIR"
SINGLETESTRUN="$JAVA7_PATH -cp $CLASS_PATHS SingleTestRunner"

echo "command that will be called: $SINGLETESTRUN"
echo ""

# should fail
$SINGLETESTRUN org.apache.commons.lang3.math.NumberUtilsTest::TestLang747

# should pass
$SINGLETESTRUN org.apache.commons.lang3.AnnotationUtilsTest::testBothArgsNull

# should pass
$SINGLETESTRUN org.apache.commons.lang3.LocaleUtilsTest::testParseAllLocales

TEST_RUNNER="SingleTestRunner"
TEST_TO_RUN="org.apache.commons.lang3.LocaleUtilsTest::testParseAllLocales"

echo "testing $TEST_TO_RUN"

DTRACE_FILE="test.dtrace.gz"
$JAVA7_PATH -cp $CLASS_PATHS:$DAIKON_JAR daikon.Chicory --ppt-select-pattern="org.apache.commons.lang3" --dtrace-file=$DTRACE_FILE $TEST_RUNNER $TEST_TO_RUN >/dev/null 2>&1

$JAVA7_PATH -cp $CLASS_PATHS:$DAIKON_JAR daikon.Daikon $DTRACE_FILE
