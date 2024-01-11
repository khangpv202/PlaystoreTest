#!/usr/bin/env bash

echo "Install AVD files"
if [ $API -gt 30 ]
then
  export PACKAGE="system-images;android-${API};google_apis;x86_64"
  export ABI="google_apis/x86_64"
else
  export PACKAGE="system-images;android-${API};google_apis;x86"
  export ABI="google_apis/x86"
fi

# Install AVD files
# $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --update --proxy=https --proxy_host=webproxy.infra.backbase.cloud --proxy_port=8888
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --install $PACKAGE #--proxy=https --proxy_host=webproxy.infra.backbase.cloud --proxy_port=8888

# list available emulators
# $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager list
# $ANDROID_HOME/emulator/emulator -list-avds
# $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager delete avd -n $EMULATOR_NAME

export EMULATOR_NAME="${EMULATOR}_API_${API}"

# Create emulator
if [ -d ~/.android/avd/$EMULATOR_NAME.avd ]
then
  echo "$EMULATOR_NAME exists"
else
  echo "Creating emulator $EMULATOR_NAME"
# $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager -h create avd
  $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager -s create avd -k "$PACKAGE" -n "$EMULATOR_NAME" -f -b "$ABI" -d "$EMULATOR"
fi

echo "Update the config.ini to improve testing"
# Set hw.keyboard to yes; need a physical keyboard to disable soft keyboard
sh scripts/update_config_ini.sh "hw.keyboard" "yes"

# Increase storage so we have enough for video recordings
sh scripts/update_config_ini.sh "disk.dataPartition.size" "2G"
sh scripts/update_config_ini.sh "sdcard.size" "128G"

# Ensure the emulator cold boots
#sh scripts/update_config_ini.sh "fastboot.forceColdBoot" "yes"
#sh scripts/update_config_ini.sh "fastboot.forceFastBoot" "no"

echo "Printing config.ini values >>>"
cat ~/.android/avd/$EMULATOR_NAME.avd/config.ini
echo "<<< config.ini End"

# Start emulator in background
# no-snapshot-save when loading an emulator from snapshot state do not save at the end of session.
echo "Starting emulator ${EMULATOR_NAME}"
nohup $ANDROID_HOME/emulator/emulator -avd $EMULATOR_NAME -cache ~/.android/avd/$EMULATOR_NAME.avd/cache.img -no-snapshot -no-window -no-audio -no-boot-anim -accel on -wipe-data > /dev/null 2>&1 & sleep 5s

"${ANDROID_HOME}"/platform-tools/adb devices

#workaround for runner performance issues - https://github.com/actions/virtual-environments/issues/3719

echo y | find ~/.android

echo 'config.ini'
        cat ~/.android/avd/$EMULATOR_NAME.avd/config.ini
        echo 'hw.ramSize=4096MB' >> ~/.android/avd/$EMULATOR_NAME.avd/config.ini
        echo '== config.ini modified'
        cat ~/.android/avd/$EMULATOR_NAME.avd/config.ini

