== Beschrijving
Set van scripts horende bij Architectuuropstelling 2.
Binnen deze architectuur werd de ZooKeeper functionaliteit gekoppeld met deze van Sorl via de SolrCloud functionaliteit.

De hier getoonde scripts omvatten de scripts inzake de losstaande Apache ZooKeeper instantie.
De getoonde scripts omvatten de initialisatie en opstart van de externe Apache ZooKeeper engine, evenals de volledige regelaar.

OPMERKING:
Architectuur 2 werd niet volledig ontwikkeld - de getoonde scripts zijn dan ook geenszins volledig.
Doch deze geven een indicatie over de werking van Apache ZooKeeper en illustreren de vereiste stappen om ZooKeeper operationeel te krijgen.

== Uitvoering:
1. Bij opstart van de instantie dient de ZooKeeper Server applicatie te worden gestart. 
   Dit verloopt via 'reboot.sh'.
2. Door middel van uitvoer van het script 'LB_StartUp.sh' kunnen alle vereiste componenten van Architectuur 2 opgestart worden.
3. De regelaar kan vervolgens worden opgestart via script 'LB.sh'

== Inhoud:
1. reboot.sh
Script om oude ZooKeeper configuratiedata te verwijderen, waarna ZooKeeper opstart.

2. LB_Functions.rb
Set van basisfuncties geschreven bovenop de RightScale Amazon Web Services Ruby Gems (right_aws).
Deze functies laten toe om op eenvoudige manier de Amazon EC2 API aan te spreken en commando's uit te voeren.
cfr. Functies om instanties te starten / IP-adres van een instantie op te vragen / Stoppen van een instantie / ...

3. LB_StartUp.sh en LB_StartUp.rb
Script om Architectuur 2 operationeel te krijgen. Dit betekent volgende:
+ De opstart van een Apache Solr Master instantie. [OPMERKING: Dit wordt gedurende de performantietesten niet gedaan]
+ Een Apache Sorl Slave instantie zal worden opgestart. 
  Het 'boot-script' voor deze instantie zal correct worden geconfigureerd, zodat het IP-adres van de Master instantie correct geconfigureerd wordt, evenals een groot aantal ZooKeeper gerelateerde instellingen.
+ Deze nieuwe instantie zal zich registreren bij de ZooKeeper Server en zal zijn set van Apaceh Solr configs uploaden naar ZooKeeper.

4. install_scr.rb
Template file inzake boot script voor nieuwe Apache Solr instanties. Dit boot script zal worden uitgevoerd net na de opstart van nieuwe Solr Slave instanties.
Dit script zal de ZooKeeper settings op de Slave instanties correct instellen.

5. LB.sh en LB.rb
Script dat de volledige regelaar bevat - LB.rb zal iedere 5 min tot uitvoer worden gebracht.
De regelaar hanteert volgende structuur:
+ Haal een lijst op van alle Slave instanties
+ Haal de statistieken voor de afgelopen 5 min op voor elke Slave instantie
+ Combineer de statistieken met historische cijfers ( statistieken van meer den 5 min geleden ).
+ Bereken de gemiddelde belasting over alle instanties
+ Start / Stop een instantie
+ Update de lijst van Slave instanties
