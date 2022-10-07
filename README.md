# uptimem
Utility to measure remote server availablility.

## requirements
`bash` `sendmail` (pre-configured, optional)

## setup
Clone the repository

```
$ cd /opt
# git clone https://github.com/Florke64/uptimem
# chmod +x uptimem/uptimem.sh
```

Set-up Cron Job
```
$ crontab -e
```

*I like to have...*
```
*/5 * * * * cd /opt/uptimem && /bin/bash /opt/uptimem/uptimem.sh 172.22.1.20 > /tmp/uptimem_last.log
```

## license
MIT.




