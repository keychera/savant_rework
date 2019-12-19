source runconfig
source ../resavant-clustermodule/check_py.sh

mkdir -p $TEMP/

# step 1 calculate raw statistic
# $PY_COMMAND calculate_sbfl_raw_statistic.py "$TEMP_INPUT/res.csv" "$TEMP_INPUT/res_fail.csv" "$TEMP/raw_stat"

# calculate given sbfl formula
$PY_COMMAND calculate_sbfl_suspiciousness_score.py "$TEMP/raw_stat"
