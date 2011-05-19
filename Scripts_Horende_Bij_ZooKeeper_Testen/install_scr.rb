# Template for boot script for new instances
# varA, varB, varC need still to be filled in - will be set by calling script, before first acces

# varA: IP address of Solr Master ( used for replication of the index )
# VarB: ZooKeeper related JAVA_OPTS to connect to the zookeeper instance
# varC: app_name of new solr - used for NewRelic deamon
# keuze: 1 for solr with master index - 2 for solr slaves ( used for replication porperties )

def userdata(keuze, varA, varB, varC)
userdata=
%{#!/bin/bash -ex

# A
}
if keuze == '2'
	add = %{sudo rm -r /data/medialoep_demo2/SolrIndex/solr/conf/}
	# Remove the config dir - a fresh one will be downloaded from ZooKeeper
else
	# Upload config from this machine to upload to ZooKeeper
	add = %{sed -ibak 's/<!-- MASTER/ /g' /data/medialoep_demo2/SolrIndex/solr/conf/solrconfig.xml
sed -ibak 's/MASTER -->/ /g' /data/medialoep_demo2/SolrIndex/solr/conf/solrconfig.xml}
end
userdata = userdata+add+%{


#B - ZooKeeper parameters
sed -ibak 's/# EXTRA ZOOKEEEPER PARAMETERS #/} + varB + %{/g' /etc/init.d/tomcat6


#C - inzake NewRelic
sed -ibak 's/app_name: Dummy/app_name: } + varC + %{\\n/g' /var/lib/tomcat6/newrelic/newrelic.yml


#D - inzake NewRelic
sed -ibak 's/# Start the NewRelic agent #/# Start the NewRelic agent #\\nexport JAVA_OPTS="$JAVA_OPTS -javaagent:\\/var\\/lib\\/tomcat6\\/newrelic\\/newrelic.jar"/g' /etc/init.d/tomcat6


#E - inzake NewRelic
sed -ibak 's/$app_name=/$app_name="} + varC + %{"/g' /usr/Monitoring_Script/settings.rb


#F
service tomcat6 restart

# tell the world what we've done!
echo 'User boot time script executed' >> /root/boot_time_script
echo '+----------+ ' >> /root/boot_time_script
echo 'A. Removed dirty Solr config - a fresh config will be downloaded from ZooKeeper' >> /root/boot_time_script
echo 'B. Modded init.d/tocmat6 - ZooKeeper parameter' >> /root/boot_time_script
echo 'C. Modded newrelic.yml - setting name of instance' >> /root/boot_time_script
echo 'D. Statup hook for NewRelic agent added' >> /root/boot_time_script
echo 'E. Added App_Name to settings' >> /root/boot_time_script
echo 'F. restarted tomcat' >> /root/boot_time_script
}

return userdata
end
