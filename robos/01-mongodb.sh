    #!/bin/bash

    #Get the user id
    user_id=$(id -u)

    #Log Folder and Log File
    log_folder="/var/log/mongodb"
    log_file="${log_folder}/${0}.log"
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


    validate()
    {
        if [ "$1" -ne 0 ]; then
        echo -e "${R}${2}..Failed${N}" | tee -a $log_file
        exit 1
        else 
        echo -e "${G}${2}..SUCCESS${N}" | tee -a $log_file
        fi
    }
    cp mongo.repo /etc/yum.repos.d/mongo.repo
    validate $? "Adding Mongo Repo"

    dnf install mongodb-org -y
    validate $? "Installing Mongodb"

    systemctl enable mongod
    systemctl start mongod
    validate $? "enable and start mongodb"

    