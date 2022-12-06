#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
export DEBIAN_FRONTEND="noninteractive"

#инстуркция от 1С https://its.1c.ru/db/metod8dev/content/5953/hdoc
#еще инструкция https://interface31.ru/tech_it/2021/10/edinyy-distributiv-1c-dlya-linux-server.html
# и еще https://github.com/pqr/docker-apache-1c-example/blob/master/README.md


#вспомогательные функции
function echo-red     { COLOR='\033[31m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-green   { COLOR='\033[32m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-yellow  { COLOR='\033[33m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-blue    { COLOR='\033[34m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-magenta { COLOR='\033[35m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-cyan    { COLOR='\033[36m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }


#---------------------------------------------------------------------------------------------------------------------------
# тело скрипта
#---------------------------------------------------------------------------------------------------------------------------
echo-yellow "[ INFO ] starting $0"

#перейдем в текущий каталог скрипта
SCRIPT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $SCRIPT_FOLDER


# запускаем обновление пакетов (без этого, возможно, не установит что-нибудь потом)
echo-blue "[ INFO ] updating and upgrading     ($0)"
apt-get update  > /dev/null 
apt-get upgrade -y > /dev/null

echo-blue "[ INFO ] preparing sources for debian libenchant1c2a     ($0)"
# для Debian
#archive_source_string="deb http://cz.archive.ubuntu.com/ubuntu focal main universe"
need_lib_string="deb http://ftp.ru.debian.org/debian buster main"
if grep -Fxq "$need_lib_string" /etc/apt/sources.list
then
    # code if found
    
    echo-blue "[ INFO ] finded sources for libenchant1c2a ($need_lib_string)     ($0)"
else
    # code if not found
    echo-yellow "[ INFO ] adding to sources $need_lib_string     ($0)"
    echo " " >> /etc/apt/sources.list
    echo "#" >> /etc/apt/sources.list
    echo "#for libenchant1c2a adding source" >> /etc/apt/sources.list
    echo $need_lib_string >> /etc/apt/sources.list
    echo "#" >> /etc/apt/sources.list
    # updating 
    echo-blue "[ INFO ] updating     ($0)"
    apt-get update  > /dev/null 

fi


echo-blue "[ INFO ] installing libenchant1c2a     ($0)"
export DEBIAN_FRONTEND="noninteractive"
apt-get install -y libenchant1c2a > /dev/null 

echo-blue "[ INFO ] FINISHED     ($0)"


