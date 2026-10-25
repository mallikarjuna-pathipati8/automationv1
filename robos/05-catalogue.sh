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
        validate $? "Catalogue enable and install 24 version"

        id roboshop &>> "$log_file"

        if [ "$?" -ne 0 ]; then            
            useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
            validate $? "Creating Roboshop User"
            else 
            echo -e "Roboshop alrready create, ${Y}Skipping${N}"
        fi
        
        rm -rf /app &>> "$log_file"
        validate $? "Removing /app old directory"
        
        mkdir -p /app &>> "$log_file"
        validate $? "Creating /app directory"

        curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip &>> "$log_file"
        validate $? "Downloading Catalogue"

        cd /app
        unzip /tmp/catalogue.zip "$log_file"
        validate $? "Unzipping Catalogue"

        cd /app
        npm install "$log_file"
        validate $? "Installating dependencies"

        echo "${script_dir}"
        echo "$script_dir/catalogue.service"
        sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/catalogue.service"
        cp "$script_dir/catalogue.service" /etc/systemd/system/catalogue.service


        systemctl daemon-reload &>> "$log_file"
        systemctl enable catalogue &>> "$log_file"
        systemctl start catalogue &>> "$log_file"
        validate $? "Enable and Start Catalogue"
        
        cp "$script_dir/mongo.repo" /etc/yum.repos.d/mongo.repo

        dnf install mongodb-mongosh -y
        validate $? "Installing MongoDB Client"

        product_count=$(mongosh --host mongodb.$domain_name --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()' 2>> "$log_file")
        validate $? "Connecting Mongodb"

        if [ "$product_count" -eq 0 ]; then
           mongosh --host mongodb.$domain_name </app/db/master-data.js
           validate $? "Loading Products" 
           else 
           echo -e "Products alrready Loaded, ${Y}Skipping${N}"
        fi

        systemctl restart catalogue
        validate %? "Restarting catalogue"
        
        echo "$(timestamp) [INFO] Script Completed in Seconds ${SECONDS}" | tee -a "$log_file"
        echo "$(timestamp) [INFO] Script is ended" | tee -a "$log_file"