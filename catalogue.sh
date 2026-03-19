#!/bin/bash
USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILES="/var/log/shell-roboshop/$0.log"
R="\e[31m"
G="\e[32m"
C="\e[36m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST="mongodb.rebba.online"


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
VALIDATE $? "Disabling nodejs default version"

dnf module enable nodejs:20 -y&>>$LOGS_FILES
VALIDATE $? "ENABLE NODEJS 20 version"

dnf install nodejs -y&>>$LOGS_FILES
VALIDATE $? "Installing nodejs"

id roboshop
if [ $? -ne 0 ]; then {
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating system user"
}
else
 echo -e "$C User already exists skipping $N"
fi
mkdir -p /app
VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILES
VALIDATE $? "Downloading catalogue code"

cd /app
VALIDATE $? "Changing directory"

rm -rf /app/*
VALIDATE $? "Removing existing data in the folder"

unzip /tmp/catalogue.zip &>>$LOGS_FILES
VALIDATE $? "Unzip the code file"

npm install &>>$LOGS_FILES
VALIDATE $? "INstalling dependiens"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "reload and starting the service"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILES
dnf install mongodb-mongosh -y

mongosh --host $MONGODB_HOST </app/db/master-data.js