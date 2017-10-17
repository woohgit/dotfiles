#!/bin/bash

cd ~/.conky/
LC_ALL=en_US.UTF-8 conky -c Gotham/Gotham &
cd ~/.conky/Conky\ Seamod
conky -c conky_seamod &
