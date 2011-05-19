#!/usr/bin/env ruby

require 'rubygems'
require 'right_aws'
require 'yaml'
require 'net/http'
require '/usr/scripts/LB_Functions.rb'

load '/usr/scripts/install_scr.rb'
load '/usr/scripts/need_restart.rb'
load '/usr/scripts/getParameter.rb'
load '/usr/scripts/master_ip.rb'

# instelling over hoeveel minuten het algoritme moet kijken 
# Bv. moving_time = 10 - het algoritme zal van de metrics (bv. respons_time) het gemiddelde nemen van de afgelopen 10 minuten. 
# Dit gemiddelde wordt dan verder gebruikt in het algoritme.
moving_time = 10
bovenlimiet = 200
onderlimiet = 25


#---------------------------------------------------#
def LaunchInstance(master_ip)
	userdata = userdata("slave", master_ip)	# Start Slave & geef IP-adres Master mee
        newInstance = Start_New_Server(userdata)
	if (newInstance == nil)
		puts Time.now.to_s() + " - HET STARTEN VAN EEN INSTANTIE IS MISLUKT! "
		# needs to be undone - there is no restart needed!	
		 file = File.open("/usr/scripts/need_restart.rb","w")
                        file.puts("$need_restart=0")
                        file.puts("$need_rebalance=0")
                file.close
	else
	        puts Time.now.to_s() + " - started instance "+newInstance[0]
	end
        return newInstance
end
#---------------------------------------------------#


# Laat de monitoring voor deze minuut lopen
# > Er worden over een tijdsperiode van 45s 10 samples genomen ( telkens 5s tussen )
# >> Deze resultaten worden opgeslagen in csv logs
huidig_act_sessies = getParameter()

# Voeg metrics toe aan moving array - de moving array bevat alle waardes van de afgelopen 30 minuten.
file = File.open("/var/www/LB/moving_array.log","r")
        input_string = file.read
file.close

hash_total = YAML::load(input_string)
act_sessies_array = hash_total["act_sessies"]

act_sessies_array.pop
act_sessies_array = act_sessies_array.reverse
act_sessies_array.push(huidig_act_sessies)
act_sessies_array = act_sessies_array.reverse

# write the new moving array
hash_total["act_sessies"] = act_sessies_array
output_string = hash_total.to_yaml
file = File.open("/var/www/LB/moving_array.log","w")
        file.write(output_string)
file.close

# Remove all non-attached volumes
Delete_Empty_Volumes()

# Need_restart: Indien recent geleden een instantie opgestart, dan dienen we na 5 min HaProxy te herstarten
# De 5 min gelden als start-up periode voor de instantie - in deze tijd wordt tomcat volledig opgestart
# ( Het opstarten van tomcat en het initieel aantal workers kan enkele minuten duren )
if ($need_restart>1)
	$need_restart = $need_restart -1;
	puts Time.now.to_s() + " - restarting HaProxy in " + $need_restart.to_s() + " min"
	file = File.open("/usr/scripts/need_restart.rb","w")
                file.puts("$need_restart="+$need_restart.to_s())
                file.puts("$need_rebalance=5")
        file.close
	exit
elsif ($need_restart == 1)
	puts Time.now.to_s() + " - restarted haproxy"
	%x[sudo haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)]
	file = File.open("/usr/scripts/need_restart.rb","w")
		file.puts("$need_restart=0")
		file.puts("$need_rebalance=5")
	file.close
	exit
end

# Need rebalancing of haproxy pool - zodat alle servers nu hetzelfde gewicht hebben
# Initieel krijgt de fresh booted server de eerste 5 min een gewicht van 1/5 de t.o.v. de overige
if ($need_rebalance>1)
	$need_rebalance = $need_rebalance - 1;
	puts Time.now.to_s() + " - rebalance HaProxy in " + $need_rebalance.to_s() + " min"
	file = File.open("/usr/scripts/need_restart.rb","w")
                file.puts("$need_restart=0")
                file.puts("$need_rebalance="+$need_rebalance.to_s())
        file.close
	exit
elsif ($need_rebalance == 1)
        puts Time.now.to_s() + " - Rebalancing haproxy pool"

	# Rebalance the haproxy pool - give al servers the same priority level (5)
	%x[sudo sed -ibak 's/weight 1/weight 5/g' /etc/haproxy/haproxy.cfg]        
	%x[sudo haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)]

        file = File.open("/usr/scripts/need_restart.rb","w")
                file.puts("$need_restart=0")
		file.puts("$need_rebalance=0")
        file.close
        exit
end

# retreive the pool of instances from a file
file = File.open("/var/www/LB/instances.log","r")
input_string = file.read 
file.close 

hash = YAML::load(input_string)
instances = hash["instances"] 

aantalInstances = 0
instancesArray = Array.new
instances.each do |instance|
	aantalInstances += 1
	instancesArray.push(instance)
end

# Bereken gemiddelde voor metrics - over de waardes van de laatste x minuten ( keuze tijdseenheid instelbaar )
act_sessies = 0

for i in 0..(moving_time-1)
	if (act_sessies_array[i] != nil)
		act_sessies += act_sessies_array[i]
	else
		act_sessies += 0
	end
end
act_sessies = act_sessies/(moving_time)
gem_act_sessies = act_sessies/aantalInstances

puts Time.now.to_s()+" - Totaal Actieve Sessies: "+act_sessies.to_s() +" - Actieve sessies per instance: "+ gem_act_sessies.to_s()

#puts "2. Evaluating the metrics to determine if instances must be started / stopped" 
#puts "3. Het starten / stoppen van instanties"

if ( gem_act_sessies >= bovenlimiet )
	# Start een of meerdere instanties op

   	if (aantalInstances < 11)
      		#puts "Starting a new instance"
		
		# Er kunnen maximaal 3 instanties ter zelfde tijd gestart worden.
                aantalNieuweInst = (gem_act_sessies/bovenlimiet).ceil
                if ( aantalNieuweInst > 3 )
                        aantalNieuweInst = 3
                end

		# Start the number of required instances
		# Do this concurrent -> The use of multiThreading is required!
	
                # Mark haproxy to be restarted within 5 min time.
                # This wil be picked up by the runs of algoritm 1 & 2 min afther this one. ( this one stays 3 min active ).
                file = File.open("/usr/scripts/need_restart.rb","w")
                        file.puts("$need_restart=5")
                        file.puts("$need_rebalance=5")
                file.close

		if (aantalNieuweInst == 1)
			newInstance = LaunchInstance($master_ip)
			if (newInstance == nil)
				exit	# Starten van instantie mislukt --> exit
			else
				instancesArray.push(newInstance[0])
                        	# Addapting HaProxy Config
	                        Add_IP(newInstance[0])		
			end
		elsif (aantalNieuweInst == 2 )
			thread_1 = Thread.new { 
				newInstance = LaunchInstance($master_ip)
				instancesArray.push(newInstance[0])
		                # Addapting HaProxy Config
		                Add_IP(newInstance[0])
	 		}
			thread_2 = Thread.new {
                                newInstance = LaunchInstance($master_ip)
                                instancesArray.push(newInstance[0])
                                # Addapting HaProxy Config
                                Add_IP(newInstance[0])
                        }
			thread_1.join
			thread_2.join
		else
                        thread_1 = Thread.new {
                                newInstance = LaunchInstance($master_ip)
                                instancesArray.push(newInstance[0])
                                # Addapting HaProxy Config
                                Add_IP(newInstance[0])
                        }
                        thread_2 = Thread.new {
                                newInstance = LaunchInstance($master_ip)
                                instancesArray.push(newInstance[0])
                                # Addapting HaProxy Config
                                Add_IP(newInstance[0])
                        }
                        thread_3 = Thread.new {
                                newInstance = LaunchInstance($master_ip)
                                instancesArray.push(newInstance[0])
                                # Addapting HaProxy Config
                                Add_IP(newInstance[0])
                        }
                        thread_1.join
                        thread_2.join
			thread_3.join
		end    		
	else
      		puts "There are already 12 instances running - cannot start a new one."
	end
elsif ( gem_act_sessies < onderlimiet )
	if ( aantalInstances > 1)
		#puts	"Stopping an instance"
		# Addapting HaProxy + gracefull restart
		Remove_IP(instances[1])
		#puts "restarting haproxy"
		%x[sudo haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)]

		#puts Stop_Server(instances[1])
		instancesArray.delete(instances[1])
   		puts "+Removed instance "+instances[1].to_s()   		
      	else
      		#puts "There is one single instance running. No need to stop instances." 
	end
else
	# puts "no action needed"
end
   
# save the pool of instances

hash_eind=Hash.new()
hash_eind["instances"] = instancesArray
output_string = hash_eind.to_yaml

file = File.open("/var/www/LB/instances.log","w")
file.write(output_string)
file.close 
#puts "-----------------------------------"
