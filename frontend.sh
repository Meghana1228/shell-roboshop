#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

logs_folder="var/log/meghana/"
script_name=$(echo $0| cut -d "." -f1 )
log_file="$log_folder/$script_name.log"

mkdir -p $log_folder

echo "script started executing at: $(date +%s)"

# check root access of the user
userid=$(id -u)
if [ $user_id -eq 0 ]
then 
echo -e " $G you are running with root access $N" 
else 
echo -e " $R you are not running with root access $N"
exit 1
fi

validate (){
    if [ $1 -eq 0 ]
then
echo -e " $G $2 is already installed $N " | tee -a $logfile
else
echo -e " $Y $2 installaition is going to install $N" | tee -a $logfile
exit 1
fi
}

dnf module disable nginx -y
dnf module enable nginx:1.24 -y
dnf install nginx -y
systemctl enable nginx 
systemctl start nginx 
rm -rf /usr/share/nginx/html/* 
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
vim /etc/nginx/nginx.conf
