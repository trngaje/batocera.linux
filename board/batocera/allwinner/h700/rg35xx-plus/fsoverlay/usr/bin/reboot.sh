#!/bin/sh

alsactl store 0 /userdata/system/.asound.state

/etc/init.d/rcK
sync

reboot

