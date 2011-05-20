def userdata(keuze, ip_Master)
userdata=
%{#!/bin/bash -ex}
if keuze == "slave"
	add = %{sed -ibak 's/<!-- CHANGE -->/<!-- SLAVE Settings -->\\n<lst name="slave">\\n<str name="masterUrl">http:\\/\\/} +ip_Master+ %{\\/solr\\/replication<\\/str>\\n<str name="pollInterval">00:00:60<\\/str>\\n<\\/lst>/g' /data/medialoep_demo2/SolrIndex/solr/conf/solrconfig.xml}
else
	add = %{sed -ibak 's/<!-- MASTER/ /g' /data/medialoep_demo2/SolrIndex/solr/conf/solrconfig.xml
sed -ibak 's/MASTER -->/ /g' /data/medialoep_demo2/SolrIndex/solr/conf/solrconfig.xml}
end
userdata = userdata+add+%{

service tomcat6 restart

# tell the world what we've done!
echo 'User boot time script executed' >> /root/boot_time_script
echo '+----------+ ' >> /root/boot_time_script
echo 'A. Modded solrconfig.xml - Replication Handler' >> /root/boot_time_script
echo 'B. restarted tomcat' >> /root/boot_time_script
}

return userdata
end