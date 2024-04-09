#!/bin/bash
#m.sh
#Description: Check for known errors and if they are found, send an alert email, save the current log file, add a new line on a new log file and restart service
#Version 1.4
#ICM Support Team
#20210422
##Version		Description				Date				By
##V1.1			Test corrective processes		2021-04-12			hportela
##V1.2			Test array to get errors		2021-04-14			hportela
##V1.3			PALCCS Checking added			2021-04-20			ICM Support
##V1.4			NPM Checking added			2021-04-22			hportela
##V1.5			zip bkp log file			2021-05-12			jlayton
##			add line number in new log
##			add general variables
##v1.6			add env var to make it work in crontab	2021-05-27			jlayton

###To check:
######Service restart script
######Restart services on another servers if needed
######Issues with other services

###Env vars
PATH=/usr/ucb:/opt/ukqa/environments/jdk1.8.0_222/jre/bin:/usr/ucb:/opt/ukqa/environments/jdk1.7.0_45/jre/bin:/usr/lib64/qt-3.3/bin:/opt/perforce:/opt/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/u01/app/oracle/product/10.2.0/client_1/bin:/home/ukqa/dro/bin:/home/ukqa/dro/control:/home/ukqa/qa/bin:/home/ukqa/dro/jenkins:/home/ukqa/dro/cloud:/opt/build_tools/perforce:/opt/build_tools/ant:/home/ukqa/dro/bin:/home/ukqa/dro/control:/home/ukqa/qa/bin:/home/ukqa/dro/jenkins:/home/ukqa/dro/cloud:/opt/build_tools/perforce:/opt/build_tools/ant
now=$(date -u +"%Y-%m-%d_%H_%M_%S")
body=$(date -u +"%d %b %H:%M UTC")
box=$(hostname)
cust_root='/opt/ukqa/SITEMAP/RSTU_ICM_UAT/'

#Error logs
palccs_error_log=$cust_root'micmserver/logs/mercedicm-server.log'
npm_error_log=$cust_root'npm/merced_std_err.log'

#Known errors
palccs_known_errors=$cust_root'support_monitoring/known_errors/palccs_errors.txt'
npm_known_errors=$cust_root'support_monitoring/known_errors/npm_errors.txt'

#Backup logs
palccs_bkp_log=$cust_root'support_monitoring/logs/micmserver/mercedicm-server_'$now'.log'
npm_bkp_log=$cust_root'support_monitoring/logs/npm/merced_std_err_'$now'.log'

#Error files
palccs_error_file=$cust_root'support_monitoring/monitoring_palccs.log'
npm_error_file=$cust_root'support_monitoring/monitoring_npm.log'

#PALCCS Array
arr_palccs=()
while IFS= read -r line || [[ "$line" ]]; do
arr_palccs+=("$line")
done < $palccs_known_errors
array_palccs_lenght=${#arr_palccs[@]}
index_palccs=0

#Check for errors for PALCCS:
while (($array_palccs_lenght > $index_palccs))
do
        if [ $(cat $palccs_error_log | grep "${arr_palccs[$index_palccs]}" | wc -l) -ge 1 ]
        then
			#1. Send an alert email
			echo "Email alert has been sent for PALCCS"
			#mail -s "PALCCS error on $box" hassan.portela@nice.com <<< "$(cat $palccs_error_log | grep -n -A 2 "${arr_palccs[$index_palccs]}" | head -2)"

			#2. Add a new line on the PALCCS.log
			echo "New line on palccs log"
			echo "--- $body" >> $palccs_error_file
			echo "$(cat $palccs_error_log | grep -n -A 2 "${arr_palccs[$index_palccs]}" | head -2)" >> $palccs_error_file

			#3. Restart PALCCS and save log file
			$cust_root/micmserver/palccs.sh stop
			mv $palccs_error_log $palccs_bkp_log
			gzip $palccs_bkp_log
			echo "PALCCS log file have been saved"
			$cust_root/micmserver/palccs.sh start
			echo "PALCCS has been restarted"
        fi
        index_palccs=$(( index_palccs+1 ))
done

#NPM Array
arr_npm=()
while IFS= read -r line || [[ "$line" ]]; do
arr_npm+=("$line")
done < $npm_known_errors
array_npm_lenght=${#arr_npm[@]}
index_npm=0

#Check for errors for NPM:
while (($array_npm_lenght > $index_npm))
do
        if [ $(cat $npm_error_log | grep "${arr_npm[$index_npm]}" | wc -l) -ge 1 ]
        then
			#1. Send an alert email
			echo "Email alert has been sent for NPM"
			#mail -s "NPM error on $box" jaime.layton@nice.com <<< "$(cat $npm_error_log | grep -n -A 2 "${arr_npm[$index_npm]}" | head -2)"

			#2. Add a new line on the NPM.log
			echo "New line on npm log"
			echo "--- $body" >> $npm_error_file
			echo "$(cat $npm_error_log | grep -n -A 2 "${arr_npm[$index_npm]}" | head -2)" >> $npm_error_file

			#3. Restart NPM
			$cust_root/npm/bin/m mserver stop singleton			
			mv $npm_error_log $npm_bkp_log
			gzip $npm_bkp_log
			echo "NPM log file have been saved"
			$cust_root/npm/bin/m mserver start singleton
			echo "NPM has been restarted"
        fi
        index_npm=$(( index_npm+1 ))
done
