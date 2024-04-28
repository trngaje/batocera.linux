#!/bin/bash

GMUPATH="/userdata/system/configs/gmu"
GMUCONFIG="${GMUPATH}/gmu.conf"
GMUINPUT="${GMUPATH}/gmuinput.conf"

if [ -d "/userdata/system/.local/share/gmu" ]
then
  rm -rf /userdata/system/.local/share/gmu
fi


FBHEIGHT="$(fbheight)"
FBWIDTH="$(fbwidth)"

if [ ! -d "${GMUPATH}" ]
then
  mkdir -p ${GMUPATH}
fi

cp -rf /usr/share/gmu/* ${GMUPATH}
ln -sf ${GMUPATH}/playlists /userdata/system/.local/share/gmu

cd /usr/share/gmu
/usr/bin/gmu.bin -d /userdata/system/configs/gmu -c /userdata/system/configs/gmu/gmu.conf
