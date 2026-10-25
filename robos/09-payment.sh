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
            dnf install python3.14 python3.14-pip -y &>>"$log_file"
            validate $? "Installing python 3.14"

            
        
        id roboshop &>>"$log_file"
        if [ $? -ne 0 ]; then
            useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
            validate $? "Creating System User"
            else 
            echo "System user alredy created ${Y}Skipping${N}"
        fi

        rm -rf /app &>>"$log_file"
        validate $? "Deleting old /app files"

        mkdir -p /app &>>"$log_file"
        validate $? "Deleting old /app files"

        curl -L -o /tmp/payment.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/payment-v4.zip
        validate $? "Downloading shiipng project"


        cd /app
        unzip -o /tmp/payment.zip -d /app &>>"$log_file"
        validate $? "Unzipping shiipng project"

        cd /app
       python3.14 -m venv /app/.venv
       validate $? "Creating  virtual environment" 
       /app/.venv/bin/pip install -r requirements.txt
        validate $? "Installing dependencies" 

        

        sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/payment.service"
        validate $? "updating payment service"

        cp "$script_dir/payment.service" /etc/systemd/system/payment.service
        validate $? "copying payment service"

        
        
        systemctl daemon-reload &>>"$log_file"
            systemctl enable payment &>>"$log_file"
            systemctl restart payment &>>"$log_file"
            validate $? "payment enable and start"
            
        echo "$(timestamp) [INFO] Script Completed in Seconds ${SECONDS}" | tee -a "$log_file"
        echo "$(timestamp) [INFO] Script is ended" | tee -a "$log_file"