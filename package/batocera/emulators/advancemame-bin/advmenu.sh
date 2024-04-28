#!/bin/bash

#copy advance files to .advance
if [ ! -d "/userdata/system/.advance" ]; then
  mkdir -p /userdata/system/.advance
  #cp -r /usr/share/advance/* /userdata/system/.advance/
  tar -xvzf /usr/share/advance/advance.tar.gz -C /userdata/system/
fi

if [ ! -d "/userdata/system/runcommand" ]; then
  tar -xvzf /usr/share/runcommand/runcommand.tar.gz -C /userdata/system/
  chmod a+x /userdata/system/runcommand/runcommand.sh
fi

advmenu
