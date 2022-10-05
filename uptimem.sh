#!/bin/env bash
# This bash script does stuff.
# This is licensed under MIT license.
# Website: https://github.com/Florke64/uptimem

ID="PARIS"
HOSTS="$@"
SUBSCRIBERS=$(cat "subscribers.txt")
CACHE_DIR="$HOME/.cache/uptimem"

# E-Mail Content
SUBJECT_FAIL="Subject: $ID: Uptime check failed with $1"
SUBJECT_SUCC="Subject: $ID: Connection with $1 is back up"
BODY_FAIL="You will be informed when it is back up via separate e-mail."
BODY_SUCC="Remote machine answered the ping."

notification() {
    CURTIME="$(date --iso-8601=seconds)"
    MAILDIR="/tmp/mail/$CURTIME/"
    mkdir -p $MAILDIR
    MAIL="$MAILDIR/notification_message.txt"
    
    echo $SUBJECT_FAIL > $MAIL

    echo $BODY_FAIL >> $MAIL
    echo "---" >> $MAIL
    echo "$CURTIME" >> $MAIL
    
    sendmail $SUBSCRIBERS < $MAIL
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
            rm -f "$lockfile"
        else
            ls $CACHE_DIR > /dev/null || mkdir -p $CACHE_DIR
            
            if ls "$lockfile" > /dev/null
            then
                echo "Uptime check with $host failed once again."
            else
                echo "[!] Uptime check with $host failed."
                touch "$lockfile"
                notification $host
            fi
        fi
    done
}

main
