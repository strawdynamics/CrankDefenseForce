#! /bin/sh
set -e
(killall 'Playdate Simulator' || true) 2>/dev/null
swift package pdc
~/Developer/PlaydateSDK/bin/Playdate\ Simulator.app/Contents/MacOS/Playdate\ Simulator .build/plugins/PDCPlugin/outputs/CrankDefenseForce.pdx
