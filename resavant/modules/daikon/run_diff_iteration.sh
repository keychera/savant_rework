# process args
print_usage() {
  printf "Usage: ..."
}

while getopts 'd:o:' flag; do
  case "${flag}" in
    d) DAIKON_RESULT_DIR="${OPTARG}" ;;
    o) OUTPUT_DIR="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

mkdir -p $OUTPUT_DIR

# iterate all cluster
counter=0
num_result=$(find $DAIKON_RESULT_DIR/* -maxdepth 0 -type d | wc -l)
while [ $counter -lt `expr $num_result` ]
do
  CURRENT_RES_DIR="$DAIKON_RESULT_DIR/$counter"
  FAILING="$CURRENT_RES_DIR/failing.inv.gz"
  SELECTED="$CURRENT_RES_DIR/selected.inv.gz"
  FAILING_SELECTED="$CURRENT_RES_DIR/failing_selected.inv.gz"

  # diff failing x selected
  $JAVA8 -cp $SCRIPTS_JAVA_JAR resavant.utils.daikon.diff.SimplifiedDiff $FAILING $SELECTED -o "$OUTPUT_DIR/failing_x_selected"

  # diff failing x failing+selected
  $JAVA8 -cp $SCRIPTS_JAVA_JAR resavant.utils.daikon.diff.SimplifiedDiff $FAILING $FAILING_SELECTED -o "$OUTPUT_DIR/failing_x_failing_selected"

  # diff selected x failing_selected
  $JAVA8 -cp $SCRIPTS_JAVA_JAR resavant.utils.daikon.diff.SimplifiedDiff $SELECTED $FAILING_SELECTED -o "$OUTPUT_DIR/selected_x_failing_selected"

  ((counter++))
done