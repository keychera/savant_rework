PROJECT="Lang"
BUG_ID="1"
GROUND_TRUTH="/home/square/Documents/projects/savant_rework/resavant/temp/1-ground-truth/$PROJECT/${BUG_ID}/$PROJECT.${BUG_ID}b.method_diff"
SUSP_SCORES="/home/square/Documents/projects/savant_rework/resavant/temp/5-sbfl/$PROJECT/$BUG_ID/susp_scores"
INVARIANT_DIFF="/home/square/Documents/projects/savant_rework/resavant/temp/4-daikon/$PROJECT/$BUG_ID/3_daikon_diff"

python $(dirname "$0")/build_l2r_data.py $GROUND_TRUTH $SUSP_SCORES $INVARIANT_DIFF "$(dirname "$0")/l2rdatatest"
