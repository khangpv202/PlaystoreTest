#!/usr/bin/env bash

booted=false
ready=false
n=0
errors=0
echo 1 > /tmp/failed

echo "Waiting for emulator to boot"
while [ $booted = false ]
do
  boot=$("${ANDROID_HOME}"/platform-tools/adb shell getprop sys.boot_completed)
  if [ "$boot" = 1 ]
    then
      echo "Emulator booted ($n sec)"
      booted=true
  else
    n=$((n + 1))
    sleep 1
  fi
  if [ $n -gt 300 ]
    then
      echo "Android Emulator did not boot in 5 minutes"
      exit 2
  fi
done

echo "Waiting for emulator launcher to be ready"
while [ $ready = false ]
do
    #Get the current focus
    # $ANDROID_HOME/platform-tools/adb shell dumpsys window
    currentFocus=$("$ANDROID_HOME"/platform-tools/adb shell dumpsys window 2>/dev/null | grep -i mCurrentFocus)
    #Inform when focus changes
    if [ "$currentFocus" != "$oldFocus" ]
      then
        echo "Current focus: ${currentFocus} ($n sec)"
        oldFocus=$currentFocus
    fi
    #Check for Launcher or Errors
    case $currentFocus in
        *"Launcher"*)
            echo "Launcher is ready, Android boot completed"
            ready=true
            rm /tmp/failed
        ;;
        *"Not Responding: com.android.systemui"*)
            errors=$((errors + 1))
            echo "Error #${errors} > Dismiss System UI isn't responding alert"
            "$ANDROID_HOME"/platform-tools/adb shell input keyevent KEYCODE_DPAD_DOWN
            "$ANDROID_HOME"/platform-tools/adb shell input keyevent KEYCODE_ENTER
            n=$((n + 5))
            sleep 5
        ;;
        *"Not Responding: com.google.android.gms"*)
            errors=$((errors + 1))
            echo "Error #${errors} > Dismiss GMS isn't responding alert"
            "$ANDROID_HOME"/platform-tools/adb shell input keyevent KEYCODE_ENTER
            n=$((n + 5))
            sleep 5
        ;;
        *"Not Responding: system"*)
            errors=$((errors + 1))
            echo "Error #${errors} > Dismiss Process system isn't responding alert"
            "$ANDROID_HOME"/platform-tools/adb shell input keyevent KEYCODE_ENTER
            n=$((n + 5))
            sleep 5
        ;;
        *"Not Responding: com.google.android.apps.messaging"*)
            errors=$((errors + 1))
            echo "Error #${errors} > Dismiss Messaging isn't responding alert"
            "$ANDROID_HOME"/platform-tools/adb shell input keyevent KEYCODE_ENTER
            n=$((n + 5))
            sleep 5
        ;;
    esac
    #If device is Not Responding try to reboot it
    if [ $errors -gt 5 ]
    then
        echo "Android Emulator failed to start, restarting..."
        "$ANDROID_HOME"/platform-tools/adb reboot
        errors=0
    fi
    #Sleep 1 second
    n=$((n + 1))
        sleep 1
    #Timeout at 10 minutes
    if [ $n -gt 600 ]
    then
        echo "Android Emulator does not start in 10 minutes"
        exit 2
    fi
done