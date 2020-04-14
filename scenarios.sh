
# process args
print_usage() {
  printf "Usage: ..."
}

OUT="./temp_all"

while getopts 's:o:' flag; do
  case "${flag}" in
    s) SCENARIO="${OPTARG}" ;;
    o) OUT="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

# OUT is from the input, default is temp_all
mkdir -p $OUT

cross_val() {
  features=$1
  out=$2

  iter_out="$out/iterations"
  mkdir -p $iter_out
  # the crossval
  # iterate all n file inside all_data
  i=0
  FILES="$features/*"
  for f in $FILES
  do
    # prepare the cross_val iteration folder
    current_folder="$iter_out/$i"
    mkdir -p $current_folder

    # move the iterated file to test folder, leaving n-1 files
    file_name="$(basename $f)_testdata"
    mv $f "$current_folder/$file_name"

    # train with all_data
    ./resavant/run_savant_train.sh -i "$features" -o "$current_folder/model"

    # test the file in test folder
    ./resavant/run_savant_predict.sh -i "$current_folder/$file_name" -m "$current_folder/model/model" -o "$current_folder/out"

    # copy back the iterated file to all_data
    cp "$current_folder/$file_name" $f

    ((i++))
  done

}

case $SCENARIO in
    # run_savant_build_data
    1) ./resavant/run_savant_build_data.sh -b "./resavant/bug.input.example" -o "$OUT/temp_data" ;;
    
    # run_savant_train
    2) ./resavant/run_savant_train.sh -i "$OUT/temp_data/6-l2r-data" -o "$OUT/temp_model" ;;

    # run_savant_predict
    3) ./resavant/run_savant_predict.sh -i "$OUT/temp_data/6-l2r-data/l2rdata.Lang.1" -m "$OUT/temp_model/model" -o "$OUT/temp_out" ;;

    # small training dataset scenario
    4)
      SMALL_OUT="$OUT/S"
      mkdir -p $SMALL_OUT
      # training
      ./resavant/run_savant_build_data.sh -b "./scenarios_input/bug.input.S_train" -o "$SMALL_OUT/S_data"
      ./resavant/run_savant_train.sh -i "$SMALL_OUT/S_data/6-l2r-data" -o "$SMALL_OUT/S_model"

      # testing   
      ./resavant/run_savant_build_data.sh -b "./scenarios_input/bug.input.a_test" -o "$SMALL_OUT/S_test"
      ./resavant/run_savant_predict.sh -i "$SMALL_OUT/S_test/6-l2r-data/l2rdata.Chart.1" -m "$SMALL_OUT/S_model/model" -o "$SMALL_OUT/S_out"
    ;;

    # Chart cross val
    5)
      input_data="./scenarios_input/bug.input.train_Chart"
      cross_val_out="$OUT/cross_val_Chart"

      # build all data
      all_data_out="$cross_val_out/all_data"
      ./resavant/run_savant_build_data.sh -b $input_data -o $all_data_out

      # cross train and predict
      cross_val "$all_data_out/6-l2r-data" "$cross_val_out"

      # the evaluation
      eval_out="$cross_val_out/eval"
      mkdir -p $eval_out
      iter_out="$cross_val_out/iterations"

      evaluator/run_evaluation.sh -i $iter_out -o $eval_out
    ;;

    # else
    *) echo "There is no scenario \"$SCENARIO\"" ;;
esac
