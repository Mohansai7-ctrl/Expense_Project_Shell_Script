#!/bin/bash
#Here, we will peform below sequence of steps to configure the backend server
# will disable the default nodejs
# install required nodejs of version 20 as it is required here as developer code written in nodejs
# after installing the node js, will create an daemon user to run the backend service so that it will communicate with db for the requests from front end server
# will create a separate folder or directory to plac the code and build file
# Download the code and unzipping in created app folder


# To run the app service, will create a backend service
# will load the app transactions schema to mysql db, for that need client service so will install mysql service

# finally reload, enable and restart the daemon backend service.

userid=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense"
mkdir -p $LOGS_FOLDER
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
$LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

CHECK_ROOT(){
    if [ $userid -ne 0 ]
    then
        echo -e "$R You are not having root access, to proceed further pls run this script with root access $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$G Hurray!, As you running this script with root access, proceeding further $N" | tee -a $LOG_FILE
    fi
}

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is $G SUCCESS $N" | tee -a $LOG_FILE
    else 
        echo -e "$2 is $G FAILED $N" | tee -a $LOG_FILE
    fi
}

CHECK_ROOT

echo -e "$Y Script Exectuing time is $(date) $N" | tee -a $LOG_FILE

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling the default nodejs is"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling the nodejs of version 20"

dnf install nodejs -y
VALIDATE $? "Installing the nodejs of version 20"



echo "Installing the build tool - npm" | tee -a $LOG_FILE
npm install &>>$LOG_FILE

id expense
if [ $? -ne 0 ]
then
    echo -e "$Y As user expense is not exisiting, going to create it $N" | tee -a $LOG_FILE
    useradd expense
    VALIDATE $? "Creating the user expense is"

else
    echo "User expense is already created" | tee -a $LOG_FILE
fi


mkdir -p /app &>>$LOG_FILE

# cd /tmp/

# if [ -f backend.zip ]
# then
# rm -rf backend.zip
# else
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip | tee -a $LOG_FILE
# fi


cd /app

rm -rf /app/*
unzip /tmp/backend.zip | tee -a $LOG_FILE

cp /home/ec2-user/Expense_Project_Shell_Script /etc/systemd/system/backend.service | tee -a $LOG_FILE

#now installing the mysql client to communicate with the mysql database
dnf install mysql &>>$LOG_FILE

#loading the schema:
mysql -h mysql.mohansai.online -u root -pExpenseApp@1 < /app/schema/backend.sql | tee -a $LOG_FILE

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading the daemon service is"

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Enabling the bakcend service is"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "Restarting the backend service is"













