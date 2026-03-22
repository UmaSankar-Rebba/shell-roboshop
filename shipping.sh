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

dnf install maven -y &>>$LOGS_FILES
VALIDATE $? "Installing maven"

id roboshop
if [ $? -ne 0 ]; then {
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILES
    VALIDATE $? "User Added"
}
else
 echo -e "$C User already exists.....! Skipping $N"
fi

mkdir -p /app
VALIDATE $? "Dir created"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGS_FILES
VALIDATE $? "Downloading the source code"

cd /app
VALIDATE $? "Change Dir to app"

rm -rf /app/* &>>$LOGS_FILES
VALIDATE $? "Removing existing files"

unzip /tmp/shipping.zip &>>$LOGS_FILES
VALIDATE $? "Unzipping the downloaded source code"

cd /app &>>$LOGS_FILES
mvn clean package &>>$LOGS_FILES
VALIDATE $? "installing and building shipping"

mv target/shipping-1.0.jar shipping.jar &>>$LOGS_FILES
VALIDATE $? "moving and renaming shipping"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOGS_FILES
VALIDATE $? "Copied the service code"

dnf install mysql -y &>>$LOGS_FILES
VALIDATE $? "installing mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then

    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOGS_FILE
    VALIDATE $? "Loaded data into MySQL"
else
    echo -e "data is already loaded ... $Y SKIPPING $N"
fi

systemctl enable shipping &>>$LOGS_FILE
systemctl start shipping
VALIDATE $? "Enabled and started shipping"