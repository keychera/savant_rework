
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

OUT="temp_all"
mkdir -p $OUT

case $SCENARIO in
    # run_savant_build_data
    1) ./resavant/run_savant_build_data.sh -b "./resavant/bug.input.example" -o "./$OUT/temp_data" ;;
    
    # run_savant_train
    2) ./resavant/run_savant_train.sh -i "./$OUT/temp_data/6-l2r-data" -o "./$OUT/temp_model" ;;

    # run_savant_predict
    3) ./resavant/run_savant_predict.sh -i "./$OUT/temp_data/6-l2r-data/l2rdata.Lang.1" -m "./$OUT/temp_model/model" -o "./$OUT/temp_out" ;;

    # small training dataset scenario
    4)
      # training
      ./resavant/run_savant_build_data.sh -b "./scenarios_input/bug.input.S_train" -o "./$OUT/S_data"
      ./resavant/run_savant_train.sh -i "./$OUT/S_data/6-l2r-data" -o "./$OUT/S_model"

      # testing   
      ./resavant/run_savant_build_data.sh -b "./scenarios_input/bug.input.a_test" -o "./$OUT/S_test"
      ./resavant/run_savant_predict.sh -i "./$OUT/S_test/6-l2r-data/l2rdata.Chart.1" -m "./$OUT/S_model/model" -o "./$OUT/S_out"
    ;;

    # else
    *) echo "There is no scenario \"$SCENARIO\"" ;;
esac
