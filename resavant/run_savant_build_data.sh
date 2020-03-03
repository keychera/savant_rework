# check prereq
. $(dirname "$0")/run.config
. $(dirname "$0")/modules.structure
. $SCRIPTS_PY/check_py.sh
. $(dirname "$0")/timelog.sh "$OUT_FOLDER/build_data_timelog"

# iterate bug
PROJECTS=(Chart Closure Math Time Lang)
BUGS_NUM=(26 0 0 0 65)

# Savant
L2R_DATA_FOLDER="$OUT_FOLDER/6-l2r-data"
mkdir -p $L2R_DATA_FOLDER

i=0
while [ $i -lt ${#PROJECTS[@]} ]
do

    # for every bug
    bug_id=1
    while [ $bug_id -le ${BUGS_NUM[$i]} ]
    do
        proj_id=${PROJECTS[$i]}
        echo "Processing ${proj_id} ${bug_id}b"

        # checkout buggy and fixed version
        CHECKOUT_FOLDER="$OUT_FOLDER/0-checkout/${proj_id}/${bug_id}"
        mkdir -p "$CHECKOUT_FOLDER"

        defects4j checkout -p "${PROJECTS[$i]}" -v "${bug_id}b" -w "${CHECKOUT_FOLDER}/b"
        defects4j checkout -p "${PROJECTS[$i]}" -v "${bug_id}f" -w "${CHECKOUT_FOLDER}/f"
        savant_timelog "${proj_id} ${bug_id} checkout"

        # get d4j infos
            # ground truth
            GROUND_TRUTH_FOLDER="$OUT_FOLDER/1-ground-truth/${proj_id}/${bug_id}"
            mkdir -p $GROUND_TRUTH_FOLDER
            
            $DEFECTS4J_MODULE/extract_ground_truths.pl -p "${PROJECTS[$i]}" -v "${bug_id}b" -w "${CHECKOUT_FOLDER}" -o "$GROUND_TRUTH_FOLDER" # -w must refer to already checkout-ed src, b and f, error not yet handled TODO wrap the checkout process
            savant_timelog "${proj_id} ${bug_id} ground truth"

            # get coverage
            CVR_FOLDER="$OUT_FOLDER/2-coverage/${proj_id}/${bug_id}"
            mkdir -p $CVR_FOLDER

            $DEFECTS4J_MODULE/run_coverage.sh -w "${CHECKOUT_FOLDER}/b" -o "$CVR_FOLDER"
            savant_timelog "${proj_id} ${bug_id} coverage"
            
        # method clustering and test selection
        CLUSTER_FOLDER="$OUT_FOLDER/3-cluster/${proj_id}/${bug_id}"
        mkdir -p $CLUSTER_FOLDER

        $PY_COMMAND $CLUSTER_MODULE/generate_method_clusters.py "$CVR_FOLDER/matrix_passing.csv" $MAX_CLUSTER_SIZE "$CLUSTER_FOLDER/clusters" 
        $PY_COMMAND $CLUSTER_MODULE/select_tests.py "$CVR_FOLDER/matrix_passing.csv" "$CLUSTER_FOLDER/clusters" $MAX_TEST_NUMBER "$CLUSTER_FOLDER/selected_tests"
        savant_timelog "${proj_id} ${bug_id} method clustering and test selection"

        # daikon
        DAIKON_FOLDER="$OUT_FOLDER/4-daikon/${proj_id}/${bug_id}"
        mkdir -p $DAIKON_FOLDER
        TARGET_PROJECT="$CHECKOUT_FOLDER/b"

        $DAIKON_MODULE/run.sh -p $TARGET_PROJECT -c $CLUSTER_FOLDER -v $CVR_FOLDER -o $DAIKON_FOLDER
        savant_timelog "${proj_id} ${bug_id} daikon"

        # sbfl
        SBFL_FOLDER="$OUT_FOLDER/5-sbfl/${proj_id}/${bug_id}"
        mkdir -p $SBFL_FOLDER
        $SBFL_MODULE/run_sbfl_calculation.sh -p "$CVR_FOLDER/matrix_passing.csv" -f "$CVR_FOLDER/matrix_failing.csv" -o $SBFL_FOLDER
        savant_timelog "${proj_id} ${bug_id} sbfl"

        # build the l2r data
        $PY_COMMAND $L2R_MODULE/build_l2r_data.py "$GROUND_TRUTH_FOLDER/${proj_id}.${bug_id}b.method_diff" "$SBFL_FOLDER/susp_scores" "$DAIKON_FOLDER/3_daikon_diff" "$L2R_DATA_FOLDER/l2rdata.${proj_id}.${bug_id}"
        savant_timelog "${proj_id} ${bug_id} building l2r data"

        ((bug_id++))
    done
    
    ((i++))
done


