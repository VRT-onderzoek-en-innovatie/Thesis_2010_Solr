#!/usr/bin/env ruby

# Script dat de gemiddelde responstijd ( -8 min <--> -2 min ) ophaalt via NewRelic REST API
# Opmerking:
# A. Eerst dient - op basis van de unieke applicatienaam ( bootstrap script zet deze naam uniek ) - een applicatienummer bekomen te worden
# Via dit nummer kan men de API verder bevragen.

#B.  Deze gegevens komen niet onmiddelijk beschikbaar. Er is dus nood aan een degelijke controle of de gegevens wel beschikbaar zijn.

load '/usr/Monitoring_Script/settings.rb'

if $app_id==nil
	# Still need to resolve app_name --> app_id 

	# Access to account 26374 with specified api_key
	`sudo wget -O/var/www/monitoring/temp/NewRelic_applications.xml "https://rpm.newrelic.com/accounts/35866/applications.xml?api_key=f70746fb1cb72ab9711bde5bbf8f8704a7d44164b876212"`
	
	# Retrieve machine id from xml
	file = File.open("/var/www/monitoring/temp/NewRelic_applications.xml", "r")
	content = file.read
	file.close
	
	regExpr=/<id type="integer">(\d*)<\/id>.*<name>#{$app_name}<\/name>/m
	app_id = content.scan(regExpr)
	if app_id.empty? == true
		# Do nothing
	else
		$app_id = app_id[0][0]
		# Store app_id
        	file = File.open("/usr/Monitoring_Script/settings.rb", "a")
		file.puts "$app_id = "+ $app_id	
	        file.close
	end
end

if $app_id==nil
	# Do nothing
	respons_time=0
else
	# Retreive the Average Respons Time for the machine
	command = "`sudo wget -O/var/www/monitoring/temp/NewRelic_values.xml http://rpm.newrelic.com/accounts/35866/applications/"+$app_id.to_s()+"/threshold_values.xml?api_key=f70746fb1cb72ab9711bde5bbf8f8704a7d44164b876212`"

	eval(command)
	# Retrieve metrics
        file = File.open("/var/www/monitoring/temp/NewRelic_values.xml", "r")
        content = file.read
        file.close

        regExpr=/<threshold_value metric_value="(\d*[.]?\d?)" formatted_metric_value="\S* ms" begin_time="\S* \S*" end_time="\S* \S*" name="Response Time" threshold_value="\S*"\/>/i
        respons = content.scan(regExpr)
	respons_time = respons[0][0]
end

# save respons time to file
file = File.open("/var/www/monitoring/temp/temp_respons_time.log", "a")
time = Time.now
concatenated_tags = "#" + time.inspect + "# "+ respons_time
file.puts concatenated_tags
file.close

file = File.open("/var/www/monitoring/csv/respons_time.csv", "a")
concatenated_tags = Time.now.inspect + ";"+ respons_time
file.puts concatenated_tags
file.close

