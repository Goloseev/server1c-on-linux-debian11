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

function prepare_sources_for_debian_libenchant1c2a () { 

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

    }


#---------------------------------------------------------------------------------------------------------------------------
# тело скрипта
#---------------------------------------------------------------------------------------------------------------------------
echo-yellow "[ INFO ] starting $0"

#перейдем в текущий каталог скрипта
SCRIPT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $SCRIPT_FOLDER

# прочитаем версию 1С из 1-го параметра при запуске скрипта
VERSION=$1
if [ -z "${VERSION}" ]; then
    echo-red "[ ERROR ] Need not empty VERSION. You can send it in first Param    ($0)"
    echo-red "[ EXAMPLE ] ./AL_Download_1c_platform.sh 8.3.22.1709 x64 My_login My_Pass    ($0)"
    exit 111
else
    echo-blue "[ INFO ] Get 1 Param VERSION=$VERSION    ($0)"
fi


# 2й параметр  PLATFORM
PLATFORM=$2
if [ -z "${PLATFORM}" ]; then
    echo-red "[ ERROR ] Need not empty PLATFORM. You can send it in second Param    ($0)"
    echo-red "[ EXAMPLE ] ./AL_Download_1c_platform.sh 8.3.22.1709 x64 My_login My_Pass    ($0)"
    exit 112
elif [ "$PLATFORM" != "x64" ]  &&  [ "$PLATFORM" != "x32" ];  then
    echo-red "[ ERROR ] Second parm PLATFORM must be x64 or x32  (not be $PLATFORM)   ($0)"
    echo-yellow "[ EXAMPLE ] ./AL_Download_1c_platform.sh 8.3.22.1709 x64 My_login My_Pass    ($0)"
    exit 112
else
    echo-blue "[ INFO ] Get 2 Param PLATFORM=$PLATFORM    ($0)"
fi




# запускаем обновление пакетов (без этого, возможно, не установит curl)
echo-blue "[ INFO ] updating and upgrading     ($0)"
apt-get update  > /dev/null 
apt-get upgrade -y > /dev/null

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $SCRIPT_DIR

#echo-blue "[ INFO ] installing curl     ($0)"
#apt-get install -y curl apt-utils > /dev/null
#Для CentOS
#yum install -y epel-release \
#	&& yum install -y fontconfig-devel fontconfig freetype libgsf unixODBC ImageMagick \ 
#	&& yum install -y nano mc net-tools passwd openssh-server openssh-clients procps   \
#	&& yum install -y iproute usbutils \
#	&& yum install -y wget bzip2 traceroute net-tools nano bind-utils telnet htop atop iftop lsof git rsync policycoreutils-python-utils tar zip unzip \
#   && yum install -y langtable glibc-locale-source glibc-langpack-ru \
#   && yum install -y curl tree\
#   && yum install -y cabextract  xorg-x11-font-utils ImageMagick \
#	&& yum clean all \
#	&& ssh-keygen -A \
#	&& fc-cache -s \
#	&& useradd usr1cv8 \
#	&& groupadd grp1cv8 \
#	&& usermod -a -G grp1cv8 usr1cv8 


#предварительная установка libenchant1c2a
prepare_sources_for_debian_libenchant1c2a
echo-blue "[ INFO ] installing libenchant1c2a     ($0)"
export DEBIAN_FRONTEND="noninteractive"
apt-get install -y libenchant1c2a > /dev/null 



#проверяем есть ли дистрибутив и скачиваем при необходимости
SUBFOLDER_NAME=distrib
VERSION_UnderLine=${VERSION//./_}



if [[ -z "$PLATFORM" ]]; then
    echo-red "[ ERROR ] PLATFORM should not be empty (x64 or x32)    ($0)"
    exit 888
elif [ "$PLATFORM" = "x64" ]; then
    SERVER_POSTFIX="server64"
    RUN_FILE_PATH="setup-full-${VERSION}-x86_64.run"
elif [ "$PLATFORM" = "x32" ]; then
    SERVER_POSTFIX="server32"
    RUN_FILE_PATH="setup-full-${VERSION}-i386.run"
else
    echo-red "[ ERROR ] PLATFORM must be x64 or x32 (now PLATFORM=$PLATFORM)   ($0)"
    exit 888
fi


SERVER_ARCHIVE_FILE_NAME="${SERVER_POSTFIX}_${VERSION_UnderLine}.tar.gz"

#технологическая платформа
FILE_PATH_SERVER="./$SUBFOLDER_NAME/$SERVER_ARCHIVE_FILE_NAME"
if ! [ -e $FILE_PATH_SERVER ];then
    chmod +x ./AL_Download_1c_platform.sh
    ./AL_Download_1c_platform.sh $VERSION
else
    echo-blue "[ INFO ] finded $FILE_PATH_SERVER     ($0)"
fi

cd ./$SUBFOLDER_NAME/ 

#распакуем скачанный архив
VERSION_UnderLine=`echo "$VERSION" | sed 's/\./_/g'`    
echo-blue "[ INFO ] unpacking $SERVER_ARCHIVE_FILE_NAME     ($0)" 
tar -xzf $SERVER_ARCHIVE_FILE_NAME


if ! [ -e $RUN_FILE_PATH ];then
    echo-red "[ ERROR ] did not finded RUN_FILE_PATH=$RUN_FILE_PATH     ($0)"
    apt-get install -y tree >> /dev/null
    tree .
    exit 444
else
    echo-blue "[ INFO ] finded RUN_FILE_PATH=$RUN_FILE_PATH     ($0)"
    chmod +x $RUN_FILE_PATH
fi

# –mode unattended - Пакетный режим
#  –enable-components - указываем компоненты
#Идентификатор	Описание
#additional_admin_functions	Установить утилиту административной консоли (см. здесь).
#client_full	Установить толстый клиент и возможность работы в конфигураторе.
#client_thin	Установить тонкий клиент (без возможности работы с файловым вариантом информационной базы).
#client_thin_fib	Установить тонкий клиент, который позволяет работать с любым вариантом информационной базы.
#config_storage_server	Установить сервер хранилища конфигураций.
#integrity_monitoring	Установить утилиту контроля целостности (см. здесь).
#liberica_jre	Установить Java Runtime Environment (JRE).
#server	Установить кластер серверов «1С:Предприятия».
#server_admin	Установить сервер администрирования кластера серверов «1С:Предприятия» ((см. здесь).
#ws	Установить модули расширения веб-сервера.


if [ $RUN_MODE = "SERVER_MODE" ]; then
  components_list="server"
elif [ $RUN_MODE = "WS_MODE" ]; then
    components_list="ws"
elif [ $RUN_MODE = "CLIENT_MODE" ]; then
    components_list="client_full,client_thin,client_thin_fib"
else
    components_list="server,server_admin,ws,client_full,client_thin,client_thin_fib"
fi

#chown root ./*
#tree -up .

#echo-yellow "[ ATTENTION ] linux version is"
#uname -a

if  [ "$PLATFORM" = "32" ];  then
    #включим совместимость с 32 битными программами
    echo-magenta "[ WARNING ] probably installing x32 platform will show error NO SUCH FILE         ($0)" 
    #dpkg --add-architecture i386
    #echo-magenta "[ INFO ] apt-get update >> /dev/null         ($0)" 
    #apt-get update >> /dev/null
    #echo-magenta "[ INFO ] Installing libgsf-1-114         ($0)" 
    #apt-get install -y libgsf-1-114 >> /dev/null
    #echo-magenta "[ INFO ] apt-get install libc6:i386         ($0)" 
    #apt-get install libc6:i386
    #echo-magenta "[ INFO ] apt-get -f install         ($0)" 
    #apt-get -f install
fi


echo-blue "[ INFO ] installing components_list=$components_list      RUN_FILE_PATH=${RUN_FILE_PATH}         ($0)" 
./"$RUN_FILE_PATH" --mode unattended --enable-components $components_list
#./setup-full-8.3.22.1709-i386.run --mode unattended --enable-components $components_list
echo-green "[ SUCCESS ] INSTALLING FINISHED     ($0)"

# из старой инструкции на диске ИТС такое еще нашел
apt-get install -y libfreetype6 libgsf-1-common unixodbc glib2.0  > /dev/null 

#скрипт запускаем из docker, потому запуск не делаем
exit 0

#Даже если это docker - любопытно запустить....
#Настройка автозапуска службы (начиная 8.3.21) имя экземпляра default
echo-blue "[ INFO ] ACTIVATING AUTORUN SERVICE     ($0)"
systemctl link /opt/1cv8/x86_64/${VERSION}/srv1cv8-${VERSION}@.service


systemctl enable srv1cv8-${VERSION}@
#systemctl start|stop|restart|status srv1cv8-${VERSION}@default
systemctl start srv1cv8-${VERSION}@default
echo-blue "[ INFO ] ... DONE ACTIVATING     ($0)"


#посмотрим что получилось...
systemctl status srv1cv8-${VERSION}@default
ps ax | grep "1C"

