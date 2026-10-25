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
        validate $? "Enabling Maven module"
        dnf install maven java-25-openjdk-devel -y &>>"$log_file"
       validate $? "Installing Maven and Java"

        alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
        validate $? "Set Java Version 25"

        echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
        source /etc/profile.d/java.sh
        echo $JAVA_HOME
        validate $? "Set Maven Version 25"

        java_version=$(java -version)        
        echo "${java_version}"
         mvn_version=$(mvn -v)
         echo "${mvn_version}"
       
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

       curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip
       validate $? "Downloading shiipng project"


      cd /app
      unzip -o /tmp/shipping.zip -d /app &>>"$log_file"
      validate $? "Unzipping shiipng project"

      cd /app
      mvn clean package 
      validate $? "Installing dependencies" 

      mv target/shipping.jar shipping.jar
      validate $? "Moving  shipping.jar"

      sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/shipping.service"
      validate $? "updating shipping service"

      cp "$script_dir/shipping.service" /etc/systemd/system/shipping.service
      validate $? "copying shipping service"

      dnf install mysql -y  &>>"$log_file"
      validate $? "Installing MySQL client"

 
      echo "$(timestamp) [INFO] Script Completed in Seconds ${SECONDS}" | tee -a "$log_file"
      echo "$(timestamp) [INFO] Script is ended" | tee -a "$log_file"