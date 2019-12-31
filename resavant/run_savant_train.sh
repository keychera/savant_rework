# check prereq
OUT_FOLDER="./temp"

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
            # ground truth, relevant infos
        

        # get coverage

        # method clustering and test selection

        # sbfl

        # daikon

        # aggregate the results
        
        ((bug_id++))
    done
    
    ((i++))
done
    
# l2r

