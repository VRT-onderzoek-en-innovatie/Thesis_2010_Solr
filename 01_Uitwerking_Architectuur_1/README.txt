== Beschrijving
Definitieve set van scripts horende bij Architectuuropstelling 1 (opgebouwd rond een centrale HAProxy load balancer).

De hier getoonde scripts omvatten de scripts inzake de losstaande Apache HAProxy instantie.
De getoonde scripts omvatten de initialisatie en opstart van de Apache HAProxy instantie evenals de opstart van alle componenten vereist voor Architectuur 1.

== Uitvoering:
1. De volledige architectuur kan opgestart worden met behulp van script 'LB_StartUp.sh'
2. Door middel van Crontab wordt de regelaar iedere minuut uitgevoerd ( script 'LB.sh' ).

== Inhoud:
1. haproxy_BootConfig.cfg
Een clean configuratie van HAProxy - bij opstart van de architectuur zal deze clean configuratie gebruikt worden.

2. install_scr.rb
Script ter creatie van boot scripts inzake de Apache Sorl Slaves. Deze userdata sectie zal uitgevoerd worden net na opstart van de Slave instanties.
Deze userdata sectie is bedoeld om de Apache Solr instantie ofwel in te stellen als Master of als Slave instantie.

3. LB_Functions.rb
Set van basisfuncties geschreven bovenop de RightScale Amazon Web Services Ruby Gems (right_aws). Deze functies laten toe om op eenvoudige manier de Amazon EC2 API aan te spreken en commando's uit te voeren. cfr. Functies om instanties te starten / IP-adres van een instantie op te vragen / Stoppen van een instantie / ...

4. LB_StartUp.sh en LB_StartUp.rb
Script dat Architectuur 1 volledig opstart. Dit omvat:
+ de opstart van een Apache Solr Master instantie.
+ de opstart van een Apache Solr Slave instantie & de koppeling van deze instantie met de Master.
+ de initialisatie van de HAProxy load balancer, zodat deze verwijst naar de net aangemaakte Slave instantie.

4. getParameter.rb
Dit script zal het actueel aantal actieve sessies (~ aantal concurrente gebruikers op de architectuur) bemonsteren via de HAProxy socket.
Tevens wordt het totaal aantal actieve sessies - sinds de laatste restart van HAProxy bemeten.
De informatie over het actueel aantal actieve sessies zal gebruikt worden als input voor de regelaar.

5. LB.sh en LB.rb (~ de regelaar)
Dit script omvat de eigenlijke regelaar. Dit omhelst verschillende stappen:
+ het binnenhalen van de informatie over het actueel aantal actieve sessies van de afgelopen minuut (via script 4.)
+ berekenen van de gemiddelde belasting over alle actieve Slave instanties heen - dit is een gewogen gemiddelde over x minuten van de hierboven bemeten parameter.
+ Beslissingsregel om instanties te starten / te stoppen.
+ Het starten van een of meerdere (2 of 3) instanties / Het stoppen van een instantie / Geen actie vereist.
+ Update van de nieuwe lijst van Slave instanties.

6. need_restart.rb
Opslag variabelen die aanduiden of de HAProxy load balancer dient herstart te worden.

7. master_ip.rb
Bevat het private IP-adres van de Apache Solr Master. Dit IP-adres zal gebruikt worden in de userdata sectie van nieuwe Slave instanties.
