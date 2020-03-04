LAST_TIME=$(($(date +%s%N)/1000000))
TIMELOG_FILE="$1"

if [ -f "$TIMELOG_FILE" ]; then
    last_char=${TIMELOG_FILE: -1}
    if [[ $last_char =~ ^-?[0-9]+$ ]]; then
        let "num=last_char+1"
    else
        let "num=1"
    fi
    TIMELOG_FILE="${TIMELOG_FILE}_${num}"
fi
echo '' > $TIMELOG_FILE

savant_timelog() {
    MSG=$1
    CURRENT_TIME=$(($(date +%s%N)/1000000))
    let "time_elapsed=(CURRENT_TIME-LAST_TIME)"
    LAST_TIME=$CURRENT_TIME

    echo "$CURRENT_TIME $(date +"%T")" >> $TIMELOG_FILE

    let "seconds_elapsed=time_elapsed/1000"
    let "mili_elapsed=time_elapsed%1000"
    if (( $seconds_elapsed > 60000 )) ; then
        let "minutes=(seconds_elapsed%3600)/60"
        let "seconds=(seconds_elapsed%3600)%60"
        echo "$minutes minute(s), $seconds second(s), $mili_elapsed miliseconds for ($MSG)" >> $TIMELOG_FILE
    else
        echo "$seconds_elapsed seconds, $mili_elapsed miliseconds for ($MSG)" >> $TIMELOG_FILE
    fi

}