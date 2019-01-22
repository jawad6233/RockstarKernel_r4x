#!/bin/bash
#
# LH Kernel build script
#
# Copyright (C) 2017 Luan Halaiko and Ashishm94 (tecnotailsplays@gmail.com)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#colors
black='\033[0;30m'
red='\033[0;31m'
green='\033[0;32m'
brown='\033[0;33m'
blue='\033[0;34m'
purple='\033[1;35m'
cyan='\033[0;36m'
nc='\033[0m'

#directories
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/arch/arm64/boot/Image.gz-dtb
ZIP_DIR=$KERNEL_DIR/repack
CONFIG_DIR=$KERNEL_DIR/arch/arm64/configs

#export
export CROSS_COMPILE="$HOME/kernel/Uber-8.0/bin/aarch64-linux-android-"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="LuanHalaiko"
export KBUILD_BUILD_HOST="TimeStopMachine"
export KBUILD_LOUP_CFLAGS="-Wno-misleading-indentation -Wno-bool-compare -O2"

#misc
CONFIG=santoni_defconfig
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"

#ASCII art
echo -e "$cyan############################ WELCOME TO #############################"
echo -e "                  __                   __  __      __  __  __           "
echo -e "                 / /   /\  /\   /\ /\ /__\/__\  /\ \ \/__\/ /           "
echo -e "                / /   / /_/ /  / //_//_\ / \// /  \/ /_\ / /            "
echo -e "               / /___/ __  /  / __ \//__/ _  \/ /\  //__/ /___          "
echo -e "               \____/\/ /_/   \/  \/\__/\/ \_/\_\ \/\__/\____/          "
echo -e "                                                                        "
echo -e "\n############################# BUILDER ###############################$nc"

#main script
while true; do
echo -e "\n$green[1]Build"
echo -e "[2]Regenerate defconfig"
echo -e "[3]Source cleanup"
echo -e "[4]Create flashable zip"
echo -e "[5]Quit$nc"
echo -ne "\n$blue(i)Please enter a choice[1-5]:$nc "

read choice

if [ "$choice" == "1" ]; then
echo -e "\n$green[a]Build revolution version"
echo -ne "\n$blue--LH--$nc "

read cpu

if [ "$cpu" == "b" ]; then
patch -p1 < 0001-nuke-cpu-oc.patch &>/dev/null
fi
  BUILD_START=$(date +"%s")
  DATE=`date`
  echo -e "\n$cyan#######################################################################$nc"
  echo -e "$brown(i)Build started at $DATE$nc"
  make $CONFIG $THREAD &>/dev/null
  make $THREAD &>buildlog.txt & pid=$!
  spin[0]="$blue-"
  spin[1]="\\"
  spin[2]="|"
  spin[3]="/$nc"

  echo -ne "$blue[Please wait...] ${spin[0]}$nc"
  while kill -0 $pid &>/dev/null
  do
    for i in "${spin[@]}"
    do
          echo -ne "\b$i"
          sleep 0.1
    done
  done
  if ! [ -a $KERN_IMG ]; then
    echo -e "\n$red(!)Kernel compilation failed, See buildlog to fix errors $nc"
    echo -e "$red#######################################################################$nc"
    exit 1
  fi
  $DTBTOOL -2 -o $KERNEL_DIR/arch/arm/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/ &>/dev/null &>/dev/null
if [ "$cpu" == "b" ]; then
patch -p1 -R < 0001-nuke-cpu-oc.patch &>/dev/null
fi
  BUILD_END=$(date +"%s")
  DIFF=$(($BUILD_END - $BUILD_START))
  echo -e "\n$brown(i)zImage and dtb compiled successfully.$nc"
  echo -e "$cyan#######################################################################$nc"
  echo -e "$purple(i)Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nc"
  echo -e "$cyan#######################################################################$nc"
fi


if [ "$choice" == "2" ]; then
  echo -e "\n$cyan#######################################################################$nc"
  make $CONFIG
  cp .config arch/arm64/configs/$CONFIG
  echo -e "$purple(i)Defconfig generated.$nc"
  echo -e "$cyan#######################################################################$nc"
fi

if [ "$choice" == "3" ]; then
  echo -e "\n$cyan#######################################################################$nc"
  rm -f $DT_IMG
  make clean &>/dev/null
  make mrproper &>/dev/null
  echo -e "$purple(i)Kernel source cleaned up.$nc"
  echo -e "$cyan#######################################################################$nc"
fi


if [ "$choice" == "4" ]; then
  echo -e "\n$cyan#######################################################################$nc"
  if [ "$cpu" == "b" ]; then
  patch -p1 < 0001-nuke-cpu-oc.patch &>/dev/null
  fi
  cd $ZIP_DIR
  make clean &>/dev/null
  cp $KERN_IMG $ZIP_DIR/boot/zImage
  make &>/dev/null
  make sign &>/dev/null
  cd ..
  if [ "$cpu" == "b" ]; then
  patch -p1 -R < 0001-nuke-cpu-oc.patch &>/dev/null
  fi
  echo -e "$purple(i)Flashable zip generated under $ZIP_DIR.$nc"
  echo -e "$cyan#######################################################################$nc"
fi


if [ "$choice" == "5" ]; then
 exit 1
fi
done
