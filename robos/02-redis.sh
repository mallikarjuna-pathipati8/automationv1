#!/bin/bash

    #Get the user id
    user_id=$(id -u)

    #Log Folder and Log File
    log_folder="/var/log/mongodb"
    log_file="${log_folder}/$(basename "$0").log"
    #Display Colors
    R="\e[31m"
    G="\e[32m"
    Y="\e[33m"
    N="\e[0m"
    #Verify User is root 
    if [ "$user_id" -ne 0 ]; then
    echo "Please run with sudo user"
    exit 1
    else 
        echo "${user_id} is Sudo User"
    fi

    #Create file 
    mkdir -p "${log_folder}"

    timestamp()
    {
      date "+%F %T"
    }
    validate()
    {
        if [ "$1" -ne 0 ]; then
        echo -e "$(timestamp) ${R}[ERROR] ${2}..Failed${N}" | tee -a "$log_file"
        exit 1
        else 
        echo -e "$(timestamp) ${G}[INFO] ${2}..SUCCESS${N}" | tee -a "$log_file"
        fi
    }
    echo "$(timestamp) Script Started"  | tee -a "$log_file"

    dnf module disable redis -y &>> "$log_file"
    dnf module enable redis:7 -y &>> "$log_file"
    dnf install redis -y &>> "$log_file"
    validate $? "Redis Installation"

    sed -i -e 's/^bind 127.0.0.0/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>> "$log_file"
    validate $? "Update Redis Config File and Protected Mode Change"

    systemctl enable redis &>> "$log_file"
    validate $? "Redis enable"

    systemctl start redis &>> "$log_file"
    validate $? "Redis Start"

    echo "$(timestamp) [INFO] Script Completed in Seconds ${SECONDS}" | tee -a "$log_file"
        echo "$(timestamp) [INFO] Script is ended" | tee -a "$log_file"