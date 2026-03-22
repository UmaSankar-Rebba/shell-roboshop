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

dnf module list nginx &>>$LOGS_FILES
VALIDATE $? "Lists the nginx"

dnf module disable nginx -y &>>$LOGS_FILES
VALIDATE $? "disable the default version of nginx"

dnf module enable nginx:1.24 -y &>>$LOGS_FILES
VALIDATE $? "enable the 1.24 version of nginx"

dnf install nginx -y &>>$LOGS_FILES
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGS_FILES
VALIDATE $? "enable nginx"

systemctl start nginx &>>$LOGS_FILES
VALIDATE $? "start nginx"

systemctl restart nginx &>>$LOGS_FILES
VALIDATE $? "restart nginx"
