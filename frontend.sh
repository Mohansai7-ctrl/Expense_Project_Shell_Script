# #!/bin/bash

# Here we need to create webserver service called nginx, which can also acts as load balancer upon our configuring the nginx and its default config files.
# we need to donwload the frontend or web server code in the /html file by deleting any content if existing.
# then need to config the expense.conf file which is additional config file in nginx directory, that expense.conf consiste the backend server private ip details to fetch, communicate and update with mysql database.
# finally after configuring the nginx configs, need to restart its service.

# Make sure while donwloading the content in html file, need to delete its existing everytime when runs this script.

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
        echo -e "$R You should have or use root access to run this script $N"
        exit 1
    else
        echo -e "$G Hurray!, You have root access, hence proceeding further $N"
    fi
}

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is $G SUCCESS $N"
    else
        echo -e "$2 is $R FAILED $N"
    fi
}

CHECK_ROOT

dnf list installed nginx
if [ $? -ne 0 ]
then   
    echo "As nginx service is not installed, not going to install it"
    dnf install nginx -y
    VALIDATE $? "nginx service"
else
    echo "nginx is already installed, hence proceeding further"
fi

systemctl enable nginx
VALIDATE $? "Enabling the nginx service"

systemctl start nginx
VALIDATE $? "Starting the nginx service"



cd /tmp/
if [ -f frontend.zip ]
then
    echo "Removing it as it is existing and will downloade the code again newly"
    curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
    echo "Downloading the zipped file in tmp directory is completed"
else
    curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
    echo "As frontend.zip file is not there, downloaded the code by creating it"
fi

cd /usr/share/nginx/html

rm -rf /html/*
unzip /tmp/frontend.zip
echo "Unzipping the code in /html directory is completed"

#need to config the nginx service now by creating expense.conf in default.d in nginx directory.

cp /home/ec2-user/Expense_Project_Shell_Script/expense.conf /etc/ngix/default.d/expense.conf
echo "Copying of expense.conf is completed to nginx directory"
VALIDATE $? "Copying the expense.conf"

systemctl restart nginx
VALIDATE $? "Restarting the nginx service"

