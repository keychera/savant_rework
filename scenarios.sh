
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

OUT="./temp_all"
mkdir -p $OUT

case $SCENARIO in
    # run_savant_build_data
    1) ./resavant/run_savant_build_data.sh -b "./resavant/bug.input.example" -o "$OUT/temp_data" ;;
    
    # run_savant_train
    2) ./resavant/run_savant_train.sh -i "$OUT/temp_data/6-l2r-data" -o "$OUT/temp_model" ;;

    # run_savant_predict
    3) ./resavant/run_savant_predict.sh -i "$OUT/temp_data/6-l2r-data/l2rdata.Lang.1" -m "$OUT/temp_model/model" -o "$OUT/temp_out" ;;

    # small training dataset scenario
    4)
      # training
      ./resavant/run_savant_build_data.sh -b "./scenarios_input/bug.input.S_train" -o "$OUT/S_data"
      ./resavant/run_savant_train.sh -i "$OUT/S_data/6-l2r-data" -o "$OUT/S_model"

      # testing   
      ./resavant/run_savant_build_data.sh -b "./scenarios_input/bug.input.a_test" -o "$OUT/S_test"
      ./resavant/run_savant_predict.sh -i "$OUT/S_test/6-l2r-data/l2rdata.Chart.1" -m "$OUT/S_model/model" -o "$OUT/S_out"
    ;;

    # large training (cross val n-1)
    5)
      cross_val_out="$OUT/cross_val"
      all_data_out="$cross_val_out/all_data"
      # build all data
      ./resavant/run_savant_build_data.sh -b "./scenarios_input/bug.input.L_train" -o $all_data_out

      iter_out="$cross_val_out/iterations"
      mkdir -p $iter_out
      # the crossval
      # iterate all n file inside all_data
      i=0
      FILES="$all_data_out/6-l2r-data/*"
      for f in $FILES
      do
        # prepare the cross_val iteration folder
        iter_folder="$iter_out/$i"
        mkdir -p $iter_folder

        # move the iterated file to test folder, leaving n-1 files
        mv $f "$iter_folder/test_data"

        # train with all_data
        ./resavant/run_savant_train.sh -i "$all_data_out/6-l2r-data" -o "$iter_folder/model"

        # test the file in test folder
        ./resavant/run_savant_predict.sh -i "$iter_folder/test_data" -m "$iter_folder/model/model" -o "$iter_folder/out"

        # copy back the iterated file to all_data
        cp "$iter_folder/test_data" $f

        ((i++))
      done
    ;;


    # else
    *) echo "There is no scenario \"$SCENARIO\"" ;;
esac
