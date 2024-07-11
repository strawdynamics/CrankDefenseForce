#!/bin/bash
PDXINFO="source/pdxinfo"
awk -F "=" '/buildNumber=/ {$2+=1} {print $1 "=" $2}' "$PDXINFO" > tmpfile && mv tmpfile "$PDXINFO"

pdc source crank-defense-force.pdx
open crank-defense-force.pdx
