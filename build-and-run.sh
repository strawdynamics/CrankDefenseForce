#! /bin/sh
set -e
./build.sh
(killall 'Playdate Simulator' || true) 2>/dev/null
~/Developer/PlaydateSDK/bin/Playdate\ Simulator.app/Contents/MacOS/Playdate\ Simulator .build/plugins/PDCPlugin/outputs/CrankDefenseForce.pdx
