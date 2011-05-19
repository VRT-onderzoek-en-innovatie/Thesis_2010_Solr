== Beschrijving:
De tijdelijke bestanden benodigd voor de werking van de scripts.

== Inhoud:
1. NewRelic_applications.xml
Deze XML werd bekomen via de NewRelic REST API.
Deze XML toont aan dat bij NewRelic een instantie geregistreerd is (met ID 340004). 
Het ID van deze instantie zal gebruikt worden in stap 2. om alle informatie op te vragen over deze instantie.

2. NewRelic_values.xml
Deze XML werd bekomen via de NewRelic REST API - dit door de statistieken voor de applicatie met ID uit 1. op te vragen.
Deze XML bevat de gemiddelde responstijd ( van de afgelopen 6 minuten ) voor de instantie.

3. server-status.log
Kopie van de Apache Server-status pagina.
Uit deze kopie kunnen we afleiden dat er slechts een gebruikersverzoek in behandeling was ( BusyWorkers: 1).

4. temp_act_sessies.log
Tijdelijk bestand dat het aantal concurrente gebruikersverzoeken bevat. 
Dit aantal werd bekomen door de server-status (3.) te verwerken.

5. temp_CPU.log

6. temp_memory.log
