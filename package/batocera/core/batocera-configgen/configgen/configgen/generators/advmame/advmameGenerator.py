#!/usr/bin/env python

from generators.Generator import Generator
import batoceraFiles
import Command
import shutil
import os
from utils.logger import get_logger
from os import path
from os import environ
import configparser
from xml.dom import minidom
import codecs
import shutil
import utils.bezels as bezelsUtil
import subprocess
from xml.dom import minidom
from PIL import Image, ImageOps
from pathlib import Path
import csv
import controllersConfig

class AdvMameGenerator(Generator):

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        # Extract "<romfile.zip>"
        romBasename = path.basename(rom)
        romDirname  = path.dirname(rom)

        board = os.popen("cat /boot/boot/batocera.board").read()
        board = board.rstrip("\n\r ")

        if os.path.isfile("/userdata/system/.advance/batocera.board"):
            board_installed = os.popen("cat /userdata/system/.advance/batocera.board").read()
            board_installed = board_installed.rstrip("\n\r ")
        else: 
            board_installed = ""
        if (not os.path.exists('/userdata/system/.advance')) or (board != board_installed):
            # mkdir -p /userdata/system/.advance
            # tar -xvzf /usr/share/advance/advance.tar.gz -C /userdata/system/
            os.system("tar -xvzf /usr/share/advance/advance.tar.gz -C /userdata/system/")
            if os.path.exists("/usr/share/advance/devices/" + board):
                os.system("cp -rv /usr/share/advance/devices/" + board + "/* /userdata/system/.advance")
            os.system("cp /boot/boot/batocera.board /userdata/system/.advance")
            
        if not os.path.exists('/userdata/system/runcommand'):
            #tar -xvzf /usr/share/runcommand/runcommand.tar.gz -C /userdata/system/
            #chmod a+x /userdata/system/runcommand/runcommand.sh
            os.system("tar -xvzf /usr/share/runcommand/runcommand.tar.gz -C /userdata/system/")
            os.system("chmod a+x /userdata/system/runcommand/runcommand.sh")
            
        commandArray =  [ "/usr/bin/advmame" ]
        commandArray += [ os.path.splitext(romBasename)[0] ]
  
        return Command.Command(array=commandArray, env={'SDL_GAMECONTROLLERCONFIG': controllersConfig.generateSdlGameControllerConfig(playersControllers)})
