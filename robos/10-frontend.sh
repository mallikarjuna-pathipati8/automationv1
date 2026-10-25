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
         dnf module disable nginx -y &>>"$log_file"
         dnf module enable nginx:1.26 -y &>>"$log_file"
         dnf install nginx -y &>>"$log_file"
         validate $? "Installing  nginx"
            
        systemctl enable nginx &>>"$log_file"
        validate $? "Enable nginx"
        systemctl start nginx &>>"$log_file"
        validate $? "Start  nginx"

         rm -rf /usr/share/nginx/html/* &>>"$log_file"
        validate $? "Removing default content"


       
        curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip
        cd /usr/share/nginx/html
        unzip -o /tmp/frontend.zip -d /app &>>"$log_file"
        validate $? "Downloading and unzipping frontend code"

    
        sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/roboshop.conf"
        validate $? "updating frontend service"

        cp "$script_dir/roboshop.conf" /etc/systemd/system/roboshop.conf
        validate $? "Copied roboshop config"

        nginx -t  &>>"$log_file"
        validate $? "Nginx Configuration"

        systemctl restart nginx
        validate $? "Restarting nginx"
        
       
            
        echo "$(timestamp) [INFO] Script Completed in Seconds ${SECONDS}" | tee -a "$log_file"
        echo "$(timestamp) [INFO] Script is ended" | tee -a "$log_file"