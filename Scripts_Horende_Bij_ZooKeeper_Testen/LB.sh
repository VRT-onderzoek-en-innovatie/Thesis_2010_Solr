#!/bin/bash


while true; do
	sudo ruby /usr/scripts/LB.rb >> /var/www/LB/algoritm.log
	sleep 300
done

