from __future__ import annotations

import filecmp
import os
import shutil
from os import environ
from os import path
import subprocess
from typing import TYPE_CHECKING

from ... import Command
from ...batoceraPaths import CONFIGS
from ...controller import generate_sdl_game_controller_config
from ..Generator import Generator

if TYPE_CHECKING:
    from pathlib import Path

    from ...types import HotkeysContext

class AdvMameGenerator(Generator):
    def getHotkeysContext(self) -> HotkeysContext:
        return {
            "name": "advmame",
            "keys": { "exit": "KEY_ESC" }
        }

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
  
        return Command.Command(array=commandArray, env={'SDL_GAMECONTROLLERCONFIG': generate_sdl_game_controller_config(playersControllers)})
