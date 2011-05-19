#!/bin/bash
# echo "----------------------------------------------------------------------------------------"
# echo "Script to monitor Performance metrics & save them at a file"
# echo "----------------------------------------------------------------------------------------"

# Monitor CPU belasting
echo "#$(date)#"  >> /var/www/monitoring/temp/temp_CPU.log
vmstat >> /var/www/monitoring/temp/temp_CPU.log

# Monitor de geheugen belasting
echo "#$(date)#"  >> /var/www/monitoring/temp/temp_memory.log
free >> /var/www/monitoring/temp/temp_memory.log

# Monitor het aantal actieve sessies ( ~het aantal concurrente verzoeken op een tijdstip )
sudo wget -O/var/www/monitoring/temp/server-status.log "localhost/server-status?auto"
sudo ruby /usr/Monitoring_Script/Script_active_sessies.rb

# Monitor de gemiddelde respons tijd
#sudo ruby /usr/Monitoring_Script/Script_NewRelic.rb

# Monitor de Disk I/O belasting
# Overbodig: de volledige index past in het geheugen - na enige tijd zijn is er geen enkele Disk I/O meer vereist.
# echo "#$(date)#" >> /var/www/monitoring/temp/temp_DiskIO.log
# iostat -x >> /var/www/monitoring/temp/temp_DiskIO.log 

# echo "----------------------------------------------------------------------------------------"
