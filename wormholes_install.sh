#!/bin/bash

echo -e "\033[0;35m"
echo "  _     ___  ____ ____  _   _  ___  ____  _____ ";
echo " | |   / _ \/ ___/ ___|| \ | |/ _ \|  _ \| ____|";
echo " | |  | | | \___ \___ \|  \| | | | | | | |  _|  ";
echo " | |__| |_| |___) |__) | |\  | |_| | |_| | |___ ";
echo " |_____\___/|____/____/|_| \_|\___/|____/|_____|";
echo -e "\e[0m"

sleep 3


echo "Sistem guncellemesi yapiliyor.."
sleep 2
sudo apt update && apt upgrade -y

cd $HOME

echo "Docker kurulumu yapiliyor.."
sleep 2

sudo apt install docker.io -y
sudo systemctl enable --now docker

#check docker cmd
which docker >/dev/null 2>&1
if  [ $? -ne 0 ] ; then
     echo "docker bulunamadi, lutfen docker yukleyin.."
     echo "->ubuntu:sudo apt install docker.io -y"
     echo "->centos:yum install  -y docker-ce "
     echo "->fedora:sudo dnf  install -y docker-ce"
     exit
fi
#check docker service
docker ps > /dev/null 2>&1
if [ $? -ne 0 ] ; then

     echo "docker servisi calismiyor, lutfen once servisi baslatin:"
     echo "->sudo service docker start"
     exit
fi

docker stop wormholes > /dev/null 2>&1
docker rm wormholes > /dev/null 2>&1
docker rmi wormholestech/wormholes:v1 > /dev/null 2>&1

if [ -d /wm/.wormholes/keystore ]; then
   read -p "Wormholes blokchain veri gecmisini temizlemek istiyorsaniz “y”ye basin, istemiyorsaniz “enter.”a basin：" xyz
   if [ "$xyz" = 'y' ]; then
         rm -rf /wm/.wormholes
              read -p "Private key'inizi girin：" ky
   else
         echo "Temizlenmedi"
   fi
else
   read -p "Private key'inizi import edin：" ky
fi

mkdir -p /wm/.wormholes/wormholes
if [ -n "$ky" ]; then
    if [ ${#ky} -eq 64 ];then
        echo $ky > /wm/.wormholes/wormholes/nodekey
    elif [ ${#ky} -eq 66 ] && ([ ${ky:0:2} == "0x" ] || [ ${ky:0:2} == "0X" ]);then
        echo ${ky:2:64} > /wm/.wormholes/wormholes/nodekey
    else
        echo "Nodekey formati yanlis!"
        exit -1
    fi
fi         

docker run -id -e KEY=$ky  -p 31303:30303 -p 8745:8545 -v /wm/.wormholes:/wm/.wormholes --name wormholes wormholestech/wormholes:v0.11.6

echo "Private key'iniz:"
sleep 5
docker exec -it wormholes /usr/bin/cat /wm/.wormholes/wormholes/nodekey
