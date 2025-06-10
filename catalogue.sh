#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

script_dir=$PWD

log_folder="var/log/meghana/"
script_name=$(echo $0| cut -d "." -f1 )
log_file="$log_folder/$script_name.log"

mkdir -p $log_folder

echo "script started executing at: $(date +%s)" | tee -a $log_file

# check root access of the user
user_id=$(id -u)
if [ $user_id -eq 0 ]
then 
echo -e " $G you are running with root access $N" | tee -a $log_file
else 
echo -e " $R ERROR: you are not running with root access $N" | tee -a $log_file
exit 1
fi

validate (){
    if [ $1 -eq 0 ]
then
echo -e " $G $2 is already installed $N " | tee -a $log_file
else
echo -e " $Y $2 installaition is going to install $N" | tee -a $log_file
exit 1
fi
}

dnf module disable nodejs -y &>>$log_file
validate $? " disabling nodejs "

dnf module enable nodejs:20 -y &>>$log_file
validate $? " enabling nodejs:20 "

dnf install nodejs -y &>>$log_file
validate $? " installing nodejs:20 "

id roboshop
if [ $? -ne 0 ]
 then
       useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
       validate $? " creating roboshop system user " &>>$log_file
else
      echo -e " $Y roboshop system user already created $N" &>>$log_file
fi

mkdir /app 
validate $? " creating app folder "

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$log_file
validate $? " downloading catalogue "

rm -rf /app/*
cd /app 
unzip /tmp/catalogue.zip &>>$log_file
validate $? " unzipping catalogue "

npm install &>>$log_file
validate $? " installing dependencies "

cp $script_dir/catalogue.setvice /etc/systemd/system/catalogue.service
validate $? " copying catalogue service "

systemctl daemon-reload &>>$log_file
systemctl enable catalogue &>>$log_file
systemctl start catalogue 
validate $? " starting catalogue "

cp $script_dir/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$log_file
validate $? " installing mongodb client "

status=$(mongosh --host mongodb.knswamy.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $status -lt 0]
  then
       mongosh --host mongodb.knswamy.site </app/db/master-data.js &>>$log_file
       validate $? " loading catalogue data into mongodb "
    else
       echo -e " $Y catalogue data is alredy loaded $N"
fi   
