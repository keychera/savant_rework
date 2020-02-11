# check prereq
source $(dirname "$0")/run.config
source $(dirname "$0")/modules.structure
source $SCRIPTS_PY/check_py.sh

# iterate bug
PROJECTS=(Chart Closure Math Time Lang)
BUGS_NUM=(1 0 0 0 1)

L2R_DATA_FOLDER="$OUT_FOLDER/6-l2r-data"
mkdir -p $L2R_DATA_FOLDER

# Multric
# i=0
# while [ $i -lt ${#PROJECTS[@]} ] 
# do
#     # for every bug
#     bug_id=1
#     while [ $bug_id -le ${BUGS_NUM[$i]} ]
#     do
#         # get coverage
#         MULTRIC_CVR_FOLDER="$OUT_FOLDER/2-coverage/${proj_id}/${bug_id}"
#         mkdir -p $MULTRIC_CVR_FOLDER
# 
#         $DEFECTS4J_MODULE/run_coverage.sh -w "${CHECKOUT_FOLDER}/b" -o "$MULTRIC_CVR_FOLDER"
#     done
# done

# Savant
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

        # get d4j infos
            # ground truth
            GROUND_TRUTH_FOLDER="$OUT_FOLDER/1-ground-truth/${proj_id}/${bug_id}"
            mkdir -p $GROUND_TRUTH_FOLDER
            
            $DEFECTS4J_MODULE/extract_ground_truths.pl -p "${PROJECTS[$i]}" -v "${bug_id}b" -w "${CHECKOUT_FOLDER}" -o "$GROUND_TRUTH_FOLDER" # -w must refer to already checkout-ed src, b and f, error not yet handled TODO wrap the checkout process

            # get coverage
            CVR_FOLDER="$OUT_FOLDER/2-coverage/${proj_id}/${bug_id}"
            mkdir -p $CVR_FOLDER

            $DEFECTS4J_MODULE/run_coverage.sh -w "${CHECKOUT_FOLDER}/b" -o "$CVR_FOLDER"
            
        # method clustering and test selection
        CLUSTER_FOLDER="$OUT_FOLDER/3-cluster/${proj_id}/${bug_id}"
        mkdir -p $CLUSTER_FOLDER

        $PY_COMMAND $CLUSTER_MODULE/generate_method_clusters.py "$CVR_FOLDER/matrix_passing.csv" $MAX_CLUSTER_SIZE "$CLUSTER_FOLDER/clusters" 
        $PY_COMMAND $CLUSTER_MODULE/select_tests.py "$CVR_FOLDER/matrix_passing.csv" "$CLUSTER_FOLDER/clusters" $MAX_TEST_NUMBER "$CLUSTER_FOLDER/selected_tests"

        # daikon
        DAIKON_FOLDER="$OUT_FOLDER/4-daikon/${proj_id}/${bug_id}"
        mkdir -p $DAIKON_FOLDER
        TARGET_PROJECT="$CHECKOUT_FOLDER/b"

        $DAIKON_MODULE/run.sh -p $TARGET_PROJECT -c $CLUSTER_FOLDER -v $CVR_FOLDER -o $DAIKON_FOLDER

        # sbfl
        SBFL_FOLDER="$OUT_FOLDER/5-sbfl/${proj_id}/${bug_id}"
        mkdir -p $SBFL_FOLDER
        $SBFL_MODULE/run_sbfl_calculation.sh -p "$CVR_FOLDER/matrix_passing.csv" -f "$CVR_FOLDER/matrix_failing.csv" -o $SBFL_FOLDER


        # build the l2r data
        $PY_COMMAND $L2R_MODULE/build_l2r_data.py "$GROUND_TRUTH_FOLDER/${proj_id}.${bug_id}b.method_diff" "$SBFL_FOLDER/susp_scores" "." "$L2R_DATA_FOLDER/l2rdata.${proj_id}.${bug_id}"

        ((bug_id++))
    done
    
    ((i++))
done

# l2r, aggregate the results and train
L2R_RESULT_FOLDER="$OUT_FOLDER/7-l2r-result"
mkdir -p $L2R_RESULT_FOLDER

$L2R_MODULE/run_l2r_train.sh -i "$L2R_DATA_FOLDER" -o "$L2R_RESULT_FOLDER"
