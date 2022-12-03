#!/bin/bash
#Version 2022-11-24

set -e # Exit immediately if a command exits with a non-zero status.

#вспомогательные функции
function echo-red     { COLOR='\033[31m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-green   { COLOR='\033[32m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-yellow  { COLOR='\033[33m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-blue    { COLOR='\033[34m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-magenta { COLOR='\033[35m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }
function echo-cyan    { COLOR='\033[36m' ; NORMAL='\033[0m' ; echo -e "${COLOR}$1${NORMAL}"; }

#clear
echo-yellow "[ INFO ] STARTED AL_download_1c_platform.sh----- $0"

#перейдем в текущий каталог скрипта
SCRIPT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $SCRIPT_FOLDER

SUBFOLDER_NAME="distrib"

#USERNAME=$ARG_SITE_1C_LOGIN
#PASSWORD=$ARG_SITE_1C_PASSWORD


# прочитаем версию 1С из 1-го параметра при запуске скрипта
VERSION=$1
if [ -z "${VERSION}" ]; then
    echo-red "[ ERROR ] Need not empty VERSION. You can send it in first Param    ($0)"
    echo-red "[ EXAMPLE ] ./AL_Download_1c_platform.sh 8.3.22.1709 no My_login My_Pass    ($0)"
    exit 111
else
    echo-blue "[ INFO ] Get 1 Param VERSION=$VERSION    ($0)"
fi


# 2й параметр  PLATFORM
PLATFORM=$2
if [ -z "${PLATFORM}" ]; then
    echo-red "[ ERROR ] Need not empty PLATFORM. You can send it in second Param    ($0)"
    echo-red "[ EXAMPLE ] ./AL_Download_1c_platform.sh 8.3.22.1709 no My_login My_Pass    ($0)"
    exit 112
elif [ "$PLATFORM" != "x64" ]  &&  [ "$PLATFORM" != "x32" ];  then
    echo-red "[ ERROR ] Second parm PLATFORM must be x64 or x32  (not be $PLATFORM)   ($0)"
    echo-yellow "[ EXAMPLE ] ./AL_Download_1c_platform.sh 8.3.22.1709 no My_login My_Pass    ($0)"
    exit 112
else
    echo-blue "[ INFO ] Get 2 Param PLATFORM=$PLATFORM    ($0)"
fi


# 3й параметр  USERNAME
USERNAME=$3
if [[ -z "$USERNAME" ]];then
    echo-red "[ ERROR ] Need not empty USERNAME. You can send it in Third Param    ($0)"
    echo-red "[ EXAMPLE ] ./AL_Download_1c_platform.sh 8.3.22.1709 no My_login My_Pass    ($0)"
    exit 1
else
    echo-blue "[ INFO ] Get 3 Param USERNAME=$USERNAME    ($0)"
fi

# 4й параметр  PASSWORD
PASSWORD=$4
if [[ -z "$PASSWORD" ]];then
    echo-red "[ ERROR ] Need not empty PASSWORD. You can send it in Fourth Param    ($0)"
    echo-red "[ EXAMPLE ] ./AL_Download_1c_platform.sh 8.3.22.1709 no My_login My_Pass    ($0)"
    exit 1
else
    echo-blue "[ INFO ] Get 4 Param PASSWORD=******    ($0)"
fi


#создадим SUBFOLDER, если его еще нет
if  [ -d ./$SUBFOLDER_NAME ];then
    echo-blue "[ INFO ] finded subfolder $SUBFOLDER_NAME    ($0)"
else
    echo-blue "[ INFO ] creating subfolder $SUBFOLDER_NAME    ($0)"
    mkdir -p ./$SUBFOLDER_NAME
fi

#подготовим имя платофрмы с "_" вместо точек
VERSION_UnderLine=${VERSION//./_}



if [[ -z "$PLATFORM" ]]; then
    echo-red "[ ERROR ] PLATFORM should not be empty (x64 or x32)    ($0)"
    exit 888
elif [ "$PLATFORM" = "x64" ]; then
    SERVER_POSTFIX="server64"
elif [ "$PLATFORM" = "x32" ]; then
    SERVER_POSTFIX="server32"
else
    echo-red "[ ERROR ] PLATFORM must be x64 or x32 (now PLATFORM=$PLATFORM)   ($0)"
    exit 888
fi

SERVER_ARCHIVE_FILE_NAME="${SERVER_POSTFIX}_${VERSION_UnderLine}.tar.gz"


#технологическая платформа
FILE_PATH_SERVER="./$SUBFOLDER_NAME/$SERVER_ARCHIVE_FILE_NAME"

echo-blue "[ INFO ] FILE_PATH_SERVER=$FILE_PATH_SERVER"


if [ -e $FILE_PATH_SERVER ];then
    echo-yellow "[ INFO ] server already downloaded in $FILE_PATH_SERVER    ($0)"
    exit 0
else
    echo-blue "[ INFO ] need to download $FILE_PATH_SERVER    ($0)"
fi

if ! command -v curl > /dev/null; then
    #НаДо поставить  curl в тихом режиме (потребует sudo)
    echo-blue "[ INFO ] installing curl    ($0)"
    apt-get install -y curl > /dev/null
else
    echo-blue "[ INFO ] curl already installed    ($0)"
fi


echo-blue "[ INFO ] try to login on https://releases.1c.ru    ($0)"

HTML_PAGE=$(curl -c /tmp/cookies.txt -s -L https://releases.1c.ru)

if [[ "$HTML_PAGE" == *"DDoS protection by DDos-Guard"* ]]; then
  echo-red "[ ERROR ] 1C enabled DDos protection page, so download by script blocked."
  echo-yellow "[ INFO ] IF IT IS DOCKER-CONTAINER"
  echo-yellow "[ INFO ] YOU NEED MANUALLY DOWNLOAD $SERVER_ARCHIVE_FILE_NAME"
  echo-yellow "[ INFO ] AND PUT IT IN _source-1c/distrib folder"
  echo-yellow "[ INFO ] THEN IN Dockerfile copy (not add) to /tmp/distrib/"
  echo-yellow "[ INFO ] example: COPY ./distrib/$SERVER_ARCHIVE_FILE_NAME /tmp/distrib/"
  
  exit 777
fi

#echo-magenta "1+ HTML_PAGE=$HTML_PAGE"
ACTION=$(echo "$HTML_PAGE" | grep -oP '(?<=form method="post" id="loginForm" action=")[^"]+(?=")')
#echo-magenta "2+"
#echo-magenta "2+ ACTION=$ACTION"
EXECUTION=$(echo "$HTML_PAGE" | grep -oP '(?<=input type="hidden" name="execution" value=")[^"]+(?=")')
#echo-magenta "3+ EXECUTION=$EXECUTION"

#echo-magenta "4+"
#auth
curl -s -L \
    -o /dev/null \
    -b /tmp/cookies.txt \
    -c /tmp/cookies.txt \
    --data-urlencode "inviteCode=" \
    --data-urlencode "execution=$EXECUTION" \
    --data-urlencode "_eventId=submit" \
    --data-urlencode "username=$USERNAME" \
    --data-urlencode "password=$PASSWORD" \
    https://login.1c.ru"$ACTION"

#echo-magenta "333"

if ! grep -q "TGC" /tmp/cookies.txt ;then
    echo-red "[ ERROR ] Auth failed    ($0)"
    exit 22
else
    echo-blue "[ SUCCESS ] logined in users.v8.1c.ru    ($0)"
fi



#технологическая платформа
FILE_PATH_SERVER="./$SUBFOLDER_NAME/${SERVER_POSTFIX}_${VERSION_UnderLine}.tar.gz"


echo-blue "[ INFO ] starting to download 1c server $VERSION    ($0)"

URL_PATH_SERVER="Platform%5c$VERSION_UnderLine%5c${SERVER_POSTFIX}_$VERSION_UnderLine.tar.gz"
URL_HTML_PAGE="https://releases.1c.ru/version_file?nick=Platform83&ver=$VERSION&path=$URL_PATH_SERVER"
HTML_TEXT=$(curl -s -G -b /tmp/cookies.txt $URL_HTML_PAGE)
URL_FOR_DOWNLOAD=$(echo "$HTML_TEXT" | grep -o 'href="https://dl03[^"]*' | tail -c +7)


if [[ -z "$URL_FOR_DOWNLOAD" ]];then
    echo-red "[ ERROR ] DIDNOT FINDED URL FOR DOWNLOAD ON PAGE URL_HTML_PAGE    ($0)"
    exit 111
fi

echo-blue "[ INFO ] url for download is  $URL_FOR_DOWNLOAD ($0)"
curl --fail -b /tmp/cookies.txt -o $FILE_PATH_SERVER -L "$URL_FOR_DOWNLOAD"

if [ -e $FILE_PATH_SERVER ];then
    echo-green "[ SUCCESS ] downloaded $FILE_PATH_SERVER    ($0)"
else
    echo-red "[ ERROR ] Did not finded archive with platform  $FILE_PATH_SERVER    ($0)"
fi


#тонкий клиент (не очень то нужен, на самом деле)
THIN_CLIENT_POSTFIX=thin.client64
FILE_PATH_THIN_CLIENT="./$SUBFOLDER_NAME/${THIN_CLIENT_POSTFIX}_${VERSION_UnderLine}.tar.gz"
URL_PATH_THIN_CLIENT="Platform%5c$VERSION_UnderLine%5c${THIN_CLIENT_POSTFIX}_$VERSION_UnderLine.tar.gz"

#удалим куки...
rm /tmp/cookies.txt