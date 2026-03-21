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
dnf module disable redis -y &>>$LOGS_FILES
VALIDATE $? "disable deafault version of redis"

dnf module enable redis:7 -y &>>$LOGS_FILES
VALIDATE $? "enable redis 7 version"

dnf install redis -y &>>$LOGS_FILES
VALIDATE $? "install redis "

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf
VALIDATE $? "OKAY"

systemctl enable redis &>>$LOGS_FILES
VALIDATE $? "enable redis"

systemctl start redis &>>$LOGS_FILES
VALIDATE $? "start rediss"