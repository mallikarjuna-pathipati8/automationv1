#!/bin/bash

        #Get the user id
        user_id=$(id -u)
        #Log Folder and Log File
        log_folder="/var/log/roboshop"
        log_file="${log_folder}/$(basename "$0").log"
        domain_name="arjundaws92s.store"
        script_dir=$(dirname "$(realpath "$0")")
        
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
        dnf module enable maven:3.9 -y &>>"$log_file"
        dnf install maven java-25-openjdk-devel -y &>>"$log_file"
        validate $? "Enable and Installing Java"


 
      echo "$(timestamp) [INFO] Script Completed in Seconds ${SECONDS}" | tee -a "$log_file"
      echo "$(timestamp) [INFO] Script is ended" | tee -a "$log_file"