# check prereq
source run.config
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
            
            # relevant infos
            BUG_INFO_FOLDER="$OUT_FOLDER/2-bug-info/${proj_id}/${bug_id}"
            mkdir -p $BUG_INFO_FOLDER

            $DEFECTS4J_MODULE/get_bug_info.sh -w "${CHECKOUT_FOLDER}/b" -o "$BUG_INFO_FOLDER"

            # get coverage
            CVR_FOLDER="$OUT_FOLDER/3-coverage/${proj_id}/${bug_id}"
            mkdir -p $CVR_FOLDER
            $DEFECTS4J_MODULE/run_coverage.sh -w "${CHECKOUT_FOLDER}/b" -b "$BUG_INFO_FOLDER" -o "$CVR_FOLDER"
            
        # method clustering and test selection

        # sbfl

        # daikon

        # aggregate the results
        
        ((bug_id++))
    done
    
    ((i++))
done
    
# l2r

