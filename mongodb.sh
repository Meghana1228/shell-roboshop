#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo 
validate $? " copying mongodb repo "

dnf install mongodb-org -y &>>$log_file
validate $? " installing mongodb "

systemctl enable mongod &>>$log_file
validate $? " enabling mongodb "

systemctl start mongod &>>$log_file
validate $? " starting mongodb "

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? " editing mongodb conf file for remote connections "

systemctl restart mongod &>>$log_file
validate $? " restarting mongodb "
