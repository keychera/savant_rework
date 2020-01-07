# check prereq
source $(dirname "$0")/run.config
source $(dirname "$0")/modules.structure
source $SCRIPTS_PY/check_py.sh

# iterate bug
PROJECTS=(Chart Closure Math Time Lang)
BUGS_NUM=(1 0 0 0 1)

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

        # sbfl

        # daikon

        # aggregate the results
        
        ((bug_id++))
    done
    
    ((i++))
done
    
# l2r

