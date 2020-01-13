# check daikon
if [ -z "$DAIKONDIR" ]
then
    echo 'Error: Daikon is either not installed' >&2
    echo 'or the $DAIKONDIR to is not set!' >&2
    exit 1
else
    DAIKON_JAR="$DAIKONDIR/daikon.jar"
fi

# process args
print_usage() {
  printf "Usage: ..."
}

while getopts 't:d:o:' flag; do
  case "${flag}" in
    t) TARGET_PROJECT="${OPTARG}" ;;
    d) DAIKON_DATA_DIR="${OPTARG}" ;;
    o) OUTPUT_DIR="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

# temp
JAVA7_PATH="/usr/java/jdk1.7.0_80/jre/bin/java"
JAVAC7_PATH="/usr/java/jdk1.7.0_80/bin/javac"
mkdir -p $OUTPUT_DIR

# compile testrunners
CLASSES_TO_CMPL=$(find $(dirname "$0")/TestRunner/src/ -name "*.java")
LIB_FOLDER="$(dirname "$0")/TestRunner/lib/*"
TEST_RUNNER_DIR="$(dirname "$0")/TestRunner/target"
mkdir -p $TEST_RUNNER_DIR
$JAVAC7_PATH -g -cp "$LIB_FOLDER" -d $TEST_RUNNER_DIR $CLASSES_TO_CMPL

# prepare classpath and means to call TestRunner
CLS_DIR=$(defects4j export -p dir.bin.classes -w $TARGET_PROJECT)
TEST_DIR=$(defects4j export -p dir.bin.tests -w $TARGET_PROJECT)
CLASS_PATHS="$TARGET_PROJECT/$CLS_DIR:$TARGET_PROJECT/$TEST_DIR:$LIB_FOLDER:$TEST_RUNNER_DIR"
TEST_RUNNER_CLASS="TestRunner"

# iterate cluster and process 3 sets of tests
CLUSTERS_DIR="$DAIKON_DATA_DIR/clusters_dir"

run_daikon() {
  PHASE_NAME=$1
  DTRACE_FILE="$CURRENT_OUT_DIR/$PHASE_NAME.dtrace.gz"
  INV_FILE="$CURRENT_OUT_DIR/$PHASE_NAME.inv.gz"
  PRINT_INV_FILE="$CURRENT_OUT_DIR/$PHASE_NAME-inv"

  $JAVA7_PATH -cp $CLASS_PATHS:$DAIKON_JAR daikon.Chicory --ppt-select-pattern=$SELECT_PATTERN --dtrace-file=$DTRACE_FILE $TEST_RUNNER_CLASS multiple $TESTS_TO_RUN >/dev/null 2>&1

  $JAVA7_PATH -cp $CLASS_PATHS:$DAIKON_JAR daikon.Daikon $DTRACE_FILE -o $INV_FILE >/dev/null 2>&1

  if test -f "$INV_FILE"; then
    $JAVA7_PATH -cp $CLASS_PATHS:$DAIKON_JAR daikon.PrintInvariants $INV_FILE > $PRINT_INV_FILE
  else
    echo "no invariant inferred for $PHASE_NAME"
  fi
}

counter=0
num_cluster=$(find $CLUSTERS_DIR/* -maxdepth 0 -type d | wc -l)
while [ $counter -lt `expr $num_cluster` ]
do
    echo "processing cluster number: $counter"
    CURRENT_OUT_DIR="$OUTPUT_DIR/$counter"
    mkdir -p $CURRENT_OUT_DIR

    # get method pattern
    METHOD_LIST="$CLUSTERS_DIR/$counter/cluster"
    SELECT_PATTERN="$(python $(dirname "$0")/build_method_pattern.py --method_list $METHOD_LIST)"

    # process all failing tests
    TESTS_TO_RUN="$CLUSTERS_DIR/failing_tests"
    run_daikon "failing"

    # process selected tests
    TESTS_TO_RUN="$CLUSTERS_DIR/$counter/selected_tests"
    run_daikon "selected"

    # process failing U selected tests
    echo "not yet implemented"

    ((counter++))
done
