VERSION="8.3.22.1709"
PLATFORM="x64" #may be x32 or x64

#перейдем в текущий каталог скрипта
SCRIPT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $SCRIPT_FOLDER


#1 Скачиваем дистрибутив
./AL_p1_download_1c_platform.sh $VERSION $PLATFORM  login password
#2 устанавливаем шрифты MS
./AL_p2_Install_fonts.sh
#3 Устанавливаем библиотеку libenchant1c2a
./AL_p3_install_libenchant1c2a.sh
#4 Устанавливаем сервер
./AL_p4_install_server_1c.sh $VERSION $PLATFORM 
#5 Запускаем сервер
./AL_p5_start_server_1c.sh $VERSION $PLATFORM  
#6 Открываем порты
./AL_p6_ufw_port_open.sh
