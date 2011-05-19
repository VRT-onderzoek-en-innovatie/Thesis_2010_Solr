#!/usr/bin/ruby
require 'yaml'
require 'time'

def getGegevens()

file = File.open("/var/www/monitoring/temp/server-status.log", "r")
content = file.read
file.close

# Extract het aantal concurrente sessies
regExpr=/BusyWorkers: (\d*[.]*\d*)/i
act_sessies = content.scan(regExpr)

file = File.open("/var/www/monitoring/temp/temp_act_sessies.log",'a+')
time = Time.now
concatenated_tags = "#" + time.inspect + "# "+ act_sessies[0][0]
file.puts concatenated_tags
file.close

return act_sessies[0][0]
end

getGegevens()