#!/usr/bin/env ruby

require 'rubygems'
require 'right_aws'
require 'yaml'
require 'net/http'
require 'LB_Functions.rb'

load 'install_scr.rb'

# Ruby script launched at boot time
# This script will prepare HAProxy & Solr for use

# 1. Start a fresh Apache Solr Master
userdata = userdata("master", "dummy")
new_master = Start_New_Server(userdata)
# Save instance_id master to file
file = File.open("/usr/scripts/master_ip.rb","w")
file.puts('$master_ip="'+new_master[1]+'"')
file.close

# 3. Start the first Slave instance
userdata = userdata("slave", new_master[1])	# Start Slave & geef IP-adres Master mee
puts "Starting new Solr instance"
new_instance = Start_New_Server(userdata)

if ( new_instance != nil )
	if ( new_instance[0] != nil && new_instance[1] != nil)
		puts "Started a new instance with id: "+new_instance[0]+" and ip: "+new_instance[1]
	end
else
	puts "Starting of a new instance was not successful!"
end

# 4. Adding instance to haproxy pool
puts "Starting from Clean haproxy config file."
puts "+ Resetting haproxy config"
%x[sudo cp /usr/scripts/haproxy_BootConfig.cfg /etc/haproxy/haproxy.cfg]

puts "Adding instance "+new_instance[0]+" to the haproxy pool"
Add_IP(new_instance[0])

# 5. Make new files, to reflect this fresh situation
# Writing new list of active instances.
output_hash = Hash.new("LB")
output_hash["instances"] = new_instance[0]
output_string = output_hash.to_yaml

file = File.open("/var/www/LB/instances.log","w")
file.write("# LB: List of all active instances and the corresponding IP-address\n");
file.write(output_string)
file.close

# Start from clean moving array - this is a sliding array who will contain the stats of the last 30 mins.
act_sessies_array = Array.new(30) {0}

output_hash = Hash.new("moving_array")
output_hash["act_sessies"] = act_sessies_array
output_string = output_hash.to_yaml

file = File.open("/var/www/LB/moving_array.log","w")
	file.write(output_string)
file.close

# No restart / rebalance needed
file = File.open("/usr/scripts/need_restart.rb","w")
	file.puts("$need_restart=0")
        file.puts("$need_rebalance=0")
file.close
