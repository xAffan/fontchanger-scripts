set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm $MODPATH/curl 0 0 0755
  set_perm $MODPATH/sleep 0 0 0755
  set_perm $MODPATH/zip 0 0 0755
  set_perm $MODPATH/bash 0 0 0755
  if [ -e $MODPATH/busybox ]; then
    set_perm $MODPATH/busybox 0 0 0755
  fi
  set_perm $MODPATH/font_changer 0 0 0700

  for file in $MODPATH/*.sh; do
    [ -f $file ] && set_perm $file  0  0  0700
  done

  ui_print " "
  ui_print " [-] After Installing type su then hit enter and type font_changer in terminal [-] "
  ui_print " [-] Then Choose Option 4 to Read the How-to on How to Set up your Custom Fonts [-] "
  sleep 3
#  set +x
}

test_connection4 () {
test=google.com
if nc -zw1 $test 443 && echo | openssl s_client -connect $test:443 2>&1 | awk 'handshake && $1 == "Verification" { if ($2=="OK") exit; exit 1 } $1 $2 == "SSLhandshake" { handshake = 1 }'; then
  echo "we have connectivity"
fi
}

test_connection() {
  ui_print " [-] Testing internet connection [-] "
  $TMPDIR/busybox-$ARCH32 ping -q -c 1 -W 1 google.com >/dev/null 2>&1 && ui_print " [-] Internet Detected [-] "; CON1=true; CON2=true || { exxit " [-] Error, No Internet Connection [-] "; CON=false; CON2=false; }
}

test_connection2() {
  case "$($TMPDIR/curl-$ARCH32 -s --max-time 2 -I http://google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23]) ui_print " [-] HTTP connectivity is up [-] "
    CON1=true
    CON2=true
    ;;
  5) ui_print " [!] The web proxy won't let us through [!] "
    CON1=false
    CON2=false
    ;;
  *) ui_print " [!] The network is down or very slow [!] "
    CON1=false
    CON2=false
    ;;
esac
}

get_var() { sed -n 's/^name=//p' ${1}; }

set_vars() {
  MODTITLE="$(grep_prop name $MODPATH/module.prop)"
  VER=$(grep_prop version $MODPATH/module.prop)
  AUTHOR=$(grep_prop author $MODPATH/module.prop)
  MAGISK_VER="$(grep_prop MAGISK_VER_CODE /data/adb/magisk/util_functions.sh)"
  FCDIR=/storage/emulated/0/Fontchanger
  MOD_VER="/data/adb/modules/Fontchanger/module.prop"
}

version_changes() {
  ui_print " "
  ui_print "  LATEST CHANGES"
  ui_print " "
  NUM=$(grep -n "Changelog" $TMPDIR/README.md | sed -re "s|([[:digit:]]):.*|\1|")
  tail -n +$NUM $TMPDIR/README.md | sed -n '/^$/q;p'
  ui_print " " 
  ui_print "If you would like to donate to me you can do so by going to https://paypal.me/BBarber61"
  ui_print " "

  ui_print "  LINKS"
  ui_print "   - Git repository: github.com/Magisk-Modules-Repo/${MODID}/"
  ui_print "   - Telegram group: https://t.me/fontchange_magisk"
  ui_print "   - Telegram profile: t.me/xaffan/"
  set +euo pipefail
}

download_files() {
ui_print " - Downloading needed files"
wget -O $MODPATH/font_changer https://github.com/xaffan/fontchanger-scripts/raw/master/font_changer 2>/dev/null
wget -O $MODPATH/Fontchanger-functions.sh https://github.com/xaffan/fontchanger-scripts/raw/master/Fontchanger-functions.sh 2>/dev/null
wget -O $MODPATH/listforcustom.txt https://github.com/xaffan/fontchanger-scripts/raw/master/listforcustom.txt 2>/dev/null
#wget -O $MODPATH/service.sh https://github.com/xaffan/fontchanger-scripts/raw/master/service.sh 2>/dev/null
wget -O $MODPATH/uninstall.sh https://github.com/xaffan/fontchanger-scripts/raw/master/uninstall.sh 2>/dev/null
wget -O $MODPATH/fonts-list.txt https://github.com/xaffan/fontchanger-scripts/raw/master/fonts-list.txt 2>/dev/null
}

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
elif [ -d /sbin/.magisk/modules/busybox-ndk ]; then
  BUSY=$(find /sbin/.magisk/modules/busybox-ndk/system/* -maxdepth 0 | sed 's#.*/##')
  for i in $BUSY; do
    PATH=/sbin/.magisk/modules/busybox-ndk/system/$i:$PATH
    _bb=/sbin/.magisk/modules/busybox-ndk/system/$i/busybox
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
elif [ -f $TMPDIR/tools/busybox ]; then
  PATH=$TMPDIR/tools:$PATH
  _bb=$TMPDIR/tools/busybox
elif [ -d /sbin/.magisk/busybox ]; then
  PATH=/sbin/.magisk/busybox:$PATH
  _bb=/sbin/.magisk/busybox/busybox
fi

set_busybox $_bb
[ $? -ne 0 ] && exit $?

set_vars
if $BOOTMODE; then
  ui_print "Checking for any other font modules installed... "
  MODULESPATH=/data/adb/modules || require_new_magisk
  for i in $MODULESPATH*; do
    if [[ $i != *Fontchanger ]]; then
      if [ ! -f $i/disable ]; then
        if [ -d $i/system/fonts ]; then
          NAME=$(get_var $i/module.prop)
          ui_print " [!] "
          ui_print " [!] Module editing fonts detected [!] "
          ui_print " [!] Module - $NAME [!] "
          ui_print " [!] "
          exxit
        fi
      fi
    fi
  done
  if [ -d /data/adb/modules/Fontchanger/system ] || [ -d /data/adb/modules/Fontchanger/product ]; then
    ui_print "Backing Up Installed Fonts and/or Emojis"
    if [ -d /data/adb/modules/Fontchanger/system ]; then
      cp -rf /data/adb/modules/Fontchanger/system $MODPATH 2>&1
    fi
    if [ -d /data/adb/modules/Fontchanger/product ]; then
      cp -rf /data/adb/modules/Fontchanger/product $MODPATH 2>&1
    fi
    for i in /data/adb/modules/Fontchanger/*.txt; do
      if [ -e $i ]; then
        cp -f $i $MODPATH 2>&1
      fi
    done
    for k in /data/adb/modules/Fontchanger/*.log; do
      if [ -e $k ]; then
        cp -f $k  $MODPATH 2>&1
      fi
    done
    if [ -d $MODPATH/system ] || [ -d $MODPATH/product ]; then
      ui_print " [-] Backup and Restore Successful [-] "
    fi
  fi
  ui_print " [-] Downloading Needed Binary Files [-] "
  wget -O $TMPDIR/tools.zip https://github.com/xaffan/fontchanger-scripts/raw/master/tools.zip
  ui_print " [-] Extracting module files [-] "
#  unzip -o "$ZIPFILE" "$MODID/*" -d ${MODPATH%/*}/ 2>&1
  unzip -o "$ZIPFILE" 'README.md' -d $TMPDIR 2>&1
  mkdir -p $TMPDIR/tools
  unzip -o "$TMPDIR/tools.zip" -d $TMPDIR/tools 2>&1
  mkdir -p /storage/emulated/0/Fontchanger/Fonts/Custom 2>&1
  mkdir -p /storage/emulated/0/Fontchanger/Emojis/Custom 2>&1
  chmod 0755 $TMPDIR/tools/curl-$ARCH32
  chmod 0755 $TMPDIR/tools/busybox-$ARCH32
  ui_print " [-] Checking For Internet Connection... [-] "
  test_connection
#  [[ "$CON1" == "true" ]] ||  abort " [!] Internet Connection is Needed... [!]"
  [[ "$CON1" == "true" ]] || test_connection2
  [[ "$CON2" == "true" ]] || abort " [!] Internet Connection is Needed... [!]"
  if "$CON1" || "$CON2"; then
    for i in /storage/emulated/0/Fontchanger/*-list.txt; do
      if [ -e $i ]; then
        rm $i 2>&1
      fi
    done
    $TMPDIR/tools/curl-$ARCH32 -k -o /storage/emulated/0/Fontchanger/fonts.txt https://john-fawkes.com/Downloads/haha/fonts-list.txt
    $TMPDIR/tools/curl-$ARCH32 -k -o /storage/emulated/0/Fontchanger/emojis-list.txt https://john-fawkes.com/Downloads/haha/emojilist/emojis-list.txt
    if [ -f /storage/emulated/0/Fontchanger/fonts.txt ] && [ -f /storage/emulated/0/Fontchanger/emojis-list.txt ]; then
      ui_print " [-] All Lists Downloaded Successfully... [-] "
    else
      ui_print " [!] Error Downloading Lists... [!] "
    fi
  else
    exxit " [!] No Internet Detected... [!] " 
  fi
else
  ui_print " [!] Only uninstall is supported in recovery [!] "
  rm -rf $MODPATH $NVBASE/modules_update/$MODID $TMPDIR 2>/dev/null
  abort "Uninstalling!"
fi
cp -f $TMPDIR/tools/curl-$ARCH32 $MODPATH/curl 2>&1
cp -f $TMPDIR/tools/sleep-$ARCH32 $MODPATH/sleep 2>&1
cp -f $TMPDIR/tools/zip-$ARCH32 $MODPATH/zip 2>&1
cp -f $TMPDIR/tools/bash-$ARCH32 $MODPATH/bash 2>&1
if [ -d /data/adb/modules/busybox-ndk ]; then
  ui_print "Busybox Already Installed" 2>&1
else
  cp -f $TMPDIR/tools/busybox-$ARCH32 $MODPATH/busybox 2>&1
fi
download_files
version_changes
mkdir -p $MODPATH/system/bin
set_permissions
mv $MODPATH/font_changer $MODPATH/system/bin/font_changer
if [ -d /sbin/.Fontchanger ]; then
  rm -rf /sbin/.Fontchanger
fi
rm -rf $TMPDIR/tools
set +x
