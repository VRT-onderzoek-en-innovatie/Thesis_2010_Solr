#!/usr/bin/env ruby

require 'rubygems'
require 'right_aws'
require 'yaml'
require 'net/http'
require 'LB_Functions.rb'

load 'install_scr.rb'

# Ruby script launched at boot time
# This script will prepare Zookeeper & Solr for use

# A fresh ZooKeeper is already started on this instance.
# One Solr instance will be launched. The instance will be configured by a boot script to connect to the running ZooKeeper.
# The local instance ./solr/conf dir (of new started instance) will be uploaded to ZooKeep as the general conf for all slave instances.


# 1. Extract IP for this machine
my_ip = Get_IP('i-5b2c2837')

# 2. Prepare the boot script
keuze = '1'
varA = "Not used in test"	# There is no master instance in use during performance tests.

varB = %{# Connect to an external zookeeper instance\\nexport JAVA_OPTS="$JAVA_OPTS -DhostPort=8080"\\nexport JAVA_OPTS="$JAVA_OPTS -Dbootstrap_confdir=\\/data\\/medialoep_demo2\\/SolrIndex\\/solr\\/conf"\\nexport JAVA_OPTS="$JAVA_OPTS -Dcollection.configName=SolrConfig"\\nexport JAVA_OPTS="$JAVA_OPTS -DzkHost=}+my_ip+%{:2181"\\n}
varC = "ResponsTime_Test"

userdata = userdata(keuze, varA, varB, varC)

# 3. Start the first instance
puts "Starting new Solr master instance"
new_instance = Start_New_Server(userdata)

if ( new_instance != nil )
	if ( new_instance[0] != nil && new_instance[1] != nil)
		puts "Started a new instance with id: "+new_instance[0]+" and ip: "+new_instance[1]
	end
else
	puts "Starting of a new instance was not successful!"
end

# 4. Make new files, to reflect this fresh situation
# Writing new list of active instances.
output_hash = Hash.new("LB")
output_hash["instances"] = new_instance[0]
output_string = output_hash.to_yaml

file = File.open("/var/www/LB/instances.log","w")
file.write("# LB: List of all active instances and the corresponding IP-address\n");
file.write(output_string)
file.close

# Make a new dir to store all files
Dir::chdir("/var/www/LB/instances")
if FileTest::directory?(new_instance[0])
else
Dir::mkdir(new_instance[0])
end

# Make new csv file - this file will store all metrics for backup/verification purpose
file = File.open("/var/www/LB/instances/"+new_instance[0]+"/stats.csv","w")
file.write("# All monitored metrics for instance "+new_instance[0]+" with ip "+new_instance[1]+"\n")
file.write("date;act_sessies;memory;cpu;respons_time")
file.close

# Make empty moving array - this is a sliding array who will contain the stats of the last 60 mins.
act_sessies_array = Array.new(20) {0}


output_hash = Hash.new("moving_array")
output_hash["act_sessies"] = act_sessies_array
output_string = output_hash.to_yaml

file = File.open("/var/www/LB/instances/"+new_instance[0]+"/moving_array.log","w")
file.write(output_string)
file.close
