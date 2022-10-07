#!/bin/env bash
# This bash script does stuff.
# This is licensed under MIT license.
# Website: https://github.com/Florke64/uptimem

ID="$(hostname)"
HOSTS="$@"
SUBSCRIBERS=$(cat "subscribers.txt")
CACHE_DIR="$HOME/.cache/uptimem"

# E-Mail Content
SUBJECT_FAIL="Subject: $ID: Uptime check failed with $1"
SUBJECT_SUCC="Subject: $ID: Connection with $1 is back up"
BODY_FAIL="You will be informed when it is back up via separate e-mail."
BODY_SUCC="Remote machine answered the ping."

notification() {
    status=$2
    curtime="$(date --iso-8601=seconds)"
    maildir="/tmp/mail/$curtime/"
    mkdir -p "$maildir"
    mail="$maildir/notification_message.txt"

    if [ $status -eq 1 ]
    then
        echo "$SUBJECT_FAIL" > $mail
        echo "$BODY_FAIL" >> $mail
    else    
        echo "$SUBJECT_SUCC" > $mail
        echo "$BODY_SUCC" >> $mail
    fi
    
    echo "---" >> $mail
    echo "$curtime" >> $mail
    
    sendmail "$SUBSCRIBERS" < $mail
}

test() {
    echo "Testing $1."
    if ping -c $2 -i 5 "$1" > /dev/null
    then
        return 0
    elif [ $2 -ne 1 ]
    then
        echo "Basic test failed."
        test "$1" 4 && return 1
    fi

    return 1
}

main() {
    for host in $HOSTS; do
        lockfile="$CACHE_DIR/$host"

        if test "$host" 1
        then
            echo "Ping succeess!"
            if ls "$lockfile" > /dev/null; then rm -f "$lockfile" && notification "$host" 0; fi
        else
            ls $CACHE_DIR > /dev/null || mkdir -p $CACHE_DIR

            if ls "$lockfile" > /dev/null
            then
                echo "Uptime check with $host failed once again."
            else
                echo "[!] Uptime check with $host failed."
                touch "$lockfile"
                notification "$host" 1
            fi
        fi
    done
}

main
