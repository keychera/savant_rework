# check prereq
. $(dirname "$0")/run.config
. $(dirname "$0")/modules.structure
. $(dirname "$0")/check_py.sh

# process args
print_usage() {
  printf "Usage: -p proj_id -b bug_id -s #_step -o out_folder\n"
}

OUT="./temp_all"

while getopts 'p:b:s:o:' flag; do
  case "${flag}" in
    p) proj_id="${OPTARG}" ;;
    b) bug_id="${OPTARG}" ;;
    s) step="${OPTARG}" ;;
    o) out_folder="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done
OUT="$out_folder/steps.$proj_id.$bug_id"
mkdir -p $OUT
T=10
M=10

case $step in
    step1)
      # checkout buggy and fixed version
      CHECKOUT_FOLDER="$OUT/0-checkout_${proj_id}_${bug_id}"
      mkdir -p "$CHECKOUT_FOLDER"

      defects4j checkout -p "$proj_id" -v "${bug_id}b" -w "${CHECKOUT_FOLDER}/b"
      defects4j checkout -p "$proj_id" -v "${bug_id}f" -w "${CHECKOUT_FOLDER}/f"
      
    ;;

    step2)
      # ground truth
      CHECKOUT_FOLDER="$OUT/0-checkout_${proj_id}_${bug_id}"
      GROUND_TRUTH_FOLDER="$OUT/1-ground-truth_${proj_id}_${bug_id}"
      mkdir -p $GROUND_TRUTH_FOLDER
      
      $DEFECTS4J_MODULE/extract_ground_truths.pl -p "$proj_id" -v "${bug_id}b" -w "${CHECKOUT_FOLDER}" -o "$GROUND_TRUTH_FOLDER" # -w must refer to already checkout-ed src, b and f, error not yet handled TODO wrap the checkout process
    ;;

    step3)
      # coverage
      CHECKOUT_FOLDER="$OUT/0-checkout_${proj_id}_${bug_id}"
      CVR_FOLDER="$OUT/2-coverage_${proj_id}_${bug_id}"
      mkdir -p $CVR_FOLDER

      $DEFECTS4J_MODULE/run_coverage.sh -w "${CHECKOUT_FOLDER}/b" -o "$CVR_FOLDER"
    ;;

    step4)
      # method clustering and test case selection
      CVR_FOLDER="$OUT/2-coverage_${proj_id}_${bug_id}"
      CLUSTER_FOLDER="$OUT/3-cluster_${proj_id}_${bug_id}"
      mkdir -p $CLUSTER_FOLDER

      $PY_COMMAND $CLUSTER_MODULE/generate_method_clusters.py "$CVR_FOLDER/matrix_passing.csv" $M "$CLUSTER_FOLDER/clusters" 
      $PY_COMMAND $CLUSTER_MODULE/select_tests.py "$CVR_FOLDER/matrix_passing.csv" "$CLUSTER_FOLDER/clusters" $T "$CLUSTER_FOLDER/selected_tests"

    ;;

    step5)
      # daikon/invariant mining
      CHECKOUT_FOLDER="$OUT/0-checkout_${proj_id}_${bug_id}"
      CLUSTER_FOLDER="$OUT/3-cluster_${proj_id}_${bug_id}"
      CVR_FOLDER="$OUT/2-coverage_${proj_id}_${bug_id}"
      DAIKON_FOLDER="$OUT/4-daikon_${proj_id}_${bug_id}"

      mkdir -p $DAIKON_FOLDER
      TARGET_PROJECT="$CHECKOUT_FOLDER/b"

      $DAIKON_MODULE/run.sh -p $TARGET_PROJECT -c $CLUSTER_FOLDER -v $CVR_FOLDER -o $DAIKON_FOLDER
    ;;

    step6)
      # SBFL
      CVR_FOLDER="$OUT/2-coverage_${proj_id}_${bug_id}"
      SBFL_FOLDER="$OUT/5-sbfl_${proj_id}_${bug_id}"
      mkdir -p $SBFL_FOLDER

      $SBFL_MODULE/run_sbfl_calculation.sh -p "$CVR_FOLDER/matrix_passing.csv" -f "$CVR_FOLDER/matrix_failing.csv" -o $SBFL_FOLDER
        
    ;;

    step7)
      # build l2r data
      GROUND_TRUTH_FOLDER="$OUT/1-ground-truth_${proj_id}_${bug_id}"
      SBFL_FOLDER="$OUT/5-sbfl_${proj_id}_${bug_id}"
      DAIKON_FOLDER="$OUT/4-daikon_${proj_id}_${bug_id}"
      L2R_DATA_FOLDER="$OUT/6-l2r-data"
      mkdir -p $L2R_DATA_FOLDER
      
      $PY_COMMAND $L2R_MODULE/build_l2r_data.py "$GROUND_TRUTH_FOLDER/${proj_id}.${bug_id}b.method_diff" "$SBFL_FOLDER/susp_scores" "$DAIKON_FOLDER/3_daikon_diff" "$L2R_DATA_FOLDER/l2rdata.${proj_id}.${bug_id}"

      L2R_METHOD_NAMES="$L2R_DATA_FOLDER/methodnames"
      mkdir -p $L2R_METHOD_NAMES
      mv "$L2R_DATA_FOLDER/l2rdata.${proj_id}.${bug_id}.names" "$L2R_METHOD_NAMES/l2rdata.${proj_id}.${bug_id}.names"

    ;;
    
    step8)
      $(dirname "$0")/run_savant_train.sh -i $OUT/6-l2r-data/ -o $OUT/model
    ;;

    step9)
      $(dirname "$0")/run_savant_predict.sh -i $OUT/6-l2r-data/l2rdata.Lang.1 -m $OUT/model/model -o $OUT/res/
    ;;

    # else
    *) echo "There is no step \"$step\"" ;;
esac