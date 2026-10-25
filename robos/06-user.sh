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

        dnf module disable nodejs -y  &>> "$log_file"
        dnf module enable nodejs:24 -y &>> "$log_file"
        dnf install nodejs -y &>> "$log_file"
        validate $? "User Enable and Install"

        id roboshop
        if [ $? -ne 0 ]; then
            useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
            validate $? "Creating System User"
        else 
            echo -e "System User Alredy Created. ${Y}Skipping${N}"
        fi 

        rm -rf /app &>> "$log_file"
        validate $? "Removing /app old directory files"

        mkdir -p /app &>> "$log_file"
        validate $? "Creating /app directory"

        curl -L -o /tmp/user.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/user-v4.zip &>> "$log_file"
        validate $? "Downloading Catalogue Code"

        cd /app
        unzip -o /tmp/user.zip -d /app &>> "$log_file"
        validate $? "Unzipping Catalogue" 

        cd /app
        npm install &>> "$log_file"
        validate $? "Installing User dependencies"

        sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/user.service"
        validate $? "Updating User service configuration"

        cp "$script_dir/user.service" /etc/systemd/system/user.service
        validate $? "Copying User service file"
      
        systemctl daemon-reload &>> "$log_file"
        systemctl enable user &>> "$log_file"
        systemctl start user &>> "$log_file"
        validate $? "User enable and start"

        systemctl restart user
        validate $? "Restart user"

      echo "$(timestamp) [INFO] Script Completed in Seconds ${SECONDS}" | tee -a "$log_file"
      echo "$(timestamp) [INFO] Script is ended" | tee -a "$log_file"

