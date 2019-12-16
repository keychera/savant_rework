source runconfig
source ../resavant-clustermodule/check_py.sh

mkdir -p $TEMP/

# step 1 calculate raw statistic
$PY_COMMAND $PYSCRIPT_PATH/calculate_sbfl_raw_statistic.py "$TEMP_INPUT/res.csv" "$TEMP_INPUT/res_fail.csv" 

# calculate given sbfl formula
