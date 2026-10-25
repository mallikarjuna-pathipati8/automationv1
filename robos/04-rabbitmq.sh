#!/bin/bash

        #Get the user id
        user_id=$(id -u)

        #Log Folder and Log File
        log_folder="/var/log/roboshop"
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
        cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
        validate $? "Copy and Pasted rabbitmq.repo"

        dnf install erlang rabbitmq-server -y &>> "$log_file"
        validate $? "rabbitmq Install" 


        systemctl enable rabbitmq-server &>> "$log_file"
        validate $? "rabbitmq Enable" 
        systemctl start rabbitmq-server &>> "$log_file"
        validate $? "rabbitmq Start" 

        # Verify roboshop user exist 
        rabbitmqctl list_users | grep -qw "roboshop"
        
        if [ "$?" -ne 0 ]; then       
        rabbitmqctl add_user roboshop roboshop123 &>> "$log_file"
        validate $? "rabbitmq add user" 
        else 
        echo -e "$(timestamp) [INFO] User is alredy exist ${Y}Skipping${N}"
        fi

        rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> "$log_file"
        validate $? "rabbitmq Set Permission" 

        echo "$(timestamp) [INFO] Script Completed in Seconds ${SECONDS}" | tee -a "$log_file"
        echo  "$(timestamp) [INFO] Script is ended" | tee -a "$log_file"



        