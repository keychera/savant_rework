# process args
w_flag=''
b_flag=''
o_flag=''
TARGET_PROJECT=''
BUGINFO_FOLDER=''
OUTPUT_FOLDER=''

print_usage() {
  printf "Usage: ..."
}

while getopts 'w:o:' flag; do
  case "${flag}" in
    w) TARGET_PROJECT="${OPTARG}" ;;
    o) OUTPUT_FOLDER="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

# run clover coverage
git --git-dir=$TARGET_PROJECT/.git/ --work-tree=$TARGET_PROJECT clean -f -d
$(dirname "$0")/run_clover_coverage.pl -w "$TARGET_PROJECT"

$JAVA8 -Dfile.encoding=UTF-8 -cp $SCRIPTS_JAVA_JAR resavant.utils.SavantCloverDBExtractor "$TARGET_PROJECT/.clover/clover4_4_1.db" $OUTPUT_FOLDER
