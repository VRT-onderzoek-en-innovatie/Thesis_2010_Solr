#!/usr/bin/env ruby

require 'rubygems'
require 'right_aws'
require 'yaml'
require 'net/http'

# Function to get the acces_key
def get_Access_Key_id()
	return "####ACCESS_KEY####"
end
# Function to get the secret_key
def get_Secret_Key()
	return "####SECRET_KEY####"
end
#-------------------------------------------------------------------

# Class variable - alle verzoeken naar Amazon gebeuren via dit object
@@ec2=RightAws::Ec2.new(get_Access_Key_id(),get_Secret_Key(),{:port => 80, :protocol => 'http', :logger => Logger.new('/dev/null')}) 

#-------------------------------------------------------------------

# Function to retreive the IP of the instance
def Get_IP(instance_id)
	hash = @@ec2.describe_instances(instance_id)
	ip = hash[0][:ip_address]
	if (ip =="")
                return nil	# Kon instance_id niet omzetten naar IP adres
        else
                return ip
        end
end
#-------------------------------------------------------------------

# Function to retreive the performance metrics of the last 5 min
def Get_Belasting(instance_ip)
	begin
	yaml = ""
	Net::HTTP.start(instance_ip) { |http|
		resp = http.get("/monitoring/Stats_YAML.log")
		yaml = resp.body
	}
	
	hash = YAML::load(yaml)

	error = Hash.new()
	error["act_sessies"]=[0,0,0,0,0]
        error["memory"]=[0,0,0,0,0]
        error["cpu"]=[0,0,0,0,0]
        error["respons_time"]=[0,0,0,0,0]

	rescue Exception => msg
		return Error
	end	
	
	# Controle op valide informatie	
	if ( hash != false )
		if ( hash["act_sessies"] != nil && hash["memory"] != nil && hash["cpu"] != nil && hash["respons_time"] != nil )
			return hash
		else
			return error
		end
	else
		return error		
	end
end
#-------------------------------------------------------------------

# Function to start a new server
def Start_New_Server(userdata)
	begin
	hash = @@ec2.launch_instances('ami-884dbee1',   :min_count => 1,
                                                :max_count => 1,
                                                :group_ids=>'VRT-medialab',
                                                :key_name=>'VanhoorelbekeStijn',
                                                :user_data=>userdata,
						:instance_type=>'m1.large')
	rescue Exception => msg
		# When starting of an instance fails - the right_aws code will generate an exception
		# We need to be prepared to handle this exception nicely.
		# puts "There was an exception: "+msg
		return nil
	end
		# sleep 120 seconds to be sure the instance is fully started and the ip is available
		sleep(120) 	

		instance_id = hash[0][:aws_instance_id]
		instance_ip = Get_IP(instance_id)
		
		return_array = [instance_id, instance_ip]
		return return_array
end
#-------------------------------------------------------------------

# Function to stop a server
def Stop_Server(instance_id)
	begin
	hash = @@ec2.terminate_instances(instance_id)
	rescue Exception => msg
		return msg
	end

	if ( hash[0][:aws_shutdown_state] = "shutting-down" )
		return "shutting-down"
	else
		return nil
	end
end
#-------------------------------------------------------------------
#-------------------------------------------------------------------

#puts Get_IP('i-5b2c2837')
#puts Get_Belasting('174.129.51.177')
#puts Stop_Server('174.129.51.288')

