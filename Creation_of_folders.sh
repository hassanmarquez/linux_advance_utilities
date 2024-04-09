echo "insert the customer root folder with an / at the end" 
read cust_root
echo "creating folders"
mkdir $cust_root'support_monitoring'
mkdir $cust_root'support_monitoring/known_errors'
mkdir $cust_root'support_monitoring/logs/'
mkdir $cust_root'support_monitoring/logs/npm'
mkdir $cust_root'support_monitoring/logs/micmserver'
echo "populating known error files"
echo "rootCause=java.lang.OutOfMemoryError: GC overhead limit exceeded" > $cust_root'support_monitoring/known_errors/npm_errors.txt'
echo "ps executeQuery failed IO Error: Connection timed out in" > $cust_root'support_monitoring/known_errors/palccs_errors.txt'
echo "changing permissions to folder"
chmod -R 775 $cust_root'support_monitoring'


1. change cust_root in monitoring script
2. Check if services (PALCCS, NPM) are in the usual folder and if the error files and start services script are there.
3. get URL from /opt/nice/eplus/npm/localconfig/URLOverrides.properties to get the webserver URL
example: micm=http://icm-tl-web1-epl.u1.niceondemand.com:8080/micm,\
4. then test npm url with 
curl -o /dev/null --silent --write-out '%{http_code}\n' http://icm-tl-web1-epl:8080/rest/user-management/user/status
5. Change it in the script
6. create script_monitoring.sh
7. Create crontab line
*/5 * * * * (bash $cust_root/support_monitoring/script_monitoring.sh)
8. test script manually for both services (PALCCS, NPM)
9. Test script with crontab for both services (PALCCS, NPM)
