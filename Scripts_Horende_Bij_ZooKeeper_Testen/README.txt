== Beschrijving
Set van scripts horende bij Architectuuropstelling 2.
Binnen deze architectuur werd de ZooKeeper functionaliteit gekoppeld met deze van Sorl via de SolrCloud functionaliteit.

De hier getoonde scripts omvatten de scripts inzake de losstaande Apache ZooKeeper instantie.
De getoonde scripts omvatten de initialisatie en opstart van de exteren Apache ZooKeeper engine, evenals de volledige regelaar.

OPMEKRING:
Architectuur 2 werd niet volledig ontwikkeld - de getoonde scripts zijn dan ook geenszins volledig.
Doch deze geven een indicatie over de werking van Apache ZooKeeper en illustreren de vereiste stappen om ZooKeeper operationeel te krijgen.

== Uitvoering:
1. Bij opstart van de instantie dient de ZooKeeper Server applicatie te worden gestart. Dit verloopt via 'reboot.sh'.
2. Door middel van uitvoer van het script 'LB_StartUp.sh' kunnen alle vereiste componenten van Architectuur 2 opgestart worden.
   Dit betekent volgende:
   + De opstart van een Apache Solr Master instantie.
   + Een Apache Sorl Slave instantie zal worden opgestart. 
   Het 'boot-script' voor deze instantie zal correct worden geconfigureerd, zodat het IP-adres van de Master instantie correct geconfigigureerd wordt, evenals een groot aantal ZooKeeper gerelateerde instellingen.
   + Deze nieuwe instantie zal zich registreren bij de ZooKeeper Server en zal zijn set van Apaceh SOlr configs uploaden naar ZooKeeper.
3. De regelaar kan vervolgens worden opgestart vai script 'LB.sh'

== Inhoud:
1. reboot.sh
Script om oude ZooKeeper configuratiedata te verwijderen, waarna ZooKeeper opstart.

2. LB_Functions.rb
Set van basisfuncties geschreven bovenop de RightScale Amazon Web Services Ruby Gems (right_aws).


require 'right_aws' rubygem