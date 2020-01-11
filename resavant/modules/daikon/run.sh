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
JAVA7_PATH="/usr/java/jdk1.7.0_80/jre/bin/java"
JAVAC7_PATH="/usr/java/jdk1.7.0_80/bin/javac"
TARGETPROJECT="/home/square/Documents/projects/savant_rework/resavant/temp/0-checkout/Lang/1/b"
TESTS_TO_RUN="/home/square/Documents/projects/savant_rework/resavant/modules/daikon/testlist"
OUTPUT_DIR="$(dirname "$0")/temp"
mkdir -p $OUTPUT_DIR

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

# prepare classpath and means to call TestRunner
CLS_DIR=$(defects4j export -p dir.bin.classes -w $TARGETPROJECT)
TEST_DIR=$(defects4j export -p dir.bin.tests -w $TARGETPROJECT)

CLASS_PATHS="$TARGETPROJECT/$CLS_DIR:$TARGETPROJECT/$TEST_DIR:$LIB_FOLDER:$TEST_RUNNER_DIR"
TEST_RUNNER="$JAVA7_PATH -cp $CLASS_PATHS TestRunner"

echo "command that will be called: $TEST_RUNNER"
echo ""

# should fail
$TEST_RUNNER single org.apache.commons.lang3.math.NumberUtilsTest::TestLang747

# should pass
$TEST_RUNNER single org.apache.commons.lang3.AnnotationUtilsTest::testBothArgsNull

# should pass
$TEST_RUNNER single org.apache.commons.lang3.LocaleUtilsTest::testParseAllLocales

# multiple test in one run
$TEST_RUNNER multiple $TESTS_TO_RUN

TEST_RUNNER_CLASS="TestRunner"
DTRACE_FILE="$OUTPUT_DIR/test.dtrace.gz"
INV_FILE="$OUTPUT_DIR/test.inv.gz"
PRINT_INV_FILE="$OUTPUT_DIR/test-inv"
$JAVA7_PATH -cp $CLASS_PATHS:$DAIKON_JAR daikon.Chicory --ppt-select-pattern="org.apache.commons.lang3" --dtrace-file=$DTRACE_FILE $TEST_RUNNER_CLASS multiple $TESTS_TO_RUN >/dev/null 2>&1

$JAVA7_PATH -cp $CLASS_PATHS:$DAIKON_JAR daikon.Daikon $DTRACE_FILE -o $INV_FILE >/dev/null 2>&1

$JAVA7_PATH -cp $CLASS_PATHS:$DAIKON_JAR daikon.PrintInvariants $INV_FILE > $PRINT_INV_FILE
