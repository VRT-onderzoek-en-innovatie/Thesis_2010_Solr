== Beschrijving:
Deze folder bevat alle scripts die uitgevoerd worden op elke Apache Solr instantie.
Deze scripts zullen een aantal belangrijke parameters van de instantie bemonsteren en de bemonsterde data wegschrijven naar een csv log.

Via de scripts kunnen volgende parameters bemonsterd worden:
 + Procentuele belasting CPU
 + Procentueel gebruik werkgeheugen
 + Het aantal actieve sessies (~ het aantal concurrente verzoeken in behandeling)
 + De gemiddelde uitvoeringstijd voor gebruikersverzoeken ( door middel van NewRelic ) [OPTIONEEL]

== Inhoud:
1. Monitoring_Scripts
	Folder met alle gebruikte scripts.
	
2. Voorbeelden_CSV_Logs
	Bevat verscheidene CSV logbestanden - deze tonen de te verwachten output van de scripts aan.
	
3. Voorbeelden_Temp_Files
	Bevat een kopie van de tijdelijke bestanden, die door het script gebruikt worden.