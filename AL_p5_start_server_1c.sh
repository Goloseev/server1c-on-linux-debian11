#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
export DEBIAN_FRONTEND="noninteractive"


#вспомогательные функции
function echo-red     { COLOR='\033[31m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-green   { COLOR='\033[32m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-yellow  { COLOR='\033[33m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-blue    { COLOR='\033[34m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-magenta { COLOR='\033[35m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-cyan    { COLOR='\033[36m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }

echo-yellow "[ INFO ] ... starting script $0 "
# прочитаем версию 1С из 1-го параметра при запуске скрипта
VERSION=$1
if [ -z "${VERSION}" ]; then
    echo-red "[ ERROR ] Need not empty VERSION. You can send it in first Param    ($0)"
    echo-red "[ EXAMPLE ] ./AL_p4_start_server_1c.sh 8.3.22.1709     ($0)"
    exit 111
else
    echo-blue "[ INFO ] Get 1 Param VERSION=$VERSION    ($0)"
fi


#Даже если это docker - любопытно запустить....
#Настройка автозапуска службы (начиная 8.3.21) имя экземпляра default
echo-blue "[ INFO ] ACTIVATING AUTORUN SERVICE     ($0)"
systemctl link /opt/1cv8/x86_64/${VERSION}/srv1cv8-${VERSION}@.service


systemctl enable srv1cv8-${VERSION}@
#systemctl start|stop|restart|status srv1cv8-${VERSION}@default

echo-blue "[ INFO ] ... STARTING SERVICE     ($0)"
systemctl start srv1cv8-${VERSION}@default

echo-blue "[ INFO ] ... DONE ACTIVATING     ($0)"


#посмотрим что получилось...
echo-blue "[ INFO ] ... SHOWING SERVICE STATUS     ($0)"
systemctl status srv1cv8-${VERSION}@default

echo-blue "[ INFO ] ... SHOWING PROCESSES LIST     ($0)"
ps ax | grep "1C"

