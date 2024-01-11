#!/usr/bin/env bash

# power down the avd
$ANDROID_HOME/platform-tools/adb shell reboot -p

echo "Waiting for emulator to power off"
offline=false
n=0
while [ $offline = false ]
do
  device=$($ANDROID_HOME/platform-tools/adb devices | egrep -o  'emulator-(\d+)')
  if [ $device ]
    then
      n=$((n + 1))
      sleep 1
  else
    echo "Emulator offline ($n sec)"
    offline=true
  fi
  if [ $n -gt 10 ]
    then
      echo "This is taking too long, Kill all devices"
      for device in $($ANDROID_HOME/platform-tools/adb devices | egrep -o  'emulator-(\d+)')
      do
        $ANDROID_HOME/platform-tools/adb -s $device emu kill
      done
      offline=true
  fi
done
sleep $n