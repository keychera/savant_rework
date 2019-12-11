
source runconfig
source ./check_py.sh

$PY_COMMAND $PYSCRIPT_PATH/generate_method_clusters.py "$TEMP/res.csv" 5 "$TEMP/clusters" 

$PY_COMMAND $PYSCRIPT_PATH/select_tests.py "$TEMP/res.csv" "$TEMP/clusters" 10 "$TEMP/selected_tests"
