#!/usr/bin/env ruby

# A. Monitor het actueel aantal actieve sessies
# De socket wordt meerdere malen bevraagd, om een nauwkeurigere waarde te bekomen.
# B. Monitor het totaal aantal actieve sessies, sinds de laatste herstart van haproxy.

require 'socket'

def getParameter()
def getAantalSessies()
socket = UNIXSocket.new("/tmp/haproxy")
socket.puts("show stat")

stats =""
while(line = socket.gets) do
  stats += line
end

# Parse stats om er het aantal actieve sessies uit te halen.
regExpr=/FRONTEND,\d*,\d*,(\d*),\d*,\d*,(\d*)/i
result = stats.scan(regExpr)
return result[0]
end

time = Time.now
totaalAantalSessies = Integer(getAantalSessies()[1])
huidigAantalSessies = Integer(getAantalSessies()[0])
sleep 5

for i in 0..7 do
	huidigAantalSessies += Integer(getAantalSessies()[0])
	sleep 5
end

huidigAantalSessies += Integer(getAantalSessies()[0])
# > In totaal zijn 10 samples genomen - telkens met 5 seconden tussen

# Schrijf de gegevens weg
# A. Gemiddelde van het aantal actieve sessies
file = File.open("/var/www/LB/csv/actieve_sessies.csv",'a+')

huidigAantalSessies = huidigAantalSessies / 10;
concatenated_tags = time.inspect + ";" + huidigAantalSessies.to_s()
file.puts concatenated_tags
file.close

# B. Totaal aantal sessies
file = File.open("/var/www/LB/csv/totaal_aantal_sessies.csv",'a+')
concatenated_tags = time.inspect + ";" + totaalAantalSessies.to_s()
file.puts concatenated_tags
file.close

return (huidigAantalSessies)
end


