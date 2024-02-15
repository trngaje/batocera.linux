#!/bin/sh

alsactl store 0 /userdata/system/.asound.state

/etc/init.d/rcK
sync

shutdown -Ph -t 3 now

