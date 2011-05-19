#!/usr/bin/env ruby

require 'rubygems'
require 'right_aws'
require 'yaml'
require 'net/http'
require '/usr/scripts/LB_Functions.rb'

load '/usr/scripts/install_scr.rb'

# instelling over hoeveel minuten het algoritme moet kijken 
# Bv. moving_time = 10 - het algoritme zal van de metrics (bv. respons_time) het gemiddelde nemen van de afgelopen 10 minuten. 
# Dit gemiddelde wordt dan verder gebruikt in het algoritme.

moving_time = 10
bovenlimiet = 0
onderlimiet = 25


# retreive the pool of instances from a file
file = File.open("/var/www/LB/instances.log","r")
input_string = file.read 
file.close 

hash = YAML::load(input_string)
instances = hash["instances"] 

# 1. Retrieve the performance metrics ( samples of last 5 min ) from each running instance
#puts "+-------------------------------+-"
puts Time.now 
#puts " " 
#puts "1. Retrieving all performance metrics from instances" 

array_gemActSessies = Array.new 
instancesArray = Array.new
aantalInstances = 0

instances.each do |instance|
	aantalInstances += 1
	instancesArray.push(instance)
	hash = Get_Belasting(Get_IP(instance))
	
	# YAML of past 5 min AND CSV backup of whole lifecycle.
	output_string = hash.to_yaml
	file = File.open("/var/www/LB/instances/"+instance+"/Last_Metrics.log","w")
	file.write(output_string)
	file.close

	# Append csv
	file = File.open("/var/www/LB/instances/"+instance+"/stats.csv","a")
	for i in 0..4 do
		file.write(Time.now.to_s() +";"+ hash["act_sessies"][i].to_s() +";"+ hash["memory"][i].to_s() +";" + hash["cpu"][i].to_s() +";"+ hash["respons_time"][i].to_s() +"\n")
	end
	file.close
	
	# Voeg metrics toe aan moving array - de moving array bevat alle waardes van de afgelopen 60 minuten.
	file = File.open("/var/www/LB/instances/"+instance+"/moving_array.log","r")
	input_string = file.read
	file.close
	
	hash2 = YAML::load(input_string)
	act_sessies_array = hash2["act_sessies"]
	act_sessies_array.pop
	act_sessies_array = act_sessies_array.reverse
	for i in 0..4 do
		act_sessies_array.push(hash["act_sessies"][i])
	end
	act_sessies_array = act_sessies_array.reverse

	# update de moving array
	hash2["act_sessies"] = act_sessies_array
	output_string = hash2.to_yaml
	file = File.open("/var/www/LB/instances/"+instance+"/moving_array.log","w")
	file.write(output_string)
	file.close
	
	# Bereken gemiddelde voor metrics - over de waardes van de laatste x minuten ( keuze tijdseenheid instelbaar )
	gem_act_sessies = 0

	for i in 0..(moving_time-1)
		if (hash2["act_sessies"][i] != nil)
			gem_act_sessies += hash2["act_sessies"][i]
		else
			 gem_act_sessies += 0
		end
	end
	gem_act_sessies = gem_act_sessies/moving_time

	array_gemActSessies.push(gem_act_sessies)
	
	puts "Stats for instance "+ instance
	puts "+gemActSessies over de laatste "+moving_time.to_s()+" min: "+gem_act_sessies.to_s()
end 

puts "------ "
#puts "2. Evaluating the metrics to determine if instances must be started / stopped" 
gem_act_sessies = (array_gemActSessies.inject(0) { |s,v| s += v })/array_gemActSessies.length 

puts "Gemiddeld aantal actieve sessies over alle instanties: "+gem_act_sessies.to_s()
#puts " "
#puts "3. Het starten / stoppen van instanties"

if ( gem_act_sessies >= bovenlimiet )
   	if (aantalInstances < 12)
      		#puts "Starting a new instance"

		# Zet userdate sectie
		keuze = '1'
		varA = "Not needed"
	
		ip_ZK=Get_IP('i-5b2c2837')
		varB = %{# Connect to an external zookeeper instance\\nexport JAVA_OPTS="$JAVA_OPTS -DhostPort=8080"\\nexport JAVA_OPTS="$JAVA_OPTS -Dcollection.configName=SolrConfig"\\nexport JAVA_OPTS="$JAVA_OPTS -DzkHost=}+ip_ZK+%{:2181"\\n}
		varC = "ResponsTime_Test"

		userdata = userdata(keuze, varA, varB, varC)
   		newInstance = Start_New_Server(userdata)
      		puts "+Started instance "+newInstance[0]
		
		instancesArray.push(newInstance[0])

		# Make a new dir to store all files
		Dir::chdir("/var/www/LB/instances")
		if FileTest::directory?(newInstance[0])
		else
		Dir::mkdir(newInstance[0])
		end

		# Make new csv file - this file will store all metrics for backup/verification purpose
		file = File.open("/var/www/LB/instances/"+newInstance[0]+"/stats.csv","w")
		file.write("# All monitored metrics for instance "+newInstance[0]+" with ip "+newInstance[1]+"\n")
		file.write("date;act_sessies;memory;cpu;respons_time")
		file.close

		# Make empty moving array - this is a sliding array who will contain the stats of the last 60 mins.
		act_sessies_array = Array.new(20) {0}

		output_hash = Hash.new("moving_array")
		output_hash["act_sessies"] = act_sessies_array
		output_string = output_hash.to_yaml

		file = File.open("/var/www/LB/instances/"+newInstance[0]+"/moving_array.log","w")
		file.write(output_string)
		file.close		

                #puts "++Started the instance"
      	else
      		puts "There are already 4 instances running - cannot start a new one."
	end
elsif ( gem_act_sessies < onderlimiet )
	if ( aantalInstances > 1)
		puts	"Stopping an instance"
		#puts Stop_Server(instancesArray[1])
		### DEACTIVATED _ REACTIVATE			
      		
      		#instancesArray.delete(instances[1])
   		#puts "+Removed the instance"
   		
      	else
      		puts "There is one single instance running. No need to stop instances." end else puts "no action needed"
end
   
   
# save the pool of instances

hash_eind=Hash.new()
hash_eind["instances"] = instancesArray
output_string = hash_eind.to_yaml

file = File.open("/var/www/LB/instances.log","w")
file.write(output_string)
file.close 
puts "-----------------------------------"
