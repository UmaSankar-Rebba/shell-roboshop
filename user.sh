#!/bin/bash
USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILES="/var/log/shell-roboshop/$0.log"
R="\e[31m"
G="\e[32m"
C="\e[36m"
N="\e[0m"
SCRIPT_DIR=$PWD

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

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
VALIDATE $? "dsable and enable nodejs"

dnf install nodejs -y
VALIDATE $? "install nodejs"

id roboshop
if [ $? -ne 0 ]; then {
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "creating system user"
}
else
 echo -e "$C User already exists....! Skipping $N"


mkdir -p /app
VALIDATE $? "Creating new folder"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip
VALIDATE $? "Downloading the code"

cd /app
VALIDATE $? "changing to app dir"

rm -rf /app/*
VALIDATE $? "removing the existing files"

unzip /tmp/user.zip
VALIDATE $? "unzipping file"

npm install
VALIDATE $? "installing"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service

systemctl daemon-reload
VALIDATE $? "reloading"

systemctl enable user
systemctl start user
VALIDATE $? "enable and start"