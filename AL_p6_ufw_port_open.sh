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


echo-yellow "[ INFO ] Starting script $0 "

echo-blue "[ INFO ] ... installing ufw    ($0) "
apt-get install -y ufw >> //dev/null

echo-blue "[ INFO ] ... enabling ufw    ($0) "
yes | sudo ufw enable


echo-blue "[ INFO ] ... opening 1540-1541 ports    ($0) "
sudo ufw allow 1540:1541/tcp >> //dev//null

echo-blue "[ INFO ] ... opening 1560-1590 ports    ($0) "
sudo ufw allow 1560:1590/tcp >> //dev//null

#Вероятно, надо добавить порт ssh иначе установленный ufw заблокирует
#будущие подключения по ssh
echo-blue "[ INFO ] ... opening shh port    ($0) "
sudo ufw allow ssh >> //dev//null

echo-blue "[ INFO ] FINISHED    ($0) "