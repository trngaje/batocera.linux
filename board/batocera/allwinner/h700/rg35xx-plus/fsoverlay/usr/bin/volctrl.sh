#!/bin/sh

name='lineout volume'

value=$(amixer sget "$name" | sed -n "s/  Mono: \([0-9]*\) .*/\1/p")

if [[ "$1" == "up" ]]; then
        let value=value+5
        if [[ $value -gt 31 ]]; then value=31; fi
else
        let value=value-5
        if [[ $value -lt 0 ]]; then value=0; fi
fi

amixer sset "$name" $value

