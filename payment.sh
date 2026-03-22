#!/bin/bash
USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILES="/var/log/shell-roboshop/$0.log"
R="\e[31m"
G="\e[32m"
C="\e[36m"
N="\e[0m"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.rebba.online

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

dnf install python3 gcc python3-devel -y &>>$LOGS_FILES
VALIDATE $? "Install python3 gcc"

id roboshop
if [ $? -ne 0 ]; then {
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILES
    VALIDATE $? "User Added"
}
else
 echo -e "$C User already exists.....! Skipping $N"
fi

mkdir /app
VALIDATE $? "Dir created"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGS_FILES
VALIDATE $? "Downloading the source code"

cd /app
VALIDATE $? "Change Dir to app"

rm -rf /app/* &>>$LOGS_FILES
VALIDATE $? "Removing existing files"

unzip /tmp/payment.zip &>>$LOGS_FILES
VALIDATE $? "Unipping the code"

cd /app
pip3 install -r requirements.txt &>>$LOGS_FILES
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOGS_FILES
VALIDATE $? "payment.service copied"

systemctl daemon-reload &>>$LOGS_FILES
VALIDATE $? "Reload the service"

systemctl enable payment &>>$LOGS_FILES
VALIDATE $? "Enable payment"

systemctl start payment &>>$LOGS_FILES
VALIDATE $? "Start payment"
