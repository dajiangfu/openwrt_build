#!/bin/bash

blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

#初次编译
function build_openwrt(){
  sudo apt-get update
  sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3.5 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib linux-libc-dev:i386
  git clone https://github.com/coolsnowwolf/lede
  cd lede
  ./scripts/feeds update -a
  ./scripts/feeds install -a
  make menuconfig
  make -j1 V=s
}

#重新编译
function rebuild_openwrt(){
  cd lede
  git pull
  ./scripts/feeds update -a
  ./scripts/feeds install -a
  rm -rf ./tmp
  rm -rf .config
  make menuconfig
  make -j1 V=s
}

#修复并编译(make clean)
function repair_build_openwrt(){
  cd lede
  make clean
  git pull
  ./scripts/feeds update -a
  ./scripts/feeds install -a
  rm -rf ./tmp
  rm -rf .config
  make menuconfig
  make -j1 V=s
}

#完全重新编译(make distclean)
function comre_build_openwrt(){
  cd lede
  make distclean
  git pull
  ./scripts/feeds update -a
  ./scripts/feeds install -a
  rm -rf ./tmp
  rm -rf .config
  make menuconfig
  make -j1 V=s
}

start_menu(){
    clear
    green " ===================================="
    green " 介绍：一键编译openwrt(lede版)源码   "
    green " 系统：>=ubuntu14.0                  "
    green " 作者：dajiangfu                     "
    green " 网站：www.github.com/dajiangfu      "
    green " ===================================="
    echo
    green " 1. 初次编译"
    green " 2. 重新编译"
    green " 3. 修复并编译(make clean)"
    green " 4. 完全重新编译(make distclean)"
    blue " 0. 退出脚本"
    echo
    read -p "请输入数字:" num
    case "$num" in
    1)
    build_openwrt
    ;;
    2)
    rebuild_openwrt 
    ;;
    3)
    repair_build_openwrt
    ;;
    4)
    comre_build_openwrt
    ;;
    0)
    exit 1
    ;;
    *)
    clear
    red "请输入正确数字"
    sleep 1s
    start_menu
    ;;
    esac
}

start_menu
