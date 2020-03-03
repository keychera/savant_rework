
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
    2) ./resavant/run_savant_train.sh -i "./temp_data/6-l2r-data" -o "./temp_model" ;;

    # run_savant_predict
    3) ./resavant/run_savant_predict.sh -i "./temp_data/6-l2r-data/l2rdata.Lang.1" -m "./temp_model/model" -o "./temp_out" ;;

    # else
    *) echo "There is no scenario \"$SCENARIO\"" ;;
esac


