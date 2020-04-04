
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

cross_val() {
  input_data=$1
  cross_val_out=$2

  # build all data
  all_data_out="$cross_val_out/all_data"
  ./resavant/run_savant_build_data.sh -b $input_data -o $all_data_out

  iter_out="$cross_val_out/iterations"
  mkdir -p $iter_out
  # the crossval
  # iterate all n file inside all_data
  i=0
  FILES="$all_data_out/6-l2r-data/*"
  for f in $FILES
  do
    # prepare the cross_val iteration folder
    current_folder="$iter_out/$i"
    mkdir -p $current_folder

    # move the iterated file to test folder, leaving n-1 files
    mv $f "$current_folder/test_data"

    # train with all_data
    ./resavant/run_savant_train.sh -i "$all_data_out/6-l2r-data" -o "$current_folder/model"

    # test the file in test folder
    ./resavant/run_savant_predict.sh -i "$current_folder/test_data" -m "$current_folder/model/model" -o "$current_folder/out"

    # copy back the iterated file to all_data
    cp "$current_folder/test_data" $f

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
      # training
      ./resavant/run_savant_build_data.sh -b "./scenarios_input/bug.input.S_train" -o "$OUT/S_data"
      ./resavant/run_savant_train.sh -i "$OUT/S_data/6-l2r-data" -o "$OUT/S_model"

      # testing   
      ./resavant/run_savant_build_data.sh -b "./scenarios_input/bug.input.a_test" -o "$OUT/S_test"
      ./resavant/run_savant_predict.sh -i "$OUT/S_test/6-l2r-data/l2rdata.Chart.1" -m "$OUT/S_model/model" -o "$OUT/S_out"
    ;;

    # small training (cross val n-1)
    5)
      cross_val "./scenarios_input/bug.input.S_train" "$OUT/cross_val"
      
      # the evaluation
      eval_out="$OUT/cross_val/eval"
      mkdir -p $eval_out

      evaluator/run_evaluation.sh -i $iter_out -o $eval_out
    ;;

    # large training (cross val n-1)
    6)
      cross_val "./scenarios_input/bug.input.L_train" "$OUT/cross_val"
      
      # the evaluation
      eval_out="$OUT/cross_val/eval"
      mkdir -p $eval_out

      evaluator/run_evaluation.sh -i $iter_out -o $eval_out
    ;;

    # cross val per project
    7)
      # Chart
        cross_val "./scenarios_input/bug.input.train_Chart" "$OUT/cross_val_Chart"

        # the evaluation
        eval_out="$OUT/cross_val_Chart/eval"
        mkdir -p $eval_out

        evaluator/run_evaluation.sh -i $iter_out -o $eval_out
      # Lang
        cross_val "./scenarios_input/bug.input.train_Lang" "$OUT/cross_val_Lang"

        # the evaluation
        eval_out="$OUT/cross_val_Lang/eval"
        mkdir -p $eval_out

        evaluator/run_evaluation.sh -i $iter_out -o $eval_out
    ;;

    # else
    *) echo "There is no scenario \"$SCENARIO\"" ;;
esac
