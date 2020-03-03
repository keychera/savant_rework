
# process args
print_usage() {
  printf "Usage: ..."
}

while getopts 's:' flag; do
  case "${flag}" in
    s) SCENARIO="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

case $SCENARIO in
    # run_savant_build_data
    1) ./resavant/run_savant_build_data.sh -b "./resavant/bug.input.example" -o "./temp_data" ;;
    
    # run_savant_train
    2) ./resavant/run_savant_train.sh -i "./temp_data/6-l2r-data" -o "./temp_res" ;;

    # run_else
    *) echo "not done" ;;
esac


