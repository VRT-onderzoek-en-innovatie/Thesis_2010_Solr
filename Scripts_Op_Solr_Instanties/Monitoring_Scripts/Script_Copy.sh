#!/bin/bash
# echo "----------------------------------------------------------------------------------------"
# echo "Script om de resultaten uit temp files over te kopieren"
# echo "Zodoende bevatten de hoofdfiles 5 min lang dezelfde data ( gegevens over vorige 5 min )"
# echo "----------------------------------------------------------------------------------------"

# Wacht 10 seconden - opdat monitoring job ( die elke min loopt ) VOLLEDIG uitgevoerd is.
sleep 10

# leeg hoofdfile
> /var/www/monitoring/Stats_YAML.log

# verwerk gegevens via RUBY & creatie van een YAML hash file
sudo ruby /usr/Monitoring_Script/Script_Copy.rb

# leeg temp
> /var/www/monitoring/temp/temp_CPU.log
> /var/www/monitoring/temp/temp_memory.log
> /var/www/monitoring/temp/temp_act_sessies.log
#> /var/www/monitoring/temp/temp_respons_time.log

# --> Stats_YAML.log bevat de statistieken over de afgelopen 5 min ( de inhoud blijft 5 min constant )

