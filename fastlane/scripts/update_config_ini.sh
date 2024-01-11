#!/usr/bin/env bash

# Set a config property for an AVD. Requires env: EMULATOR_NAME
# @param $1 : property key
# @param $2 : new value
echo "SETTING $1 = $2"
if ! grep -R "^[#]*\s*$1=.*" ~/.android/avd/$EMULATOR_NAME.avd/config.ini > /dev/null; then
  # echo "APPENDING because '$1' not found"
  echo "$1=$2" >> ~/.android/avd/$EMULATOR_NAME.avd/config.ini
else
  # echo "SETTING because '$1' found already"
  sed -ir "s/^[#]*\s*$1=.*/$1=$2/" ~/.android/avd/$EMULATOR_NAME.avd/config.ini
fi