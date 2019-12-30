
source runconfig

mkdir -p $TEMP

# build the input for each bugs

BUG_FEATURES_FOLDER="$TEMP/bug-features"
mkdir -p $BUG_FEATURES_FOLDER

BUG_GROUND_TRUTH="../resavant-defects4Jmodule/temp/Lang.1b.method_diff"
BUG_SBFL_STAT="../resavant-sbflmodule/temp/susp_scores"
BUG_DAIKON_STAT="."
python build_input.py $BUG_GROUND_TRUTH $BUG_SBFL_STAT $BUG_DAIKON_STAT "$BUG_FEATURES_FOLDER/Lang.1b"

# aggregate the input
python aggregate_input.py "$BUG_FEATURES_FOLDER" "$TEMP/aggregate_features"

# normalize the input
python normalize_input.py "$TEMP/aggregate_features" "$TEMP/normalized_features" "$TEMP/maxmin_info"

# run the libsvm
$RANKSVM_FOLDER/train "$TEMP/normalized_features" "$TEMP/model"

# test the model
$RANKSVM_FOLDER/predict "$TEMP/test_features" "$TEMP/model" "$TEMP/test_result"
