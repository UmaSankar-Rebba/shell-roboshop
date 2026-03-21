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

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
VALIDATE $? "disable and enable node js"

dnf install nodejs -y
VALIDATE $? "install nodejs"

id roboshop
if [ $? -ne 0 ]; then {
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "system user"
}
else
 echo -e "$C User already added.Skipping $N"
fi

mkdir -p /app
VALIDATE $? "create directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
cd /app
rm -rf /app/*
unzip /tmp/cart.zip
VALIDATE $? "unzip the copied file"

npm install
VALIDATE $? "Installing"

cp cart.service /etc/systemd/system/cart.service
VALIDATE $? "cart.service is copied"

systemctl daemon-reload
VALIDATE $? "reload the system"

systemctl enable cart 
systemctl start cart
VALIDATE $? "enable and start the service"