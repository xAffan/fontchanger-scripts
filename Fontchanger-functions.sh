#!/data/adb/modules/Fontchanger/bash
#######################################################################################################
#                                              Leave Menu                                             #
#######################################################################################################
MODUTILVCODE=10
# Variables:
#  BBok - If busybox detection was ok (true/false)
#  _bb - Busybox binary directory
#  _bbname - Busybox name

# set_busybox <busybox binary>
# alias busybox applets
set_busybox() {
  if [ -x "$1" ]; then
    for i in $(${1} --list); do
      if [ "$i" != 'echo' ] || [ "$i" != 'zip' ] || [ "$1" != 'sleep' ]; then
        alias "$i"="${1} $i" >/dev/null 2>&1
      fi
    done
    _busybox=true
    _bb=$1
  fi
}
_busybox=false

if $_busybox; then
  true
elif [ -d /data/adb/modules/busybox-ndk ]; then
  BUSY=$(find /data/adb/modules/busybox-ndk/system/* -maxdepth 0 | sed 's#.*/##')
  for i in $BUSY; do
    PATH=/data/adb/modules/busybox-ndk/system/$i:$PATH
    _bb=/data/adb/modules/busybox-ndk/system/$i/busybox
    BBox=true
  done
elif [ -f /sbin/.magisk/modules/ccbins/system/bin/busybox ]; then
  PATH=/sbin/.magisk/modules/ccbins/system/bin:$PATH
  _bb=/sbin/.magisk/modules/ccbins/system/bin/busybox
  BBox=true
elif [ -f /sbin/.magisk/modules/ccbins/system/xbin/busybox ]; then
  PATH=/sbin/.magisk/modules/ccbins/system/xbin:$PATH
  _bb=/sbin/.magisk/modules/ccbins/system/xbin/busybox
  BBox=true
elif [ -d /sbin/.magisk/busybox ]; then
  PATH=/sbin/.magisk/busybox:$PATH
  _bb=/sbin/.magisk/busybox/busybox
  BBox=true
elif [ -f $MODPATH/busybox ]; then
  PATH=$MODPATH/busybox:$PATH
  _bb=$MODPATH/busybox
  BBox=true
fi

set_busybox $_bb
[ $? -ne 0 ] && exit $?
[ -n "$ANDROID_SOCKET_adbd" ] && alias clear='echo'
_bbname="$($_bb | head -n1 | awk '{print $1,$2}')"
if [ "$_bbname" == "" ]; then
  _bbname="BusyBox not found!"
  BBox=false
fi

check_updates() {
  echo -e "\n${B}Checking for mod updates${N}"
  rm -f $MODPATH/.updated 2>&1
  wget -qO $MODPATH/.changelog https://raw.githubusercontent.com/xaffan/fontchanger-scripts/$branch/changelog.txt 2>/dev/null
  for i in Fontchanger-functions.sh,MODUTILVCODE system/bin/font_changer,scriptver; do
    local file="$(echo $i | cut -d , -f1)" value="$(echo $i | cut -d , -f2)"
    if [ `wget -qO - https://raw.githubusercontent.com/xaffan/fontchanger-scripts/$branch/$(basename $file) 2>/dev/null | grep "^$value=" | cut -d = -f2` -gt `grep "^$value=" $MODPATH/$file | cut -d = -f2` ]; then
      echo "$scriptver" > $MODPATH/.updated
      wget -qO $MODPATH/$file https://raw.githubusercontent.com/xaffan/fontchanger-scripts/$branch/$(basename $file) 2>/dev/null
      [ "$file" == "system/bin/font_changer" ] && { umount -l /$file; mount -o bind $MODPATH/$file /$file; }
    fi
  done
}

invalid() {
  echo -e "${R}Invaild Option...${N}"
  $SLEEP 3
  clear
}

return_menu() {
  SKIPUP=$((SKIPUP + 1))
  mchoice=""
  while [[ "$mchoice" != "y" && "$mchoice" != "n" ]]; do
    echo -e "${R}Return to menu? < y | n > : ${N}"
    read -r mchoice
    case $(echo -e $mchoice | tr '[:upper:]' '[:lower:]') in
    y) menu ;;
    n) clear && quit ;;
    *) invalid ;;
    esac
  done
}

emoji_reboot_menu() {
  mchoice=""
  while [[ "$mchoice" != "y" && "$mchoice" != "n" ]]; do
    echo -e "${B}Emoji Applied Successfully...${N}"
    echo -e "${R}You Will Need to Reboot to Apply Changes${N}"
    echo -e "${R}Reboot? < y | n > : ${N}"
    read -r mchoice
    case $(echo -e $mchoice | tr '[:upper:]' '[:lower:]') in
    y) reboot ;;
    n) return_menu ;;
    *) invalid ;;
    esac
  done
}

font_reboot_menu() {
  mchoice=""
  while [[ "$mchoice" != "y" && "$mchoice" != "n" ]]; do
    echo -e "${B}Font Applied Successfully...${N}"
    echo -e "${R}You Will Need to Reboot to Apply Changes${N}"
    echo -e "${R}Reboot? < y | n > : ${N}"
    read -r mchoice
    case $(echo -e $mchoice | tr '[:upper:]' '[:lower:]') in
    y) reboot ;;
    n) return_menu ;;
    *) invalid ;;
    esac
  done
}

retry() {
  echo -e "${R}[!] FONT WAS NOT APPLIED [!]${N}"
  echo -e "${R} PLEASE TRY AGAIN${N}"
  $SLEEP 3
  clear
}

is_not_empty() {
  if [ "$(ls -Ap $1 $2 $3 | grep ".zip")" ]; then
    :
  else
    :
  fi
}

is_not_empty_font() {
  DIR="$1"
  if [ "$( ls -Ap $DIR | grep -v "/")" ]; then
    font_reboot_menu
  else
    retry
  fi
}

lg_device() {
device=$(getprop ro.product.brand 2>/dev/null)
if [ $device = "lge" ]; then
  if [ -d $MODPATH/system/fonts ]; then
    cp -f $MODPATH/system/fonts/Roboto-Bold.ttf $MODPATH/system/fonts/LG_Number_Roboto_Bold_New.ttf
    cp -f $MODPATH/system/fonts/Roboto-Bold.ttf $MODPATH/system/fonts/LG_Number_Roboto_Bold.ttf
    cp -f $MODPATH/system/fonts/Roboto-Light.ttf $MODPATH/system/fonts/LG_Number_Roboto_Light.ttf
    cp -f $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/LG_Number_Roboto_Regular.ttf
    cp -f $MODPATH/system/fonts/Roboto-Thin.ttf $MODPATH/system/fonts/LG_Number_Roboto_Thin_New.ttf
    cp -f $MODPATH/system/fonts/Roboto-Thin.ttf $MODPATH/system/fonts/LG_Number_Roboto_Thin.ttf
    cp -f $MODPATH/system/fonts/Roboto-Light.ttf $MODPATH/system/fonts/LG_SlimNumber-Light.ttf
    cp -f $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/LG_SlimNumber-Regular.ttf
    cp -f $MODPATH/system/fonts/Roboto-Thin.ttf $MODPATH/system/fonts/LG_SlimNumber-Thin.ttf
  fi
  if [ -d $MODPATH/system/product/fonts ]; then
    cp -f $MODPATH/system/product/fonts/Roboto-Bold.ttf $MODPATH/system/product/fonts/LG_Number_Roboto_Bold_New.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Bold.ttf $MODPATH/system/product/fonts/LG_Number_Roboto_Bold.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Light.ttf $MODPATH/system/product/fonts/LG_Number_Roboto_Light.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Regular.ttf $MODPATH/system/product/fonts/LG_Number_Roboto_Regular.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Thin.ttf $MODPATH/system/product/fonts/LG_Number_Roboto_Thin_New.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Thin.ttf $MODPATH/system/product/fonts/LG_Number_Roboto_Thin.ttf
    cp -f $MODPATH/system/fonts/Roboto-Light.ttf $MODPATH/system/fonts/LG_SlimNumber-Light.ttf
    cp -f $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/LG_SlimNumber-Regular.ttf
    cp -f $MODPATH/system/fonts/Roboto-Thin.ttf $MODPATH/system/fonts/LG_SlimNumber-Thin.ttf
  fi
  if [ -d $MODPATH/product/fonts ]; then
    cp -f $MODPATH/product/fonts/Roboto-Bold.ttf $MODPATH/product/fonts/LG_Number_Roboto_Bold_New.ttf
    cp -f $MODPATH/product/fonts/Roboto-Bold.ttf $MODPATH/product/fonts/LG_Number_Roboto_Bold.ttf
    cp -f $MODPATH/product/fonts/Roboto-Light.ttf $MODPATH/product/fonts/LG_Number_Roboto_Light.ttf
    cp -f $MODPATH/product/fonts/Roboto-Regular.ttf $MODPATH/product/fonts/LG_Number_Roboto_Regular.ttf
    cp -f $MODPATH/product/fonts/Roboto-Thin.ttf $MODPATH/product/fonts/LG_Number_Roboto_Thin_New.ttf
    cp -f $MODPATH/product/fonts/Roboto-Thin.ttf $MODPATH/product/fonts/LG_Number_Roboto_Thin.ttf
    cp -f $MODPATH/system/fonts/Roboto-Light.ttf $MODPATH/system/fonts/LG_SlimNumber-Light.ttf
    cp -f $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/LG_SlimNumber-Regular.ttf
    cp -f $MODPATH/system/fonts/Roboto-Thin.ttf $MODPATH/system/fonts/LG_SlimNumber-Thin.ttf
  fi
fi
}

pixel() {
device=$(getprop ro.product.brand)
if [ $device = google ]; then
  if [ -f $MIRROR/system/fonts/GoogleSans-Regular.ttf ]; then
	  cp $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/GoogleSans-Regular.ttf
	  cp $MODPATH/system/fonts/Roboto-Italic.ttf $MODPATH/system/fonts/GoogleSans-Italic.ttf
	  cp $MODPATH/system/fonts/Roboto-Medium.ttf $MODPATH/system/fonts/GoogleSans-Medium.ttf
	  cp $MODPATH/system/fonts/Roboto-MediumItalic.ttf $MODPATH/system/fonts/GoogleSans-MediumItalic.ttf
	  cp $MODPATH/system/fonts/Roboto-Bold.ttf $MODPATH/system/fonts/GoogleSans-Bold.ttf
	  cp $MODPATH/system/fonts/Roboto-BoldItalic.ttf $MODPATH/system/fonts/GoogleSans-BoldItalic.ttf
  fi
  if [ -f $MIRROR/system/product/fonts/GoogleSans-Regular.ttf ]; then
	  cp $MODPATH/system/product/fonts/Roboto-Regular.ttf $MODPATH/system/product/fonts/GoogleSans-Regular.ttf
	  cp $MODPATH/system/product/fonts/Roboto-Italic.ttf $MODPATH/system/product/fonts/GoogleSans-Italic.ttf
	  cp $MODPATH/system/product/fonts/Roboto-Medium.ttf $MODPATH/system/product/fonts/GoogleSans-Medium.ttf
	  cp $MODPATH/system/product/fonts/Roboto-MediumItalic.ttf $MODPATH/system/product/fonts/GoogleSans-MediumItalic.ttf
	  cp $MODPATH/system/product/fonts/Roboto-Bold.ttf $MODPATH/system/product/fonts/GoogleSans-Bold.ttf
	  cp $MODPATH/system/product/fonts/Roboto-BoldItalic.ttf $MODPATH/system/product/fonts/GoogleSans-BoldItalic.ttf
  fi
  if [ -f $MIRROR/product/fonts/GoogleSans-Regular.ttf ]; then
	  cp $MODPATH/product/fonts/Roboto-Regular.ttf $MODPATH/product/fonts/GoogleSans-Regular.ttf
	  cp $MODPATH/product/fonts/Roboto-Italic.ttf $MODPATH/product/fonts/GoogleSans-Italic.ttf
	  cp $MODPATH/product/fonts/Roboto-Medium.ttf $MODPATH/product/fonts/GoogleSans-Medium.ttf
	  cp $MODPATH/product/fonts/Roboto-MediumItalic.ttf $MODPATH/product/fonts/GoogleSans-MediumItalic.ttf
	  cp $MODPATH/product/fonts/Roboto-Bold.ttf $MODPATH/product/fonts/GoogleSans-Bold.ttf
	  cp $MODPATH/product/fonts/Roboto-BoldItalic.ttf $MODPATH/product/fonts/GoogleSans-BoldItalic.ttf
  fi
fi
}

oxygen() {
device=$(getprop ro.build.version.ota 2>/dev/null)
if [[ $device = *Oxygen* ]]; then
  if [ -f $MIRROR/system/fonts/SlateForOnePlus-Regular.ttf ]; then
	  cp $MODPATH/system/fonts/Roboto-Black.ttf $MODPATH/system/fonts/SlateForOnePlus-Black.ttf
	  cp $MODPATH/system/fonts/Roboto-Bold.ttf $MODPATH/system/fonts/SlateForOnePlus-Bold.ttf
	  cp $MODPATH/system/fonts/Roboto-Medium.ttf $MODPATH/system/fonts/SlateForOnePlus-Medium.ttf
	  cp $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/SlateForOnePlus-Regular.ttf
	  cp $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/SlateForOnePlus-Book.ttf
	  cp $MODPATH/system/fonts/Roboto-Light.ttf $MODPATH/system/fonts/SlateForOnePlus-Light.ttf
	  cp $MODPATH/system/fonts/Roboto-Thin.ttf $MODPATH/system/fonts/SlateForOnePlus-Thin.ttf
  fi
  if [ -f $MIRROR/system/product/fonts/SlateForOnePlus-Regular.ttf ]; then
	  cp $MODPATH/system/product/fonts/Roboto-Black.ttf $MODPATH/system/product/fonts/SlateForOnePlus-Black.ttf
	  cp $MODPATH/system/product/fonts/Roboto-Bold.ttf $MODPATH/system/product/fonts/SlateForOnePlus-Bold.ttf
	  cp $MODPATH/system/product/fonts/Roboto-Medium.ttf $MODPATH/system/product/fonts/SlateForOnePlus-Medium.ttf
	  cp $MODPATH/system/product/fonts/Roboto-Regular.ttf $MODPATH/system/product/fonts/SlateForOnePlus-Regular.ttf
	  cp $MODPATH/system/product/fonts/Roboto-Regular.ttf $MODPATH/system/product/fonts/SlateForOnePlus-Book.ttf
	  cp $MODPATH/system/product/fonts/Roboto-Light.ttf $MODPATH/system/product/fonts/SlateForOnePlus-Light.ttf
	  cp $MODPATH/system/product/fonts/Roboto-Thin.ttf $MODPATH/system/product/fonts/SlateForOnePlus-Thin.ttf
  fi
  if [ -f $MIRROR/product/fonts/GoogleSans-Regular.ttf ]; then
	  cp $MODPATH/product/fonts/Roboto-Black.ttf $MODPATH/product/fonts/SlateForOnePlus-Black.ttf
	  cp $MODPATH/product/fonts/Roboto-Bold.ttf $MODPATH/product/fonts/SlateForOnePlus-Bold.ttf
	  cp $MODPATH/product/fonts/Roboto-Medium.ttf $MODPATH/product/fonts/SlateForOnePlus-Medium.ttf
	  cp $MODPATH/product/fonts/Roboto-Regular.ttf $MODPATH/product/fonts/SlateForOnePlus-Regular.ttf
	  cp $MODPATH/product/fonts/Roboto-Regular.ttf $MODPATH/product/fonts/SlateForOnePlus-Book.ttf
	  cp $MODPATH/product/fonts/Roboto-Light.ttf $MODPATH/product/fonts/SlateForOnePlus-Light.ttf
	  cp $MODPATH/product/fonts/Roboto-Thin.ttf $MODPATH/product/fonts/SlateForOnePlus-Thin.ttf
  fi
fi
}

samsung_device() {
device=$(getprop ro.product.brand 2>/dev/null)
if [ $device = "samsung" ]; then
  if [ -d $MODPATH/system/fonts ]; then
    cp -f $MODPATH/system/fonts/Roboto-Bold.ttf $MODPATH/system/fonts/RobotoNum-3L.ttf
    cp -f $MODPATH/system/fonts/Roboto-Bold.ttf $MODPATH/system/fonts/RobotoNum-3R.ttf
    cp -f $MODPATH/system/fonts/Roboto-Bold.ttf $MODPATH/system/fonts/SamsungSans-Bold.ttf
    cp -f $MODPATH/system/fonts/Roboto-BoldItalic.ttf $MODPATH/system/fonts/SamsungSans-BoldItalic.ttf
    cp -f $MODPATH/system/fonts/Roboto-Italic.ttf $MODPATH/system/fonts/SamsungSans-Italic.ttf
    cp -f $MODPATH/system/fonts/Roboto-Medium.ttf $MODPATH/system/fonts/SamsungSans-Medium.ttf
    cp -f $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/SamsungSans-Regular.ttf
    cp -f $MODPATH/system/fonts/Roboto-Thin.ttf $MODPATH/system/fonts/SamsungSans-Thin.ttf
    cp -f $MODPATH/system/fonts/Roboto-Light.ttf $MODPATH/system/fonts/SamsungSans-Light.ttf
    cp -f $MODPATH/system/fonts/Roboto-LightItalic.ttf $MODPATH/system/fonts/SamsungSans-LightItalic.ttf
    cp -f $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/SECRobotoLight-Regular.ttf
    cp -f $MODPATH/system/fonts/Roboto-Bold.ttf $MODPATH/system/fonts/SECRobotoLight-Bold.ttf
    cp -f $MODPATH/system/fonts/Roboto-Bold.ttf $MODPATH/system/fonts/SECRobotoCondensed-Bold.ttf
  fi
  if [ -d $MODPATH/system/product/fonts ]; then
    cp -f $MODPATH/system/product/fonts/Roboto-Bold.ttf $MODPATH/system/product/fonts/RobotoNum-3L.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Bold.ttf $MODPATH/system/product/fonts/RobotoNum-3R.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Bold.ttf $MODPATH/system/product/fonts/SamsungSans-Bold.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-BoldItalic.ttf $MODPATH/product/system/fonts/SamsungSans-BoldItalic.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Italic.ttf $MODPATH/system/product/fonts/SamsungSans-Italic.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Medium.ttf $MODPATH/system/product/fonts/SamsungSans-Medium.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Regular.ttf $MODPATH/system/product/fonts/SamsungSans-Regular.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Thin.ttf $MODPATH/system/product/fonts/SamsungSans-Thin.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Light.ttf $MODPATH/system/product/fonts/SamsungSans-Light.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-LightItalic.ttf $MODPATH/system/product/fonts/SamsungSans-LightItalic.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Regular.ttf $MODPATH/system/product/fonts/SECRobotoLight-Regular.ttf
    cp -f $MODPATH/system/psroduct/fonts/Roboto-Bold.ttf $MODPATH/system/product/fonts/SECRobotoLight-Bold.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Bold.ttf $MODPATH/system/product/fonts/SECRobotoCondensed-Bold.ttf
  fi
  if [ -d $MODPATH/product/fonts ]; then
    cp -f $MODPATH/product/fonts/Roboto-Bold.ttf $MODPATH/product/fonts/RobotoNum-3L.ttf
    cp -f $MODPATH/product/fonts/Roboto-Bold.ttf $MODPATH/product/fonts/RobotoNum-3R.ttf
    cp -f $MODPATH/product/fonts/Roboto-Bold.ttf $MODPATH/product/fonts/SamsungSans-Bold.ttf
    cp -f $MODPATH/product/fonts/Roboto-BoldItalic.ttf $MODPATH/product/fonts/SamsungSans-BoldItalic.ttf
    cp -f $MODPATH/product/fonts/Roboto-Italic.ttf $MODPATH/product/fonts/SamsungSans-Italic.ttf
    cp -f $MODPATH/product/fonts/Roboto-Medium.ttf $MODPATH/product/fonts/SamsungSans-Medium.ttf
    cp -f $MODPATH/product/fonts/Roboto-Regular.ttf $MODPATH/product/fonts/SamsungSans-Regular.ttf
    cp -f $MODPATH/product/fonts/Roboto-Thin.ttf $MODPATH/product/fonts/SamsungSans-Thin.ttf
    cp -f $MODPATH/product/fonts/Roboto-Light.ttf $MODPATH/product/fonts/SamsungSans-Light.ttf
    cp -f $MODPATH/product/fonts/Roboto-LightItalic.ttf $MODPATH/product/fonts/SamsungSans-LightItalic.ttf
    cp -f $MODPATH/product/fonts/Roboto-Regular.ttf $MODPATH/product/fonts/SECRobotoLight-Regular.ttf
    cp -f $MODPATH/product/fonts/Roboto-Bold.ttf $MODPATH/product/fonts/SECRobotoLight-Bold.ttf
    cp -f $MODPATH/product/fonts/Roboto-Bold.ttf $MODPATH/product/fonts/SECRobotoCondensed-Bold.ttf
  fi
fi
}

android10() {
if [ "$API" -ge 29 ]; then
  if [ -d $MODPATH/system/product/fonts ]; then
	  cp -rf $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/NotoSerif-Regular.ttf
	  cp -rf $MODPATH/system/fonts/Roboto-Bold.ttf $MODPATH/system/fonts/NotoSerif-Bold.ttf
	  cp -rf $MODPATH/system/fonts/Roboto-Italic.ttf $MODPATH/system/fonts/NotoSerif-Italic.ttf
	  cp -rf $MODPATH/system/fonts/Roboto-BoldItalic.ttf $MODPATH/system/fonts/NotoSerif-BoldItalic.ttf
	  cp -rf $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/SourceSansPro-Regular.ttf
	  cp -rf $MODPATH/system/fonts/Roboto-Bold.ttf $MODPATH/system/fonts/SourceSansPro-Bold.ttf
	  cp -rf $MODPATH/system/fonts/Roboto-BoldItalic.ttf $MODPATH/system/fonts/SourceSansPro-BoldItalic.ttf
	  cp -rf $MODPATH/system/fonts/Roboto-Italic.ttf $MODPATH/system/fonts/SourceSansPro-Italic.ttf
	  cp -rf $MODPATH/system/fonts/Roboto-Medium.ttf $MODPATH/system/fonts/SourceSansPro-SemiBold.ttf
	  cp -rf $MODPATH/system/fonts/Roboto-MediumItalic.ttf $MODPATH/system/fonts/SourceSansPro-SemiBoldItalic.ttf
  fi
  if [ -d $MODPATH/system/product/fonts ]; then
	  cp -rf $MODPATH/system/product/fonts/Roboto-Regular.ttf $MODPATH/system/product/fonts/NotoSerif-Regular.ttf
	  cp -rf $MODPATH/system/product/fonts/Roboto-Bold.ttf $MODPATH/system/product/fonts/NotoSerif-Bold.ttf
	  cp   -rf $MODPATH/system/product/fonts/Roboto-Italic.ttf $MODPATH/system/product/fonts/NotoSerif-Italic.ttf
	  cp -rf $MODPATH/system/product/fonts/Roboto-BoldItalic.ttf $MODPATH/system/product/fonts/NotoSerif-BoldItalic.ttf
	  cp -rf $MODPATH/system/product/fonts/Roboto-Regular.ttf $MODPATH/system/product/fonts/SourceSansPro-Regular.ttf
	  cp -rf $MODPATH/system/product/fonts/Roboto-Bold.ttf $MODPATH/system/product/fonts/SourceSansPro-Bold.ttf
	  cp -rf $MODPATH/system/product/fonts/Roboto-BoldItalic.ttf $MODPATH/system/product/fonts/SourceSansPro-BoldItalic.ttf
	  cp -rf $MODPATH/system/product/fonts/Roboto-Italic.ttf $MODPATH/system/product/fonts/SourceSansPro-Italic.ttf
	  cp -rf $MODPATH/system/product/fonts/Roboto-Medium.ttf $MODPATH/system/product/fonts/SourceSansPro-SemiBold.ttf
	  cp -rf $MODPATH/system/product/fonts/Roboto-MediumItalic.ttf $MODPATH/system/product/fonts/SourceSansPro-SemiBoldItalic.ttf
  fi
  if [ -d $MODPATH/product/fonts ]; then
	  cp -rf $MODPATH/product/fonts/Roboto-Regular.ttf $MODPATH/product/fonts/NotoSerif-Regular.ttf
	  cp -rf $MODPATH/product/fonts/Roboto-Bold.ttf $MODPATH/product/fonts/NotoSerif-Bold.ttf
	  cp -rf $MODPATH/product/fonts/Roboto-Italic.ttf $MODPATH/product/fonts/NotoSerif-Italic.ttf
	  cp -rf $MODPATH/product/fonts/Roboto-BoldItalic.ttf $MODPATH/product/fonts/NotoSerif-BoldItalic.ttf
	  cp -rf $MODPATH/product/fonts/Roboto-Regular.ttf $MODPATH/product/fonts/SourceSansPro-Regular.ttf
	  cp -rf $MODPATH/product/fonts/Roboto-Bold.ttf $MODPATH/product/fonts/SourceSansPro-Bold.ttf
	  cp -rf $MODPATH/product/fonts/Roboto-BoldItalic.ttf $MODPATH/product/fonts/SourceSansPro-BoldItalic.ttf
	  cp -rf $MODPATH/product/fonts/Roboto-Italic.ttf $MODPATH/product/fonts/SourceSansPro-Italic.ttf
	  cp -rf $MODPATH/product/fonts/Roboto-Medium.ttf $MODPATH/product/fonts/SourceSansPro-SemiBold.ttf
	  cp -rf $MODPATH/product/fonts/Roboto-MediumItalic.ttf $MODPATH/product/fonts/SourceSansPro-SemiBoldItalic.ttf
  fi
fi
}
#######################################################################################################
#                                               LOGGING                                               #
#######################################################################################################
# Loggers
LOGGERS="
$CACHELOC/magisk.log
$CACHELOC/magisk.log.bak
/data/adb/magisk_debug.log
$TMPLOGLOC/Fontchanger-install-verbose.log
$TMPLOGLOC/Fontchanger-install.log
$TMPLOGLOC/${MODID}-service.log
$TMPLOGLOC/${MODID}.log
$TMPLOGLOC/${MODID}-old.log
$TMPLOGLOC/${MODID}-verbose.log
$TMPLOGLOC/${MODID}-verbose-old.log
"

log_handler() {
  if [ $(id -u) == 0 ]; then
    echo -e "" >>$LOG
    echo -e "$(date +"%m-%d-%Y %H:%M:%S") - $1" >>$LOG
  fi
}

log_print() {
  echo -e "$1"
  log_handler "$1"
}

log_script_chk() {
  log_handler "$1"
  echo -e "$(date +"%m-%d-%Y %H:%M:%S") - $1" >>$LOG
}

#Log Functions
# Saves the previous log (if available) and creates a new one
log_start() {
  if [ -f "$LOG" ]; then
    mv -f $LOG $oldLOG
  fi
  touch $LOG
  echo "*********************************************" >>$LOG
  echo "*              FontChanger                  *" >>$LOG
  echo "*********************************************" >>$LOG
  echo "*                 $VER                      *" >>$LOG
  echo "*              John Fawkes                  *" >>$LOG
  echo "*********************************************" >>$LOG
  log_script_chk "Log start."
}

collect_logs() {
  log_handler "Collecting logs and information."
  # Create temporary directory
  mkdir -pv $TMPLOGLOC >>$LOG

  # Saving the current prop values
  log_handler "RESETPROPS"
  echo -e "==========================================" >>$LOG
  resetprop >>$LOG
  log_print " Collecting Modules Installed "
  echo -e "==========================================" >>$LOG
  ls /data/adb/modules >>$LOG
  log_print " Collecting Logs for Installed Files "
  echo -e "==========================================" >>$LOG
  log_handler "$(du -ah $MODPATH)" >>$LOG
  echo -e "==========================================" >>$LOG

  # Saving Magisk and module log files and device original build.prop
  for ITEM in $LOGGERS; do
    if [ -f "$ITEM" ]; then
      case "$ITEM" in
      *build.prop*)
        BPNAME="build_$(echo -e $ITEM | sed 's|\/build.prop||' | sed 's|.*\/||g').prop"
        ;;
      *)
        BPNAME=""
        ;;
      esac
      cp -af $ITEM ${TMPLOGLOC}/${BPNAME} >>$LOG
    else
      case "$ITEM" in
      *$FCDIR)
        FCDIRLOCTMP=$FCDIR/Logs
        ITEMTPM=$(echo -e $ITEM | sed 's|$FCDIR|$FCDIRLOCTMP|')
        if [ -f "$ITEMTPM" ]; then
          cp -af $ITEMTPM $TMPLOGLOC >>$LOG
        else
          log_handler "$ITEM not available."
        fi
        ;;
      *)
        log_handler "$ITEM not available."
        ;;
      esac
    fi
  done

  # Package the files
  cd $TMPLOGLOC || {
    echo -e "$TMPLOGLOC Doesnt Exist"
    exit 1
  }
  #  tar -zcvf Fontchanger_logs.tar.xz Fontchanger_logs >> $LOG
  $ZIP -r9v "Fontchanger_logs.zip" ./*

  # Copy package to internal storage
  cp -f $TMPLOGLOC/Fontchanger_logs.zip $FCDIR >>$LOG

  if [ -e $FCDIR/Fontchanger_logs.zip ]; then
    log_print "Fontchanger_logs.zip Created Successfully."
  else
    log_print "Archive File Not Created. Error in Script. Please contact John Fawkes"
  fi

  # Remove temporary directory
  #  rm -rf $TMPLOGLOC >> $LOG
  log_handler "Logs and information collected."
}
#######################################################################################################
#                                               HELP                                                  #
#######################################################################################################
help() {
  cat <<EOF
$MODTITLE $VER($REL)
by $AUTHOR
Copyright (C) 2019, John Fawkes @ xda-developers
License: GPLv3+

Usage: $_name
   or: $_name [options]...

Options:

  -c|--cemoji [custom emoji]  apply the custom emoji
  e.g., font_changer -c <name of custom emoji>
  e.g., font_changer --cemoji <name of custom emoji>
  
  -d|--cfont [custom font]    apply a custom font
  e.g., font_changer -d <name of custom font>
  e.g., font_changer --cfont <name of custom font>

  -e|--emoji [emoji]          apply an emoji
  e.g., font_changer -e <name of emoji>
  e.g., font_changer --emoji <name of emoji>

  -f|--font [font]            apply a font from downloadable list
  e.g., font_changer -f <name of font>
  e.g., font_changer --font <name of font>

  -h|--help                   show this message
  e.g., font_changer -h
  e.g., font_changer --help

  -m|--restoreemoji           restore just stock emoji but keep fontchanger font
  e.g., font_changer -m
  e.g., font_changer --restoreemoji

  -n|--restorefont            restore just stock font but keep fontchanger emoji
  e.g., font_changer -n
  e.g., font_changer --restorefont

  -r|--random                 apply a random font
  e.g., font_changer -r
  e.g., font_changer --random

  -s|--current                show current font
  e.g., font_changer -s
  e.g., font_changer --current

  -z|--delete                 delete downloaded font and emoji zips if they exist
  e.g., font_changer -z
  e.g., font_changer --delete

EOF
  exit
}

help_custom() {
  cat <<EOF
$MODTITLE $VER($REL)
by $AUTHOR
Copyright (C) 2019, John Fawkes @ xda-developers
License: GPLv3+
  Welcome to the How-to for FontChanger!
  This is the Folder Structure You Will Need to Follow
  In Order for FontChanger to Properly Detect and Apply Your Font!
  Note ------ /sdcard Equals Internal Storage

    |--Fontchanger/
            |--Fonts/
               |--Custom/
                  |--<font-folder-name>/
                         |--<font>.ttf
                         |--<font>.ttf
  
  You Need To Place Your Font Folders in /storage/emulated/0/Fontchanger/Fonts/Custom.
  The <font-folder-name> is the Name of the Font You Want to Apply.
  This Would be the Main Folder That Holds the ttf Files for That Font.
  The --<font>.ttf are the ttf Files For That Specific Font.
  You Can Have Multiple Font Folders Inside the Fontchanger/Fonts Folder.
  Inside the Folder that Has Your ttf Files Inside, You Need to Have 23 Font Files.
  The Script Will Not Pass Unless All 20 Files Exist! The Files You Need Are : 
  Roboto-Black.ttf 
  Roboto-BlackItalic.ttf 
  Roboto-Bold.ttf 
  Roboto-BoldItalic.ttf 
  RobotoCondensed-Bold.ttf 
  RobotoCondensed-BoldItalic.ttf 
  RobotoCondensed-Italic.ttf 
  RobotoCondensed-Light.ttf 
  RobotoCondensed-LightItalic.ttf
  RobotoCondensed-Medium.ttf
  RobotoCondensed-MediumItalic.ttf
  RobotoCondensed-Regular.ttf 
  Roboto-Italic.ttf 
  Roboto-Light.ttf 
  Roboto-LightItalic.ttf 
  Roboto-Medium.ttf 
  Roboto-MediumItalic.ttf 
  Roboto-Regular.ttf 
  Roboto-Thin.ttf 
  Roboto-ThinItalic.ttf


  For the custom emojis you'll need to setup a directory in /storage/emulated/0/Fontchanger/Emojis/Custom
  
      |--Fontchanger/
            |--Emoji/
               |--Custom/
                |--<Emoji-folder-name>/
                        |--<font>.ttf
                        |--<font>.ttf
 
  The <emoji-folder-name> is the folder that will house your custom emoji file.
  The <font>.ttf are the emoji files. Usually named NotoColorEmoji.ttf.
EOF
  exit
}
#######################################################################################################
#                                         EMOJIS                                                      #
#######################################################################################################
apply_emoji() {
  echo -e "${B}Applying Emoji. Please Wait...${N}"
  $SLEEP 2
  emojichoice="$(grep -w $choice $MODPATH/emojilist.txt | tr -d '[' | tr -d ']' | tr -d $choice | tr -d ' ')"
  rm -f $MODPATH/product/fonts/*Emoji*.ttf
  rm -f $MODPATH/system/product/fonts/*Emoji*.ttf
  rm -f $MODPATH/system/fonts/*Emoji*.ttf
  [ -e $FCDIR/Emojis/$emojichoice.zip ] || $CURL -k -o "$FCDIR/Emojis/$emojichoice.zip" https://john-fawkes.com/Downloads/hahaemoji/$emojichoice.zip
  mkdir -p $FCDIR/Emojis/$emojichoice
  unzip -o "$FCDIR/Emojis/$emojichoice.zip" -d $FCDIR/Emojis/$emojichoice
  if [ -d $MIRROR/product/fonts ]; then
    mkdir -p $MODPATH/product/fonts
    cp -f $FCDIR/Emojis/$emojichoice/NotoColorEmoji.ttf $MODPATH/product/fonts
    if [ -f $MIRROR/product/fonts/SamsungColorEmoji.ttf ]; then
      cp -f $MODPATH/product/fonts/NotoColorEmoji.ttf $MODPATH/product/fonts/SamsungColorEmoji.ttf
    fi
    if [ -f $MIRROR/product/fonts/hTC_ColorEmoji.ttf ]; then
      cp -f $MODPATH/product/fonts/NotoColorEmoji.ttf $MODPATH/product/fonts/hTC_ColorEmoji.ttf
    fi
    set_perm_recursive $MODPATH/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    mkdir -p $MODPATH/system/product/fonts
    cp -f $FCDIR/Emojis/$emojichoice/NotoColorEmoji.ttf $MODPATH/system/product/fonts
    if [ -f $MIRROR/system/product/fonts/SamsungColorEmoji.ttf ]; then
      cp -f $MODPATH/system/product/fonts/NotoColorEmoji.ttf $MODPATH/system/product/fonts/SamsungColorEmoji.ttf
    fi
    if [ -f $MIRROR/system/product/fonts/hTC_ColorEmoji.ttf ]; then
      cp -f $MODPATH/system/product/fonts/NotoColorEmoji.ttf $MODPATH/system/product/fonts/fonts/hTC_ColorEmoji.ttf
    fi
    set_perm_recursive $MODPATH/system/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/fonts ]; then
    mkdir -p $MODPATH/system/fonts
    cp -f $FCDIR/Emojis/$emojichoice/NotoColorEmoji.ttf $MODPATH/system/fonts
    if [ -f $MIRROR/system/fonts/SamsungColorEmoji.ttf ]; then
      cp -f $MODPATH/system/fonts/NotoColorEmoji.ttf $MODPATH/system/fonts/SamsungColorEmoji.ttf
    fi
    if [ -f $MIRROR/system/fonts/hTC_ColorEmoji.ttf ]; then
      cp -f $MODPATH/system/fonts/NotoColorEmoji.ttf $MODPATH/system/fonts/hTC_ColorEmoji.ttf
    fi
    set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
  fi
  if [ -d $FCDIR/Emojis/$emojichoice ]; then
    rm -rf $FCDIR/Emojis/$emojichoice
  fi
  [ -f $CEMOJI ] || touch $CEMOJI
  truncate -s 0 $CEMOJI
  echo "CURRENT=$emojichoice" >>$CEMOJI
  if [ -e $MODPATH/product/fonts/NotoColorEmoji.ttf ] || [ -e $MODPATH/system/product/fonts/NotoColorEmoji.ttf ] || [ -e $MODPATH/system/fonts/NotoColorEmoji.ttf ]; then
    emoji_reboot_menu
  else
    echo -e "${R}[!] Emoji WAS NOT APPLIED [!]${N}"
    echo -e "${R} PLEASE TRY AGAIN${N}"
    $SLEEP 3
    clear
    emoji_menu
  fi
}

list_emoji() {
  num=1
  rm $MODPATH/emojilist.txt
  emojis=($(cat $FCDIR/emojis-list.txt | sed 's/.zip//'))
  touch $MODPATH/emojilist.txt
  for i in "${emojis[@]}"; do
    ProgressBar $num ${#emojis[@]}
    num=$((num + 1))
  done
}

emoji_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    clear
    list_emoji
    clear
    echo -e "$div"
    title_div "Emojis"
    echo -e "$div"
    echo -e " "
    num=1
    for emoji in "${emojis[@]}"; do
      echo -e "${W}[$num]${N} ${G}$emoji${N}" && echo -e " [$num] $emoji" >> $MODPATH/emojilist.txt
      num=$((num + 1))
    done
    echo -e " "
    wrong=$(cat $MODPATH/emojilist.txt | wc -l)
    echo -e "${G}[-] Please Choose an Emoji to Apply. Enter the Corresponding Number...${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    *)
      if [ $choice = "q" ]; then
        echo -e "${R}Quiting...${N}"
        clear
        quit
      elif [ $choice = "r" ]; then
        return_menu
      elif [ $choice -le $wrong ]; then
        apply_emoji
      elif [[ -n ${choice//[0-9]/} ]]; then
        invalid
      else
        [ $choice -gt $wrong ] && invalid
      fi
      ;;
    esac
  done
}
#######################################################################################################
#                                         CUSTOM EMOJIS                                              #
#######################################################################################################
apply_custom_emoji() {
  echo -e "${B}Applying Custom Emoji Please Wait...${N}"
  $SLEEP 2
  cusemojichoice="$(grep -w $choice $MODPATH/customemojilist.txt | tr -d [ ] | tr -d $choice | tr -d ' ')"
  if [ -d $MODPATH/system ] || [ -d $MODPATH/product ]; then
    for i in $MODPATH/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        rm -f $i
      fi
    done
  fi
  if [ -d $MODPATH/system/product ]; then
    for i in $MODPATH/*/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        rm -f $i
      fi
    done
  fi
  if [ -d $MIRROR/product/fonts ]; then
    mkdir -p $MODPATH/product/fonts
    cp -f $FCDIR/Emojis/Custom/$cusemojichoice/NotoColorEmoji.ttf $MODPATH/product/fonts
    if [ -f $MIRROR/product/fonts/SamsungColorEmoji.ttf ]; then
      cp -f $MODPATH/product/fonts/NotoColorEmoji.ttf $MODPATH/product/fonts/SamsungColorEmoji.ttf
    fi
    if [ -f $MIRROR/product/fonts/hTC_ColorEmoji.ttf ]; then
      cp -f $MODPATH/product/fonts/NotoColorEmoji.ttf $MODPATH/product/fonts/hTC_ColorEmoji.ttf
    fi
    set_perm_recursive $MODPATH/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    mkdir -p $MODPATH/system/product/fonts
    cp -f $FCDIR/Emojis/Custom/$cusemojichoice/NotoColorEmoji.ttf $MODPATH/system/product/fonts
    if [ -f $MIRROR/system/product/fonts/SamsungColorEmoji.ttf ]; then
      cp -f $MODPATH/system/product/fonts/NotoColorEmoji.ttf $MODPATH/system/product/fonts/SamsungColorEmoji.ttf
    fi
    if [ -f $MIRROR/system/product/fonts/hTC_ColorEmoji.ttf ]; then
      cp -f $MODPATH/system/product/fonts/NotoColorEmoji.ttf $MODPATH/system/product/fonts/hTC_ColorEmoji.ttf
    fi
    set_perm_recursive $MODPATH/system/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/fonts ]; then
    mkdir -p $MODPATH/system/fonts
    cp -f $FCDIR/Emojis/Custom/$cusemojichoice/NotoColorEmoji.ttf $MODPATH/system/fonts
    if [ -f $MIRROR/system/fonts/SamsungColorEmoji.ttf ]; then
      cp -f $MODPATH/system/fonts/NotoColorEmoji.ttf $MODPATH/system/fonts/SamsungColorEmoji.ttf
    fi
    if [ -f $MIRROR/system/fonts/hTC_ColorEmoji.ttf ]; then
      cp -f $MODPATH/system/fonts/NotoColorEmoji.ttf $MODPATH/system/fonts/hTC_ColorEmoji.ttf
    fi
    set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
  fi
  [ -f $CEMOJI ] || touch $CEMOJI
  truncate -s 0 $CEMOJI
  echo "CURRENT=$cusemojichoice" >> $CEMOJI
  if [ -e $MODPATH/product/fonts/NotoColorEmoji.ttf ] || [ -e $MODPATH/system/product/fonts/NotoColorEmoji.ttf ] || [ -e $MODPATH/system/fonts/NotoColorEmoji.ttf ]; then
    emoji_reboot_menu
  else
    echo -e "${R}[!] Emoji WAS NOT APPLIED [!]${N}"
    echo -e "${R} PLEASE TRY AGAIN${N}"
    $SLEEP 3
    clear
    emoji_menu
  fi
}

list_custom_emoji() {
  num=1
  rm $MODPATH/customemojilist.txt
  touch $MODPATH/customemojilist.txt
  for i in $(find "$FCDIR/Emojis/Custom/" -type d | sed 's#.*/##'); do
    $SLEEP 0.1
    echo -e "[$num] $i" >> $MODPATH/customemojilist.txt && echo -e "${W}[$num]${N} ${B}$i${N}"
    num=$((num + 1))
  done
}

custom_emoji_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    for j in $FCDIR/Emojis/Custom/*; do
      if [ -d $j ]; then
        list_custom_emoji
        break
      else
        echo -e "${R}No Custom Fonts Found${N}"
        return_menu
      fi
    done
    wrong=$(cat $MODPATH/customemojilist.txt | wc -l)
    echo -e "${G}[-] Please Choose an Emoji to Apply. Enter the Corresponding Number...${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    *)
      if [ $choice = "q" ]; then
        echo -e "${R}Quiting...${N}"
        clear
        quit
      elif [ $choice = "r" ]; then
        return_menu
      elif [ $choice -le $wrong ]; then
        apply_custom_emoji
      elif [[ -n ${choice//[0-9]/} ]]; then
        invalid
      else
        [ $choice -gt $wrong ] && invalid
      fi
      ;;
    esac
  done
}
#######################################################################################################
#                                         CUSTOM FONTS                                                #
#######################################################################################################
apply_custom_font() {
  echo -e "${B}Applying Custom Font Please Wait...${N}"
  $SLEEP 2
  choice2="$(grep -w $choice $MODPATH/customfontlist.txt | tr -d '[' | tr -d ']' | tr -d "$choice" | tr -d ' ')"
  cusfont=$(cat $MODPATH/listforcustom.txt)
  if [ -e $FCDIR/dump.txt ]; then
    truncate -s 0 $FCDIR/dump.txt
  else
    touch $FCDIR/dump.txt
  fi
  for i in "${cusfont[@]}"; do
    if [ -e $FCDIR/Fonts/Custom/$choice2/$i ]; then
      echo -e "$i found" >>$FCDIR/dump.txt && echo -e "${B}$i Found${N}"
    fi
    if [ ! -e $FCDIR/Fonts/Custom/$choice2/$i ]; then
      echo -e "$i NOT FOUND" >>$FCDIR/dump.txt && echo -e "${R}$i NOT FOUND${N}"
    fi
  done
  if grep -wq "NOT FOUND" $FCDIR/dump.txt; then
    abort "${R}Script Will Not Continue Until All ttf Files Exist!${N}"
  fi
  PASSED=true
  if [ -d $MODPATH/system ] || [ -d $MODPATH/product ]; then
    for i in $MODPATH/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        mv -f $i $MODPATH
      fi
    done
  fi
  if [ -d $MODPATH/system/product ]; then
    for i in $MODPATH/*/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        mv -f $i $MODPATH
      fi
    done
  fi
  if [ -d $MODPATH/system/fonts ]; then
    rm -rf $MODPATH/system/fonts
  fi
  if [ -d $MODPATH/product/fonts ]; then
    rm -rf $MODPATH/product/fonts
  fi
  if [ -d $MODPATH/system/product/fonts ]; then
    rm -rf $MODPATH/system/product/fonts
  fi
  if [ -d $MIRROR/product/fonts ]; then
    mkdir -p $MODPATH/product/fonts
    cp -f $FCDIR/Fonts/Custom/$choice2/* $MODPATH/product/fonts/
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    mkdir -p $MODPATH/system/product/fonts
    cp -f $FCDIR/Fonts/Custom/$choice2/* $MODPATH/system/product/fonts/
  fi
  if [ -d $MIRROR/system/fonts ]; then
    mkdir -p $MODPATH/system/fonts
    cp -f $FCDIR/Fonts/Custom/$choice2/* $MODPATH/system/fonts/
  fi
  for i in $MODPATH/*Emoji*.ttf; do
    if [ -e $i ]; then
      if [ -d $MIRROR/product/fonts ]; then
        mv -f $i $MODPATH/product/fonts
      fi
      if [ -d $MIRROR/system/product/fonts ]; then
        mv -f $i $MODPATH/system/product/fonts
      fi
      if [ -d $MIRROR/system/fonts ]; then
        mv -f $i $MODPATH/system/fonts
      fi
    fi
  done
  lg_device
  pixel
  samsung_device
  oxygen
  android10
  if [ -d $MIRROR/product/fonts ]; then
    set_perm_recursive $MODPATH/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    set_perm_recursive $MODPATH/system/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/fonts ]; then
    set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
  fi
  [ -f $CFONT ] || touch $CFONT
  truncate -s 0 $CFONT
  echo "CURRENT=$choice2" >>$CFONT
  if [ $PASSED == true ] && [ -d $MODPATH/product/fonts ] || [ -d $MODPATH/system/product/fonts ] || [ -d $MODPATH/system/fonts ]; then
    font_reboot_menu
  else
    retry
  fi
}

list_custom_fonts() {
  num=1
  rm $MODPATH/customfontlist.txt
  touch $MODPATH/customfontlist.txt
  for i in $(find "$FCDIR/Fonts/Custom/" -type d | sed 's#.*/##'); do
    $SLEEP 0.1
    echo -e "[$num] $i" >> $MODPATH/customfontlist.txt && echo -e "${W}[$num]${N} ${B}$i${N}"
    num=$((num + 1))
  done
}

custom_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    for j in $FCDIR/Fonts/Custom/*; do
      if [ -d $j ]; then
        list_custom_fonts
        break
      else
        echo -e "${R}No Custom Fonts Found${N}"
        return_menu
      fi
    done
    wrong=$(cat $MODPATH/customfontlist.txt | wc -l)
    echo -e "${G}[-] Please Choose a Font to Apply. Enter the Corresponding Number...${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    *)
      if [ $choice = "q" ]; then
        echo -e "${R}Quiting...${N}"
        clear
        quit
      elif [ $choice = "r" ]; then
        return_menu
      elif [ $choice -le $wrong ]; then
        apply_custom_font
      elif [[ -n ${choice//[0-9]/} ]]; then
        invalid
      else
        [ $choice -gt $wrong ] && invalid
      fi
      ;;
    esac
  done
}
#######################################################################################################
#                                         DOWNLOADABLE FONTS                                          #
#######################################################################################################
apply_font() {
  choice2="$(grep -w $choice $MODPATH/fontlist.txt | tr -d '[' | tr -d ']' | tr -d "$choice" | tr -d ' ')"
  echo -e "${B}Applying Font. Please Wait...${N}"
  $SLEEP 2
  if [ -d $MODPATH/system ] || [ -d $MODPATH/product ]; then
    for i in $MODPATH/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        mv -f $i $MODPATH
      fi
    done
  fi
  if [ -d $MODPATH/system/product ]; then
    for i in $MODPATH/*/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        mv -f $i $MODPATH
      fi
    done
  fi
  if [ -d $MODPATH/system/fonts ]; then
    rm -rf $MODPATH/system/fonts
  fi
  if [ -d $MODPATH/product/fonts ]; then
    rm -rf $MODPATH/product/fonts
  fi
  if [ -d $MODPATH/system/product/fonts ]; then
    rm -rf $MODPATH/system/product/fonts
  fi
  [ -e $FCDIR/Fonts/$choice2.zip ] || $CURL -k -o "$FCDIR/Fonts/$choice2.zip" https://john-fawkes.com/Downloads/haha$choice2.zip
  mkdir -p $FCDIR/Fonts/$choice2
  unzip -o "$FCDIR/Fonts/$choice2.zip" -d $FCDIR/Fonts/$choice2
  if [ -d $MIRROR/product/fonts ]; then
    mkdir -p $MODPATH/product/fonts
    cp -f $FCDIR/Fonts/$choice2/* $MODPATH/product/fonts
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    mkdir -p $MODPATH/system/product/fonts
    cp -f $FCDIR/Fonts/$choice2/* $MODPATH/system/product/fonts
  fi
  if [ -d $MIRROR/system/fonts ]; then
    mkdir -p $MODPATH/system/fonts
    cp -f $FCDIR/Fonts/$choice2/* $MODPATH/system/fonts
  fi
  for i in $MODPATH/*Emoji*.ttf; do
    if [ -e $i ]; then
      if [ -d $MIRROR/product/fonts ]; then
        mv -f $i $MODPATH/product/fonts
      fi
      if [ -d $MIRROR/system/product/fonts ]; then
        mv -f $i $MODPATH/system/product/fonts
      fi
      if [ -d $MIRROR/system/fonts ]; then
        mv -f $i $MODPATH/system/fonts
      fi
    fi
  done
  lg_device
  pixel
  samsung_device
  oxygen
  android10
  if [ -d $FCDIR/Fonts/$choice2 ]; then
    rm -rf $FCDIR/Fonts/$choice2
  fi
  if [ -d $MIRROR/product/fonts ]; then
    set_perm_recursive $MODPATH/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    set_perm_recursive $MODPATH/system/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/fonts ]; then
    set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
  fi
  [ -f $CFONT ] || touch $CFONT
  truncate -s 0 $CFONT
  echo "CURRENT=$choice2" >>$CFONT
  if [ -d $MODPATH/product/fonts ]; then
    is_not_empty_font $MODPATH/product/fonts
  elif [ -d $MODPATH/system/product/fonts ]; then
    is_not_empty_font $MODPATH/system/product/fonts
  elif [ -d $MODPATH/system/fonts ]; then
    is_not_empty_font $MODPATH/system/fonts
  fi
}

list_fonts() {
  num=1
  rm $MODPATH/fontlist.txt
  fonts=($(cat $FCDIR/fonts.txt | sed 's/.zip//'))
  touch $MODPATH/fontlist.txt
  for i in "${fonts[@]}"; do
    ProgressBar $num ${#fonts[@]}
    num=$((num + 1))
  done
}

font_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    clear
    list_fonts
    clear
    echo -e "$div"
    title_div "Fonts"
    echo -e "$div"
    echo -e " "
    num=1
    for font in "${fonts[@]}"; do
      echo -e "${W}[$num]${N} ${G}$font${N}" && echo -e " [$num] $font" >> $MODPATH/fontlist.txt
      num=$((num + 1))
    done
    echo -e " "
    wrong=$(cat $MODPATH/fontlist.txt | wc -l)
    echo -e "${G}[-] Please Choose a Font to Apply. Enter the Corresponding Number...${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    *)
      if [ $choice = "q" ]; then
        echo -e "${R}Quiting...${N}"
        clear
        quit
      elif [ $choice = "r" ]; then
        return_menu
      elif [ $choice -le $wrong ]; then
        apply_font
      elif [[ -n ${choice//[0-9]/} ]]; then
        invalid
      else
        [ $choice -gt $wrong ] && invalid
      fi
      ;;
    esac
  done
}
#######################################################################################################
#                                       Restore Stock Font                                            #
#######################################################################################################
default_menu() {
  choice=""
  emojichoice=""
  while [ "$choice" != "q" ] && [ "$emojichoice" != "q" ]; do
    echo -e "${G}Would You Like to Restore your Stock Font?${N}"
    echo -e " "
    echo -e "${B}[-] Select an Option...${N}"
    echo -e " "
    echo -e "${W}[Y]${N} ${G} - Yes${N}"
    echo -e " "
    echo -e "${W}[N]${N} ${G} - No${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    y)
      echo -e "${B}Restore Default Selected...${N}"
      for i in $MODPATH/system/fonts/*Emoji.ttf; do
        if [ -e "$i" ]; then
          mkdir -p $FCDIR/Emojis/Backups/system
          mv -f $i $FCDIR/Emojis/Backups/system
        fi
      done
      for i in $MODPATH/product/fonts/*Emoji.ttf; do
        if [ -e "$i" ]; then
          mkdir -p $FCDIR/Emojis/Backups/product
          mv -f $i $FCDIR/Emojis/Backups/product
        fi
      done
      for i in $MODPATH/system/product/fonts/*Emoji.ttf; do
        if [ -e "$i" ]; then
          mkdir -p $FCDIR/Emojis/Backups/system/product
          mv -f $i $FCDIR/Emojis/Backups/system/product
        fi
      done
      if [ -d $MODPATH/system/fonts ]; then
        rm -rf $MODPATH/system/fonts
      fi
      if [ -d $MODPATH/product/fonts ]; then
        rm -rf $MODPATH/product/fonts
      fi
      if [ -d $MODPATH/system/product/fonts ]; then
        rm -rf $MODPATH/system/product/fonts
      fi
      truncate -s 0 $CFONT
      ;;
    n)
      echo -e "${C}Keeping Modded Font...${N}"
      ;;
    q)
      echo -e "${R}[-] Quiting...${N}"
      clear
      quit
      ;;
    r)
      echo -e "${G}[-] Return to Menu Selected...${N}"
      ;;
    *)
      invaild
      $SLEEP 1.5
      ;;
    esac
    echo -e "${B}Would You like to Keep Your Emojis?${N}"
    echo -e " "
    echo -e "${B}[-] Select an Option...${N}"
    echo -e " "
    echo -e "${W}[Y]${N} ${G} - Yes${N}"
    echo -e " "
    echo -e "${W}[N]${N} ${G} - No${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r emojichoice
    case $(echo -e $emojichoice | tr '[:upper:]' '[:lower:]') in
    y)
      echo -e "${Y}Keeping Emojis${N}"
      if [ -f $FCDIR/Emojis/Backups/product/NotoColorEmoji.ttf ]; then
        mkdir -p $MODPATH/product/fonts
        mv -f $FCDIR/Emojis/Backups/product/*Emoji.ttf $MODPATH/product/fonts
      fi
      if [ -f $FCDIR/Emojis/Backups/system/product/NotoColorEmoji.ttf ]; then
        mkdir -p $MODPATH/system/product/fonts
        mv -f $FCDIR/Emojis/Backups/system/product/*Emoji.ttf $MODPATH/system/product/fonts
      fi
      if [ -f $FCDIR/Emojis/Backups/system/NotoColorEmoji.ttf ]; then
        mkdir -p $MODPATH/system/fonts
        mv -f $FCDIR/Emojis/Backups/system/*Emoji.ttf $MODPATH/system/fonts
      fi
      rm $FCDIR/Emojis/Backups
      break
      ;;
    n)
      echo -e "${R}Removing Emojis${N}"
      if [ -d $FCDIR/Emojis/Backups ]; then
        rm $FCDIR/Emojis/Backups
      fi
      for i in $MODPATH/system/fonts/*Emoji*; do
        if [ -e "$i" ]; then
          rm -f $i
        fi  
      done
      for i in $MODPATH/product/fonts/*Emoji*; do
        if [ -e "$i" ]; then
          rm -f $i
        fi
      done
      for i in $MODPATH/system/product/fonts/*Emoji*; do
        if [ -e "$i" ]; then
          rm -f $i
        fi
      done
      truncate -s 0 $CEMOJI
      break
      ;;
    q)
      echo -e "${R}[-] Quiting...${N}"
      clear
      quit
      ;;
    r)
      echo -e "${G}[-] Return to Menu Selected...${N}"
      ;;
    *)
      invaild
      $SLEEP 1.5
      ;;
    esac
  done
  return_menu
}
#######################################################################################################
#                                        Update Emoji/Font Lists                                      #
#######################################################################################################
update_lists() {
  currVer=$(wget https://john-fawkes.com/Downloads/hahafontlist/fonts-list.txt --output-document - | wc -l)
  currVer2=$(wget https://john-fawkes.com/Downloads/hahaemojilist/emojis-list.txt --output-document - | wc -l)
  instVer=$(cat $FCDIR/fonts-list.txt | wc -l)
  instVer2=$(cat $FCDIR/emojis-list.txt | wc -l)
  echo -e "${B}Checking For Updates...${N}"
  if [ $currVer -gt $instVer ] || [ $currVer -lt $instVer ]; then
    echo -e "${G}[-] Checking For Internet Connection... [-]${N}"
    test_connection3
    if ! "$CON3"; then
      test_connection2
      if ! "$CON2"; then
        test_connection
      fi
    fi
    if "$CON1" || "$CON2" || "$CON3"; then
      rm $FCDIR/fonts-list.txt
      mkdir -p $FCDIR/Fonts/Custom
      $CURL -k -o $FCDIR/fonts-list.txt https://john-fawkes.com/Downloads/hahafontlist/fonts-list.txt
      if [ $instVer != $currVer ]; then
        echo -e "${B}[-] Fonts Lists Downloaded Successfully... [-]${N}"
      else
        echo -e "${R}[!] Error Downloading Fonts Lists... [!]${N}"
      fi
    else
      abort "${R}[!] No Internet Detected... [!]${N}"
    fi
  else
    echo -e "${R}No Font List Updates Found${N}"
  fi
  if [ $currVer2 -gt $instVer2 ] || [ $currVer2 -lt $instVer2 ]; then
    echo -e "${B}[-] Checking For Internet Connection... [-]${N}"
    test_connection3
    if ! "$CON3"; then
      test_connection2
      if ! "$CON2"; then
        test_connection
      fi
    fi
    if "$CON1" || "$CON2" || "$CON3"; then
      rm $FCDIR/emojis-list.txt
      mkdir -p $FCDIR/Emojis/Custom
      $CURL -k -o $FCDIR/emojis-list.txt https://john-fawkes.com/Downloads/hahaemojilist/emojis-list.txt
      if [ $instVer2 != $currVer2 ]; then
        echo -e "${B}[-] Emoji Lists Downloaded Successfully... [-]${N}"
      else
        echo -e "${R}[!] Error Downloading Emoji Lists... [!]${N}"
      fi
    else
      abort "${R}[!] No Internet Detected... [!]${N}"
    fi
  else
    echo -e "${R}No Emoji List Updates Found${N}"
  fi
}
#######################################################################################################
#                                        Delete Downloaded Zips                                       #
#######################################################################################################
clear_font_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    CHECKFONTS=$(du -hs $FCDIR/Fonts/*.zip | cut -c-4)
    if is_not_empty $FCDIR/Fonts; then
      echo -e "${B}Checking Space...${N}"
      echo -e " "
      echo -e "${B}Your Font Zips are Taking Up $CHECKFONTS Space${N}"
      echo -e " "
      echo -e "${G}[-] Would You Like to Delete the Downloaded Font Zips to Save Space?${N}"
      echo -e " "
      echo -e "${B}[-] Select an Option...${N}"
      echo -e " "
      echo -e "${W}[Y]${N} ${G} - Yes${N}"
      echo -e " "
      echo -e "${W}[N]${N} ${G} - No${N}"
      echo -e " "
      echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
      echo -e " "
      echo -e "${R}[Q] - Quit${N}"
      echo -e " "
      echo -e "${B}[CHOOSE] : ${N}"
      echo -e " "
      read -r choice
      case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
        y)
          echo -e "${Y}[-] Deleting Font Zips${N}"
        #            find $FCDIR/Fonts -depth -mindepth 1 -maxdepth 1 -type d ! -regex '^$FCDIR/Fonts/Custom\(/.*\)?' -type d ! -regex '^$FCDIR/Fonts/User\(/.*\)?' -type d ! -regex '^$FCDIR/Fonts/avfonts\(/.*\)?' -delete
          for i in $FCDIR/Fonts/*.zip; do
            rm -f $i
          done
          break
        ;;
        n)
          echo -e "${R}[-] Not Removing Fonts${N}"
          break
        ;;
        q)
          echo -e "${R}[-] Quiting...${N}"
          clear
          quit
        ;;
        r)
          echo -e "${G}[-] Return to Menu Selected...${N}"
          return_menu
          break
        ;;
        *)
          invaild
          $SLEEP 1.5
        ;;
      esac
    else
      echo -e "${R}[-] No Emoji Zips Found${N}"
    fi
  done
  return_menu
}
clear_emoji_menu() {
  choice=""
  CHECKEMOJI=$(du -hs $FCDIR/Emojis/*.zip | cut -c-4)
  while [ "$choice" != "q" ]; do
    if is_not_empty $FCDIR/Emojis; then
      echo -e "${B}Checking Space...${N}"
      echo -e " "
      echo -e "${B}Your Emoji Zips are Taking Up $CHECKEMOJI Space${N}"
      echo -e " "
      echo -e "${G}[-] Would You Like to Delete the Downloaded Emoji Zips to Save Space?${N}"
      echo -e " "
      echo -e "${B}[-] Select an Option...${N}"
      echo -e " "
      echo -e "${W}[Y]${N} ${G} - Yes${N}"
      echo -e " "
      echo -e "${W}[N]${N} ${G} - No${N}"
      echo -e " "
      echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
      echo -e " "
      echo -e "${R}[Q] - Quit${N}"
      echo -e " "
      echo -e "${B}[CHOOSE] : ${N}"
      echo -e " "
      read -r choice
      case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
        y)
          echo -e "${Y}[-] Deleting Emoji Zips${N}"
        #            find $FCDIR/Fonts -depth -mindepth 1 -maxdepth 1 -type d ! -regex '^$FCDIR/Fonts/Custom\(/.*\)?' -type d ! -regex '^$FCDIR/Fonts/User\(/.*\)?' -type d ! -regex '^$FCDIR/Fonts/avfonts\(/.*\)?' -delete
          for i in $FCDIR/Emojis/*.zip; do
            rm -f $i
          done
          break
        ;;
        n)
          echo -e "${R}[-] Not Removing Emojis${N}"
          break
        ;;
        q)
          echo -e "${R}[-] Quiting...${N}"
          clear
          quit
        ;;
        r)
          echo -e "${G}[-] Return to Menu Selected...${N}"
          return_menu
          break
        ;;
        *)
          invaild
          $SLEEP 1.5
        ;;
      esac
    else
      echo -e "${R}[-] No Emoji Zips Found${N}"
      return_menu
    fi
  done
  return_menu
}
clear_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    echo -e " "
    echo -e "${G}[-] Would You Like to Delete the Emoji Zips or Font Zips to Save Space?${N}"
    echo -e " "
    echo -e "${B}[-] Select an Option...${N}"
    echo -e " "
    echo -e "${W}[1]${N} ${G} - Emojis${N}"
    echo -e " "
    echo -e "${W}[2]${N} ${G} - Fonts${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
      1)
        echo -e "${G}[-] Emojis Zips...${N}"
        clear_emoji_menu
        break
      ;;
      2)
        echo -e "${R}[-] Fonts Zips${N}"
        clear_font_menu
        break
      ;;
      r)
        echo -e "${B}[-] Return to Menu Selected...${N}"
        return_menu
        break
      ;;
      q)
        echo -e "${R}[-] Quitting...${N}"
        clear
        quit
      ;;
      *)
        invalid
      ;;
    esac
  done
}
#######################################################################################################
#                                             Random                                                  #
#######################################################################################################
random_menu() {
  choice=""
  choice2=""
  choice3=""
  while [ "$choice" != "q" ]; do
    FRANDOM="$(((RANDOM % 243) + 1))"
    echo -e "${G}Would You Like to Choose a Random Font?${N}"
    echo -e "${G}Please Enter (y)es or (n)o...${N}"
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    y)
      echo -e "${G}Applying Random Font...${N}"
      if [ -e $MODPATH/random.txt ]; then
        truncate -s 0 $MODPATH/random.txt
      else
        touch $MODPATH/random.txt
      fi
      echo -e $FRANDOM >> $MODPATH/random.txt
      choice="$(cat $MODPATH/random.txt)"
      choice3="$(sed -n ${choice}p $FCDIR/fonts-list.txt)"
      choice2="$(echo -e $choice3 | sed 's/.zip//')"
      #    choice2="$(sed -n ${choice}p $FCDIR/fonts-list.txt | tr -d '.zip')"
      $SLEEP 2
      if [ -d $MODPATH/system ] || [ -d $MODPATH/product ]; then
        for i in $MODPATH/*/*/*Emoji*.ttf; do
          if [ -e $i ]; then
            mv -f $i $MODPATH
          fi
        done
      fi
      if [ -d $MODPATH/system/product ]; then
        for i in $MODPATH/*/*/*/*Emoji*.ttf; do
          if [ -e $i ]; then
            mv -f $i $MODPATH
          fi
        done
      fi
      if [ -d $MODPATH/system/fonts ]; then
        rm -rf $MODPATH/system/fonts
      fi
      if [ -d $MODPATH/product/fonts ]; then
        rm -rf $MODPATH/product/fonts
      fi
      if [ -d $MODPATH/system/product/fonts ]; then
        rm -rf $MODPATH/system/product/fonts
      fi
      [ -e $FCDIR/Fonts/$choice2.zip ] || $CURL -k -o "$FCDIR/Fonts/$choice2.zip" https://john-fawkes.com/Downloads/haha$choice2.zip
      mkdir -p $FCDIR/Fonts/$choice2
      unzip -o "$FCDIR/Fonts/$choice2.zip" -d $FCDIR/Fonts/$choice2
      if [ -d $MIRROR/product/fonts ]; then
        mkdir -p $MODPATH/product/fonts
        cp -f $FCDIR/Fonts/$choice2/* $MODPATH/product/fonts
      fi
      if [ -d $MIRROR/system/product/fonts ]; then
        mkdir -p $MODPATH/system/product/fonts
        cp -f $FCDIR/Fonts/$choice2/* $MODPATH/system/product/fonts
      fi
      if [ -d $MIRROR/system/fonts ]; then
        mkdir -p $MODPATH/system/fonts
        cp -f $FCDIR/Fonts/$choice2/* $MODPATH/system/fonts
      fi
      for i in $MODPATH/*Emoji*.ttf; do
        if [ -e $i ]; then
          cp -f $i $MODPATH/product/fonts
          cp -f $i $MODPATH/system/product/fonts
          mv -f $i $MODPATH/system/fonts
        fi
      done
      lg_device
      pixel
      samsung_device
      oxygen
      android10
      if [ -d $FCDIR/Fonts/$choice2 ]; then
        rm -rf $FCDIR/Fonts/$choice2
      fi
      if [ -d $MIRROR/product/fonts ]; then
        set_perm_recursive $MODPATH/product/fonts 0 0 0755 0644
      fi
      if [ -d $MIRROR/system/product/fonts ]; then
        set_perm_recursive $MODPATH/system/product/fonts 0 0 0755 0644
      fi
      if [ -d $MIRROR/system/fonts ]; then
        set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
      fi
      [ -f $CFONT ] || touch $CFONT
      truncate -s 0 $CFONT
      echo "CURRENT=$choice2" >> $CFONT
      if [ -d $MODPATH/product/fonts ]; then
        is_not_empty_font $MODPATH/product/fonts
      elif [ -d $MODPATH/system/product/fonts ]; then
        is_not_empty_font $MODPATH/system/product/fonts
      elif [ -d $MODPATH/system/fonts ]; then
        is_not_empty_font $MODPATH/system/fonts
      fi
      ;;
    n)
      return_menu
      ;;
    *)
      invaild
      $SLEEP 1.5
      ;;
    esac
  done
}
#######################################################################################################
#                                               Menus                                                 #
#######################################################################################################
choose_font_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    echo -e "${G}Which Font Option Would You Like to Choose?${N}"
    echo -e " "
    echo -e "${W}[1]${N} ${G} - List of Downloadable Fonts${N}"
    echo -e " "
    echo -e "${W}[2]${N} ${G} - Random Font${N}"
    echo -e " "
    echo -e "${W}[3]${N} ${G} - Custom Fonts${N}"
    echo -e " "
    echo -e "${W}[R] - Return to Main Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    1)
      echo -e "${B}[-] Downloadable Fonts Selected...${N}"
      font_menu
      break
      ;;
    2)
      echo -e "${B}[-] Random Font Selected...${N}"
      random_menu
      break
      ;;
    3)
      echo -e "${Y}[-] Custom Fonts Selected...${N}"
      custom_menu
      break
      ;;
    r)
      echo -e "${B}[-] Return to Menu Selected...${N}"
      return_menu
      ;;
    q)
      echo -e "${R}[-] Quitting...${N}"
      clear
      quit
      ;;
    *)
      invalid
      ;;
    esac
  done
}

choose_emoji_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    echo -e "${G}Which Emoji Option Would You Like to Choose?${N}"
    echo -e " "
    echo -e "${W}[1]${N} ${G} - List of Downloadable Emojis${N}"
    echo -e " "
    echo -e "${W}[2]${N} ${G} - Custom Emojis${N}"
    echo -e " "
    echo -e "${W}[R] - Return to Main Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    1)
      echo -e "${B}[-] Downloadable Emojis Selected...${N}"
      emoji_menu
      break
      ;;
    2)
      echo -e "${Y}[-] Custom Emojis Selected...${N}"
      custom_emoji_menu
      break
      ;;
    r)
      echo -e "${B}[-] Return to Menu Selected...${N}"
      return_menu
      ;;
    q)
      echo -e "${R}[-] Quitting...${N}"
      clear
      quit
      ;;
    *)
      invalid
      ;;
    esac
  done
}

choose_help_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    echo -e "${G}Which Help Option Would You Like to Choose?${N}"
    echo -e " "
    echo -e "${W}[1]${N} ${G} - Custom Font Help${N}"
    echo -e " "
    echo -e "${W}[2]${N} ${G} - Help with Shortcuts${N}"
    echo -e " "
    echo -e "${W}[R] - Return to Main Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    1)
      echo -e "${R}[-] Custom Fonts Help Selected...${N}"
      help_custom
      break
      ;;
    2)
      echo -e "${Y}[-] Shortcut Flags Help Selected...${N}"
      help
      break
      ;;
    r)
      echo -e "${B}[-] Return to Menu Selected...${N}"
      return_menu
      ;;
    q)
      echo -e "${R}[-] Quitting...${N}"
      clear
      quit
      ;;
    *)
      invalid
      ;;
    esac
  done
}

hidden_menu() {
  rm -f $MODPATH/.branches.txt 2>&1
  branches=($(curl https://api.github.com/repos/xaffan/fontchanger-scripts/branches | grep "name" | sed 's/name//' | sed 's/://' | sed 's/"//' | sed 's/"//' | sed 's/,//'))  choice=""
  while [ "$choice" != "q" ]; do
  clear
  echo -e " "
  pcenter "${B}Welcome to the Dark Side${N}"
  echo -e " "
  $test_connection || { echo -e "${G}Internet is Needed For This, Going Back to Main Menu\n${N}"; sleep 4 && menu; }
  echo -e "${Y}Current branch:${N}"
  echo -e " "
  echo -e "${W}$branch${N}"
  echo -e " "
  echo -e "${B}Which Branch Would You like to Update to?${N}"
  echo -e " "
  c=1
  for i in ${branches[@]}; do
    echo -e "${W}[$c]${N} ${B}$i${N}" | grep $i | sed 's/"//' | sed 's/"//' && echo -e "[$c] $i" | grep $i | sed 's/"//' | sed 's/"//' >> $MODPATH/.branches.txt
    echo -e " "
    c=$((c+1))
  done
    echo -e "${W}[R] - Return to Main Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    branchchoice="$(grep -w $choice $MODPATH/.branches.txt | tr -d '[' | tr -d ']' | tr -d "$choice" | tr -d ' ')"
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
      *)
        if [ $choice = "q" ]; then
          echo -e "${R}Quiting...${N}"
          clear
          quit
        elif [ $choice = "r" ]; then
          return_menu
        elif [[ -n ${choice//[0-9]/} ]]; then
          invalid
        else
          echo -e " Switched Branch to $branchchoice"
          sed -i "s/^branch=.*/branch=$branchchoice/" $MODPATH/system/bin/font_changer
          umount -l /system/bin/font_changer; mount -o bind $MODPATH/system/bin/font_changer /system/bin/font_changer;
          break
        fi
      ;;
    esac
  done
  return_menu
}

changelog_func() {
  echo -e "Latest Changes"
  NUM=$(grep -n "Changelog" $MODPATH/.changelog | sed -re "s|([[:digit:]]):.*|\1|")
  tail -n +$NUM $MODPATH/.changelog | sed -n '/^$/q;p'
  echo -e " "
  echo -e "${W}[R] - Return to Main Menu${N}"
  echo -e " "
  echo -e "${R}[Q] - Quit${N}"
  echo -e " "
  echo -e "${B}[CHOOSE] : ${N}"
  echo -e " "
  read -r choice
  case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    r)
      echo -e "${B}[-] Return to Menu Selected...${N}"
      return_menu
      ;;
    q)
      echo -e "${R}[-] Quitting...${N}"
      clear
      quit
      ;;
    *)
      invalid
      ;;
  esac
}
