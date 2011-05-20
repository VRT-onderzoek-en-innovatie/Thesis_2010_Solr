#!/bin/bash

sudo ruby /usr/scripts/LB_StartUp.rb
# Geef de server een weight 5 ( standaard weight ) - tijdens uitvoer regelaar zullen nieuwe servers tijdelijk weight 1 krijgen - hier is dit niet nodig.
sudo sed -ibak 's/weight 1/weight 5/g' /etc/haproxy/haproxy.cfg

sudo service haproxy restart
echo " Please wait some minutes for the first instance to fully load"
