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

        curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip
        validate $? "Downloading shiipng project"


        cd /app
        unzip -o /tmp/frontend.zip -d /app &>>"$log_file"
        validate $? "Unzipping shiipng project"

    

        

        sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/frontend.service"
        validate $? "updating frontend service"

        cp "$script_dir/frontend.service" /etc/systemd/system/frontend.service
        validate $? "copying frontend service"

        
        
        systemctl daemon-reload &>>"$log_file"
            systemctl enable frontend &>>"$log_file"
            systemctl restart frontend &>>"$log_file"
            validate $? "frontend enable and start"
            
        echo "$(timestamp) [INFO] Script Completed in Seconds ${SECONDS}" | tee -a "$log_file"
        echo "$(timestamp) [INFO] Script is ended" | tee -a "$log_file"