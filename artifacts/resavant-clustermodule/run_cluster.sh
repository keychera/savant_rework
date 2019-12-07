
source runconfig

$PY_COMMAND $PYSCRIPT_PATH/get_method_cluster.py "$TEMP/res.csv" 5 "$TEMP/clusters" 

$PY_COMMAND $PYSCRIPT_PATH/select_tests.py "$TEMP/res.csv" "$TEMP/clusters" 10 "$TEMP/selected_tests"
