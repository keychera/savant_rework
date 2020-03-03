SECONDS=0
LAST_TIME=0
TIMELOG_FILE="$1"

echo '' > $TIMELOG_FILE
savant_timelog() {
    MSG=$1
    CURRENT_TIME=$SECONDS
    let "time_elapsed=(CURRENT_TIME-LAST_TIME)"
    LAST_TIME=$CURRENT_TIME

    echo "$CURRENT_TIME $(date +"%T")" >> $TIMELOG_FILE

    if (( $time_elapsed > 60 )) ; then
        let "minutes=(time_elapsed%3600)/60"
        let "seconds=(time_elapsed%3600)%60"
        echo "$minutes minute(s) and $seconds second(s) for ($MSG)" >> $TIMELOG_FILE
    else
        echo "$time_elapsed seconds for ($MSG)" >> $TIMELOG_FILE
    fi

}