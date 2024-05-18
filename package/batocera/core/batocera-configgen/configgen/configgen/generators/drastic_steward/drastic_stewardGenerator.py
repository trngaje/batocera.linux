#!/usr/bin/env python

import Command
from generators.Generator import Generator
import controllersConfig
import shutil
from shutil import copyfile
import subprocess
from subprocess import Popen
import filecmp
import configparser
import os
import sys
import settings
from os import environ

class Drastic_stewardGenerator(Generator):

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):

        drastic_steward_root = "/userdata/system/drastic"
        drastic_steward_bin = "/userdata/system/drastic/launch.sh"
        drastic_steward_conf = "/userdata/system/drastic/config/drastic.cfg"

        if not os.path.exists(drastic_steward_root):
            os.makedirs(drastic_steward_root, exist_ok = True)
            os.system("cp -rv /usr/share/drastic_steward/* /userdata/system/drastic")
            #os.system("ln -s -f /userdata/saves/nds/drastic/backup /userdata/system/drastic/backup")
            #os.system("ln -s -f /userdata/saves/nds/drastic/savestates  /usrerdata/system/drastic/savestates")
     
        if not os.path.exists("/userdata/saves/nds/drastic/backup"):
            os.makedirs("/userdata/saves/nds/drastic/backup", exist_ok = True)
            
        if not os.path.exists("/userdata/saves/nds/drastic/savestates"):
            os.makedirs("/userdata/saves/nds/drastic/savestates", exist_ok = True)
                       
        os.chdir(drastic_steward_root)
        commandArray = [drastic_steward_bin, rom]
        #/userdata/system/drastic/launch.sh
        return Command.Command(
            array=commandArray,
            env={
                'DISPLAY': '0.0',
            })

