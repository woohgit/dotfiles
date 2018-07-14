#!/bin/bash
export LC_ALL=en_US.UTF-8

conky -c ~/.conky/Rings/rings & # the main conky with rings
sleep 8 #time for the main conky to start; needed so that the smaller ones draw above not below (probably can be lower, but we still have to wait 5s for the rings to avoid segfaults)
conky -c ~/.conky/Rings/cpu &
sleep 1
conky -c ~/.conky/Rings/mem &
conky -c ~/.conky/Rings/notes &
