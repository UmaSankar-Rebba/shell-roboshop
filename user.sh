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

dnf module disable nodejs -y &>>$LOGS_FILES
dnf module enable nodejs:20 -y &>>$LOGS_FILES
VALIDATE $? "dsable and enable nodejs"

dnf install nodejs -y &>>$LOGS_FILES
VALIDATE $? "install nodejs"

id roboshop
if [ $? -ne 0 ]; then {
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop&>>$LOGS_FILES
    VALIDATE $? "creating system user"
}
else
 echo -e "$C User already exists....! Skipping $N"
fi


mkdir -p /app
VALIDATE $? "Creating new folder"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOGS_FILES
VALIDATE $? "Downloading the code"

cd /app
VALIDATE $? "changing to app dir"

rm -rf /app/* &>>$LOGS_FILES
VALIDATE $? "removing the existing files"

unzip /tmp/user.zip &>>$LOGS_FILES
VALIDATE $? "unzipping file"

npm install &>>$LOGS_FILES
VALIDATE $? "installing"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service

systemctl daemon-reload &>>$LOGS_FILES
VALIDATE $? "reloading"

systemctl enable user &>>$LOGS_FILES
systemctl start user &>>$LOGS_FILES
VALIDATE $? "enable and start"