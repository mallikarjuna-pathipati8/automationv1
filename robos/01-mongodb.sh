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

        echo "$(timestamp) [INFO] Script is started" | tee -a "$log_file"
        cp mongo.repo /etc/yum.repos.d/mongo.repo 
        validate $? "Adding Mongo Repo"

        dnf install mongodb-org -y &>> "$log_file"
        validate $? "Installing Mongodb"

        systemctl enable mongod &>> "$log_file"
        validate $? "enable mongodb"
        systemctl start mongod &>> "$log_file"
        validate $? "start mongodb"

        sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> "$log_file"
        validate $? "Replace  mongod.conf with 127.0.0.1 with 0.0.0.0"

        systemctl restart mongod &>> "$log_file"
        validate $? "Restarting Mongodb"

        echo "$(timestamp) [INFO] Script Completed in Seconds ${SECONDS}" | tee -a "$log_file"
        echo "$(timestamp) [INFO] Script is ended" | tee -a "$log_file"