#!/bin/bash

# Checking first user is having root access or not to run this script, if not will highlight to user to use/login as root access
# #Creating mysql-server and enabling it.
# Creating/Setting password to the created mysql-server database.

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
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"


CHECK_ROOT(){
    if [ $userid -ne 0 ]
    then
        echo -e "$R You don't have root access to run this script, Please run this script by providing root or super user access $N" &>>$LOG_FILE
        exit 1
    else
        echo -e "$G Hurray!, you are having root access to run this script, Hence Proceeding further $N" &>>$LOG_FILE
        
    fi

}

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is $G SUCCESS... $N"
    else
        echo -e "$2 is $R FAILED... $N"
    fi
}



echo "Your Script Executing time is $date" | tee -a $LOG_FILE

CHECK_ROOT

dnf list installed mysql-server &>>$LOG_FILE
if [ $? - ne 0 ]
then
    echo -e "$Y As mysql-server is not installed, now going to install it $N" | tee -a $LOG_FILE
    dnf install mysql-server -y
    VALIDATE $? "Your mysql-server installation is:"
else
    echo -e "$G Your mysql-server is already installed, proceeding further $N" | tee -a $LOG_FILE
fi

# Going to enable, and start the mysqld service
systemctl status mysqld
if [ $? -ne 0 ]
then
    systemctl enable mysqld
    VALIDATE $? "Enabling the mysqld"
    systemctl start mysqld
    VALIDATE $? "Starting the mysqld"
else
    echo -e "$G mysqld is already active and running, hence no need to enable or restart it $N" | tee -a $LOG_FILE
fi

#Again checking the running status of mysqld service
systemctl status mysqld
if [ $? -eq 0 ]
then
    echo -e "$G Hurray! mysqld service is active and running, hence proceeding further to setup the password for database $N" | tee -a $LOG_FILE
else
    echo "Still mysqld is not running, need to check it" | tee -a $LOG_FILE
    exit 1
fi 

#Checking and setting the password of root user for the mysql db

mysql -h mysql.mohansai.online -u root -pExpenseApp@1 -e 'show databases;'
if [ $? -ne 0 ]
then
    echo -e "$R Password for db is not set, hence creating/setting it now $N" | tee -a $LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting the password is"
else
    echo -e "Password is already created, hence $G SKIPPING $N" | tee -a $LOG_FILE

fi

