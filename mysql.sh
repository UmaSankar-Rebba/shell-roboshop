#!/bin/bash
USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILES="/var/log/shell-roboshop/$0.log"
R="\e[31m"
G="\e[32m"
C="\e[36m"
N="\e[0m"   

if [ $USER_ID -ne 0 ]; then
 echo -e " $R You dont have permission to access this operation $N.$G Please contact sudo Admin $N"
 exit 1
fi
mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
     echo -e "$R $2 is Failure $N" | tee -a $LOGS_FILES
     exit 1
    else
     echo -e "$G $2 is Success $N" | tee -a $LOGS_FILES
    fi
}

dnf install mysql-server -y
VALIDATE $? "installing mysql"

systemctl enable mysqld
VALIDATE $? "enabled mysqld"

systemctl start mysqld
VALIDATE $? "start mysqld"

read password
mysql_secure_installation --set-root-pass $password