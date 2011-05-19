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
	ip = hash[0][:private_ip_address]
	if (ip =="")
                return nil	
				# cfr. Fout waarbij instance_id niet kon omzetten worden naar IP adres'
        else
                return ip
        end
end
#-------------------------------------------------------------------

# Function to start a new server
def Start_New_Server(userdata)
	begin
	hash = @@ec2.launch_instances('ami-1cf20e75',   :min_count => 1,
                                                :max_count => 1,
                                                :group_ids=>'VRT-medialab',
                                                :key_name=>'VanhoorelbekeStijn',
                                                :user_data=>userdata,
						:instance_type=>'m1.large',
						:aws_availability_zone=>'us-east-1c')	
							# aws_availability_zone -> alle instanties binnen us-east-1c - zodat trafiek tussen instanties graties is.
								
							# instance_type
							 # t1.micro for quick&dirty testing ( only $0.02 / instance )
							 # m1.large for production tests
		
	rescue Exception => msg
		# When starting of an instance fails - the right_aws code will generate an exception
		# We need to be prepared to handle this exception nicely.
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

# Function to add the instance to the haproxy server pool
def Add_IP(instance_id)
        ip = Get_IP(instance_id)

        file = File.open("/etc/haproxy/haproxy.cfg",'a+')
        file.puts "#" + instance_id +"#"
        file.puts "server "+ instance_id + " " + ip + ":80 weight 1" 
		# initeel weight 1 -- will be highered to 5 after 5 minutes.
        file.puts "#" + instance_id +"#"

end
#-------------------------------------------------------------------

# Function to remove the instance from the haproxy server pool
def Remove_IP(instance_id)
        file = File.open("/etc/haproxy/haproxy.cfg",'r')
        content = ""
        file.each {|line|
          content << line
        }
        file.close

        regExpr = /##{instance_id}#\n.*\n##{instance_id}#/i
        content = content.gsub(regExpr,"")

        file = File.open("/etc/haproxy/haproxy.cfg",'w')
        file.puts content
        file.close
end
#-------------------------------------------------------------------

# Function to remove all non-attached volumed
def Delete_Empty_Volumes()
	hash = @@ec2.describe_volumes()
	hash.each do |volume|
		if ( volume[:aws_status] == "available" )
			@@ec2.delete_volume(volume[:aws_id])
		end
	end
	return "Deleted all 'non-attached' volumes"
end

#-------------------------------------------------------------------

#puts Get_IP('i-301a755d')
#puts Get_Belasting('174.129.51.177')
#puts Stop_Server('174.129.51.288')
#puts Delete_Empty_Volumes()
