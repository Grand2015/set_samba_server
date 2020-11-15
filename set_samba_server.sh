#!/bin/bash
echo "Project: Build Samba Server Env"
echo "Author: Grand li"
echo "Version: 1.0"
echo "Date:2:15 2020/11/16"


#1.Install Samba APP
sudo apt-get install samba -y
sudo apt-get install cifs-utils -y
sudo apt-get install smbclient -y

#2.Set Samba Server Param
#Create share dir
NAME=${USER}
cd /home/${NAME}/

if [ ! -d "/home/${NAME}/share" ]; then
	echo "/share not is exit..."	
else
	echo "/share is exit"
	rm -rf /home/${NAME}/share
fi

sudo mkdir -p /home/${NAME}/share
echo "dir /home/${NAME}/share created...[OK]"
sudo chmod -R 777 /home/${NAME}/share


SHARE_PATH="/home/${NAME}/share"
echo ${SHARE_PATH}

#Modify Samba cfg file
if [ ! -d "/etc/samba" ]; then
	echo "/share not is exit, samba app install check...[FAIL]"
	echo "Build Samba Server Env...[FAIL]"
	return
fi

if [ ! -f "/etc/samba/smb.conf" ]; then
	echo "smb.conf not is exit, please check samba app install is OK or not"
	echo "Build Samba Server Env...[FAIL]"
	return
fi

#conf file back
if [ ! -f "/etc/samba/smb.conf.bak" ]; then
	echo "smb.conf not is exit, creat it"
	sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
fi

sudo chmod -R 777 /etc/samba/smb.conf
CNOF_FILE_PATH="/etc/samba/smb.conf"

:<<BLOCK
FILE_PATH="${SHARE_PATH}/smb.conf"
if [ ! -f ${FILE_PATH} ]; then
	echo "smb.conf not is exit, creat it"
else
	rm -rf ${FILE_PATH}
fi
touch ${FILE_PATH}
BLOCK

#check conf is modefied or not
sudo sed -i '/\[share\]/,$d' ${CNOF_FILE_PATH}

echo -e "[share]" >> ${CNOF_FILE_PATH}
echo -e "\tpath = /home/${NAME}/share" >> ${CNOF_FILE_PATH}
echo -e "\tavailable = yes" >> ${CNOF_FILE_PATH}
echo -e "\tbrowseable = yes" >> ${CNOF_FILE_PATH}
echo -e "\tbrowseable = yes" >> ${CNOF_FILE_PATH}
echo -e "\tpublic = yes" >> ${CNOF_FILE_PATH}
echo -e "\twritable = yes" >> ${CNOF_FILE_PATH}


#add user
sudo useradd ${NAME}

#set login password
sudo touch /etc/samba/smbpasswd
sudo smbpasswd -a ${NAME}


USER_FILE_PATH="/etc/samba/smbusers"
if [ ! -f ${USER_FILE_PATH} ]; then
	echo "smbusers not is exit, creat it"
else
	sudo rm -rf ${USER_FILE_PATH}
fi
sudo touch ${USER_FILE_PATH}
sudo chmod -R 777 ${USER_FILE_PATH}

echo -e "myname = \"networkusername\"" >> ${USER_FILE_PATH}

#restart samba server
SAMBA_FILE_PATH="/etc/init.d/samba"
SAMBA_FILE_PATH_BAK="/etc/cron.daily/samba"

if [ -f ${SAMBA_FILE_PATH} ]; then
	sudo ${SAMBA_FILE_PATH} restart
else
	echo "${SAMBA_FILE_PATH} not exit, research ${SAMBA_FILE_PATH_BAK}"
	if [ -f ${SAMBA_FILE_PATH_BAK} ]; then
		sudo ${SAMBA_FILE_PATH_BAK} restart
	else
		echo "${SAMBA_FILE_PATH_BAK} not exit}"
		echo "Build Samba Server Env...[FAIL]"
		return
	fi			
fi

echo "Build Samba Server Env...[OK]"
echo "Enjoy it"








