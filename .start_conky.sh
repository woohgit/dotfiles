#!/bin/bash

#cd ~/.conky/
LC_ALL=en_US.UTF-8 conky -c Gotham/Gotham &
cd ~/.conky/Conky\ Seamod
conky -c conky_seamod &
cd ~/repos/conkySimpleForecast/
#LC_ALL=en_US.UTF-8 conky -c conky_simpleforcast &
