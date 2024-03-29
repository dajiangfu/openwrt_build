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

#新建非root用户
function add_user(){
  #创建一个用户名为cloud的用户并指定bash为终端
  sudo useradd -r -m -s /bin/bash cloud
  #给用户cloud添加一个密码
  sudo passwd cloud
  #编辑用户权限，因/etc/sudoers文件默认是只读文件，因此需先添加sudoers文件的写权限
  sudo chmod +w /etc/sudoers
  #编辑 sudoers 文件，按i进入编辑模式，在User privilege specification的root ALL=(ALL) ALL一行下面加入cloud ALL=(ALL:ALL) ALL然后按esc后输入:wq保存并退出 vim 编辑器
  sudo vim /etc/sudoers
  #安全考虑建议撤销sudoers文件写权限
  sudo chmod -w /etc/sudoers
  #切换到刚才创建的新用户（两次输入su cloud，输入密码不会显示）
  su cloud
}
#初次编译
function build_openwrt(){
  #安装编译依赖
  sudo apt update -y
  sudo apt full-upgrade -y
  sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
  bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
  git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev \
  libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz \
  mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pip qemu-utils \
  rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
  #下载源代码，更新 feeds 并选择配置
  git clone https://github.com/coolsnowwolf/lede
  cd lede
  read -s -n1 -p "按任意键继续 ... " #此处将脚本暂停后面的命令继续运行，如果想添加其他插件，添加完成后再按任意键继续
  ./scripts/feeds update -a
  ./scripts/feeds install -a
  make menuconfig
  #下载dl库，编译固件（-j后面是线程数，第一次编译推荐用单线程）
  make download -j8
  make V=s -j1
}

#重新编译
function rebuild_openwrt(){
  cd lede
  git pull
  ./scripts/feeds update -a
  ./scripts/feeds install -a
  read -p "是否重新配置 ?请输入 [Y/n] :" yn
  [ -z "${yn}" ] && yn="y"
  if [[ $yn == [Yy] ]]; then
    rm -rf ./tmp
    rm -rf .config
    make menuconfig
  else
    make defconfig
  fi
  make download -j8
  make V=s -j$(nproc)
}

#修复并编译(make clean仅仅是清除之前编译的可执行文件及配置文件)
function repair_build_openwrt(){
  cd lede
  make clean
  git pull
  ./scripts/feeds update -a
  ./scripts/feeds install -a
  rm -rf ./tmp
  rm -rf .config
  make menuconfig
  make download -j8
  make V=s -j$(nproc)
}

#完全重新编译(make distclean要清除所有生成的文件)
function comre_build_openwrt(){
  cd lede
  make distclean
  git pull
  ./scripts/feeds update -a
  ./scripts/feeds install -a
  rm -rf ./tmp
  rm -rf .config
  make menuconfig
  make download -j8
  make V=s -j1
}

start_menu(){
  clear
  green "====================================="
  green " 介绍：一键编译openwrt(lede版)源码   "
  green " 系统：>=ubuntu14.0                  "
  green " 作者：dajiangfu                     "
  green " 网站：www.github.com/dajiangfu      "
  green "====================================="
  blue  "注意"
  blue  "1、不要用root用户进行编译"
  blue  "2、国内用户编译前最好准备好梯子"
  blue  "3、默认登陆IP 192.168.1.1 密码 password"
  blue  "4、编译完成后输出路径：bin/targets"
  green "====================================="
  echo
  green " 1. 新建非root用户"
  green " 2. 初次编译"
  green " 3. 重新编译"
  green " 4. 修复并编译(make clean)"
  green " 5. 完全重新编译(make distclean)"
  blue " 0. 退出脚本"
  echo
  read -p "请输入数字:" num
  case "$num" in
  1)
  add_user
  ;;
  2)
  build_openwrt
  ;;
  3)
  rebuild_openwrt 
  ;;
  4)
  repair_build_openwrt
  ;;
  5)
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
