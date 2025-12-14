#!/bin/bash
# PDXINFO="Sources/CrankDefenseForce/Resources/pdxinfo"
# awk -F "=" '/buildNumber=/ {$2+=1} {print $1 "=" $2}' "$PDXINFO" > tmpfile && mv tmpfile "$PDXINFO"

swift package pdc
