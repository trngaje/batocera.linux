from __future__ import annotations

import filecmp
import os
import shutil
from os import environ
import subprocess
from typing import TYPE_CHECKING

from ... import Command
from ...batoceraPaths import CONFIGS
from ...controller import generate_sdl_game_controller_config
from ..Generator import Generator

if TYPE_CHECKING:
    from pathlib import Path

    from ...types import HotkeysContext

class Drastic_stewardGenerator(Generator):

    def getHotkeysContext(self) -> HotkeysContext:
        return {
            "name": "drastic",
            "keys": { "exit": "KEY_ESC" }
        }

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):

        drastic_steward_root = "/userdata/system/drastic"
        drastic_steward_bin = "/userdata/system/drastic/launch.sh"
        drastic_steward_conf = "/userdata/system/drastic/config/drastic.cfg"

        board = os.popen("cat /boot/boot/batocera.board").read()
        board=board.rstrip("\n\r ")

        if os.path.isfile(drastic_steward_root + "/batocera.board"):
            board_installed = os.popen("cat " + drastic_steward_root + "/batocera.board").read()
            board_installed = board_installed.rstrip("\n\r ")
        else:
            board_installed = ""
            
        if (not os.path.exists(drastic_steward_root)) or (board != board_installed):
            os.makedirs(drastic_steward_root, exist_ok = True)
            os.system("cp -rv /usr/share/drastic_steward/* /userdata/system/drastic")
            if os.path.exists("/usr/share/drastic_steward/devices/" + board ):
                os.system("cp -rv /usr/share/drastic_steward/devices/" + board + "/* /userdata/system/drastic")
            os.system("cp /boot/boot/batocera.board /userdata/system/drastic")

        if not os.path.exists("/userdata/saves/nds/drastic/backup"):
            os.makedirs("/userdata/saves/nds/drastic/backup", exist_ok = True)

        if not os.path.exists("/userdata/saves/nds/drastic/savestates"):
            os.makedirs("/userdata/saves/nds/drastic/savestates", exist_ok = True)

        os.chdir(drastic_steward_root)
        commandArray = [drastic_steward_bin, rom]
        return Command.Command(
            array=commandArray,
            env={
                'DISPLAY': '0.0',
                'LIB_FB': '3',
                'SDL_GAMECONTROLLERCONFIG': generate_sdl_game_controller_config(playersControllers)
            })

