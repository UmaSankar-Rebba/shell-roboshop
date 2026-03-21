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
dnf module enable nodejs:20 -y&>>$LOGS_FILES
VALIDATE $? "disable and enable node js"

dnf install nodejs -y &>>$LOGS_FILES
VALIDATE $? "install nodejs"

id roboshop
if [ $? -ne 0 ]; then {
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILES
    VALIDATE $? "system user"
}
else
 echo -e "$C User already added.Skipping $N"
fi

mkdir -p /app
VALIDATE $? "create directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOGS_FILES
cd /app
rm -rf /app/*
unzip /tmp/cart.zip &>>$LOGS_FILES
VALIDATE $? "unzip the copied file"

npm install &>>$LOGS_FILES
VALIDATE $? "Installing"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "cart.service is copied"

systemctl daemon-reload &>>$LOGS_FILES
VALIDATE $? "reload the system"

systemctl enable cart &>>$LOGS_FILES
systemctl start cart &>>$LOGS_FILES
VALIDATE $? "enable and start the service"