#!/bin/sh

TARGET_DIR="/userdata/bios"
PICO_DIR="$TARGET_DIR/pico-8"
ROMS_DIR="/userdata/roms/pico8"
TEMP_INSTALL_DIR="$ROMS_DIR/pico8-install"

PICO_8_64_FILE="$TEMP_INSTALL_DIR/pico-8/pico8_64"
PICO_8_DYN_FILE="$TEMP_INSTALL_DIR/pico-8/pico8_dyn"
PICO_8_GPIO_FILE="$TEMP_INSTALL_DIR/pico-8/pico8_gpio"
PICO_8_DAT_FILE="$TEMP_INSTALL_DIR/pico-8/pico8.dat"

PICO_8_ES_SYSTEMS_CONFIG=/usr/share/emulationstation/es_systems_pico8.cfg.install
SPLORE_FILE="$ROMS_DIR/Splore.png"

PICO_8_ZIPFILE=$(ls -d /userdata/roms/pico8/pico-8*raspi*.zip 2>/dev/null | head -1)

if [ -z $PICO_8_ZIPFILE ] || [ ! -f "$PICO_8_ZIPFILE" ]; then
  echo "Please add the Raspberry Pi version of Pico-8 to roms/pico8 and try again."
  exit 0
fi

if [ ! -f "$PICO_8_ES_SYSTEMS_CONFIG" ]; then
  echo "Unable to install Pico-8: $PICO_8_ES_SYSTEMS_CONFIG missing."
  exit 0
fi

if [ -d "$PICO_DIR" ]; then
    echo "Pico-8 is already installed at $PICO_DIR."
    echo "If you want to reinstall Pico-8, please remove the Pico-8 folder from your BIOS folder."
    exit 0
fi

# Unzip Pico-8
mkdir "$TEMP_INSTALL_DIR"
unzip "$PICO_8_ZIPFILE" -d "$TEMP_INSTALL_DIR"

# Make sure all required files have been unpacked.
if [ ! -f $PICO_8_64_FILE ]; then
  echo "Unable to install Pico-8: $PICO_8_64_FILE missing."
  exit 0
fi

if [ ! -f $PICO_8_DYN_FILE ]; then
  echo "Unable to install Pico-8: $PICO_8_DYN_FILE missing."
  exit 0
fi

if [ ! -f $PICO_8_GPIO_FILE ]; then
  echo "Unable to install Pico-8: $PICO_8_GPIO_FILE missing."
  exit 0
fi

if [ ! -f $PICO_8_DAT_FILE ]; then
  echo "Unable to install Pico-8: $PICO_8_DAT_FILE missing."
  exit 0
fi

# Create BIOS folder.
mkdir $PICO_DIR
echo "Created BIOS folder for Pico-8."

# Move Pico8 files to destination
mv $PICO_8_64_FILE "$PICO_DIR/pico8"
mv $PICO_8_DYN_FILE "$PICO_DIR/"
mv $PICO_8_GPIO_FILE "$PICO_DIR/"
mv $PICO_8_DAT_FILE "$PICO_DIR/"
echo "Installed Pico-8 BIOS files."

# Make executable executable
chmod +x "$PICO_DIR/pico8"
echo "Set Pico-8 to be executable."

# Install ES Systems Pico-8 config
TARGET_FILE="/userdata/system/configs/emulationstation/es_systems_pico8.cfg"
cp $PICO_8_ES_SYSTEMS_CONFIG $TARGET_FILE
echo "Installed emulator configuration for standalone Pico-8."

if [ ! -f "$SPLORE_FILE" ]; then
    echo "Splore" > "$SPLORE_FILE"
    echo "Created file $SPLORE_FILE"
else
    echo "File $SPLORE_FILE already exists"
fi

rm -r $TEMP_INSTALL_DIR
echo "Removed temporary installation files."

rm $PICO_8_ZIPFILE
echo "Removed Pico8 zip file."

batocera-settings-set "pico8.core" "pico8_official"
batocera-settings-set "pico8.emulator" "lexaloffle"
echo "Set up Pico-8 as default emulator for Pico-8 games."

sleep 2

curl http://localhost:1234/reloadgames
echo "Games reloaded - installation done."

exit 0
