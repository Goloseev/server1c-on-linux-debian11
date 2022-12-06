#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
export DEBIAN_FRONTEND="noninteractive"

#инструкция от 1С https://its.1c.ru/db/metod8dev/content/5953/hdoc
#еще инструкция https://interface31.ru/tech_it/2021/10/edinyy-distributiv-1c-dlya-linux-server.html

#вспомогательные функции
function echo-red     { COLOR='\033[31m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-green   { COLOR='\033[32m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-yellow  { COLOR='\033[33m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-blue    { COLOR='\033[34m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }

    



#
# тело скрипта
echo-yellow "[ INFO $0 ] starting $0"



echo-blue "[ INFO $0 ] preparing sources for debian fonts "
# для Debian
need_lib_string="deb http://deb.debian.org/debian/ bullseye contrib non-free"
need_lib_string2="deb-src http://deb.debian.org/debian/ bullseye contrib non-free"

#need_lib_string3="deb http://security.debian.org/debian-security bullseye contrib non-free"
#need_lib_string4="deb-src http://security.debian.org/debian-security bullseye contrib non-free"


if grep -Fxq "$need_lib_string" /etc/apt/sources.list
then
    # code if found
    
    echo-blue "[ INFO $0 ] finded sources contrib and non-free ($need_lib_string)"
else
    # code if not found
    echo-yellow "[ INFO $0 ] adding to sources contrib and non-free "
    echo " " >> /etc/apt/sources.list
    echo "#" >> /etc/apt/sources.list
    echo "#for ms fonts adding contrib and non-free source" >> /etc/apt/sources.list
    echo $need_lib_string >> /etc/apt/sources.list
    echo $need_lib_string2 >> /etc/apt/sources.list
    #echo $need_lib_string3 >> /etc/apt/sources.list
    #echo $need_lib_string4 >> /etc/apt/sources.list
    echo "#" >> /etc/apt/sources.list
    # updating 
    echo-blue "[ INFO $0 ] updating"
    apt-get update  > /dev/null 

fi


#непосредственно установка шрифтов
echo-blue "[ INFO $0 ] installing fonts (may be long)"
apt-get install -y ttf-mscorefonts-installer libodbc1 > /dev/null 
echo-blue "[ INFO $0 ] ....finished installing fonts"


