#!/usr/bin/ruby
require 'yaml'


def getGegevens(keuze,regularExpr)
# keuze: CPU of memory
# regularExpr: De regularExpr benodigd voor verwerking

file = File.open("/var/www/monitoring/temp/temp_" + keuze + ".log", "r")
content = file.read
file.close

# Extract date & time
regExpr=/#([\w\d\s:+?]*)#/i
time = content.scan(regExpr)

# Extract belasting
result = content.scan(regularExpr)

belastingArray = Array.new
file = File.open("/var/www/monitoring/csv/" + keuze + ".csv",'a+')
for i in 0 .. result.length-1 do
	innerArray = result[i]
	if (keuze == "CPU")
		belasting = Integer(innerArray[0]) + Integer(innerArray[1])
	elsif (keuze == "memory")
		belasting = innerArray[1].to_f / Integer(innerArray[0]).to_f * 100
	else
                belasting = Integer(innerArray[0])
	end
	belastingArray.push((belasting * 10**2).round.to_f / 10**2 )

	concatenated_tags = time[i][0] + ";"+ ((belasting * 10**2).round.to_f / 10**2).to_s()
        file.puts concatenated_tags
end
file.close

return belastingArray
end

regularExpr = /wa\w*\s*\d*\s*\d*\s*\d*\s*\d*\s*\d*\s*\d*\s*\d*\s*\d*\s*\d*\s*\d*\s*\d*\s*\d*\s*(\d*)\s*(\d*)\s*(\d*)\s*(\d*)\s/i
gegevensCPU = getGegevens("CPU",regularExpr)

regularExpr = /Mem:\s*(\d*)\s*(\d*)\s*(\d*)\s*(\d*)\s*(\d*)\s*(\d*)/i
gegevensMemory = getGegevens("memory",regularExpr)

regularExpr = /# (\d*)/i
gegevensActSessies = getGegevens("act_sessies",regularExpr)

#regularExpr = /# (\d*)/i
#gegevensResponsTime = getGegevens("respons_time",regularExpr)

output_hash = Hash.new("gegevens")
output_hash["cpu"] = gegevensCPU
output_hash["memory"] = gegevensMemory
output_hash["act_sessies"] = gegevensActSessies
#output_hash["respons_time"] = gegevensResponsTime
output_string = output_hash.to_yaml

file = File.open("/var/www/monitoring/Stats_YAML.log", "w")
file.write(output_string)
file.close
