== Beschrijving:
Deze folder bevat alle scripts die uitgevoerd worden op elke Apache Solr instantie.
Deze scripts zullen een aantal belangrijke parameters van de instantie bemonsteren en de bemonsterde data wegschrijven naar een csv log.

Via de scripts kunnen volgende parameters bemonsterd worden:
 + Procentuele belasting CPU
 + Procentueel gebruik werkgeheugen
 + Het aantal actieve sessies (~ het aantal concurrente verzoeken in behandeling)
 + De gemiddelde uitvoeringstijd voor gebruikersverzoeken ( door middel van NewRelic ) [OPTIONEEL]

== Uitvoering:
De uitvoering van de scripts wordt geregeld door middel van Crontab. Onderstaande toont de geregistreerde Crontab tasks.

*/1 * * * * /usr/Monitoring_Script/Script_Monitoring.sh
*/5 * * * * /usr/Monitoring_Script/Script_Copy.sh

== Inhoud:
1. Script_Monitoring.sh 
Dit script zal iedere minuut de parameters CPU, geheugen en aantal actieve sessies bemonsteren.
( De parameters NewRelic responstijd en DISK I/O worden niet bemonsterd, maar staan in commentaar vermeld. )

2. Script_active_sessies.rb
Dit script zal uit de output van Apache server-status pagina het aantal concurrente gebruikers filteren.

3. Script_NewRelic.rb 
Script om de gemiddelde responstijd via de NewRelic REST API op te vragen.
De REST API kan bevraagd worden met behulp van een uniek applicatie ID. Dit ID wordt bijgehouden in settings.rb .

4. Script_Copy.sh en Script_Copy.rb
Dit script zal iedere 5 minuten uitgevoerd worden met behulp van Crontab.
Dit script zal de bemonsterde waardes van de afgelopen vijf minuten verzamelen tot een gestructureerde hash (zoals weergegeven in Stats_YAML.log).