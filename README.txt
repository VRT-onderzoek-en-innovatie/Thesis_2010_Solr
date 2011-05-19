== Beschrijving
Deze repository bevat alle broncode horende bij de Thesis 'Schaalbaar zoeksysteem door middel van Cloud Computing'	

== Inhoud
1. Monitoring_Solr_Slave
Deze folder bevat alle scripts die uitgevoerd worden op elke Apache Solr instantie.
Deze scripts zullen een aantal belangrijke parameters van de instantie bemonsteren en de bemonsterde data wegschrijven naar een csv log.

2. Uitwerking_Architectuur_1
Definitieve set van scripts horende bij Architectuuropstelling 1 (opgebouwd rond een centrale HAProxy load balancer).
Deze repository bevat de eindversie van de regelaar.

3. Uitwerking_Architectuur_2
Set van scripts horende bij Architectuuropstelling 2.
Binnen deze architectuur werd de ZooKeeper functionaliteit gekoppeld met deze van Sorl via de SolrCloud functionaliteit.

OPMERKING:
Architectuur 2 werd niet volledig ontwikkeld - de getoonde scripts zijn dan ook geenszins volledig.
Doch deze geven een indicatie over de werking van Apache ZooKeeper en illustreren de vereiste stappen om ZooKeeper operationeel te krijgen.