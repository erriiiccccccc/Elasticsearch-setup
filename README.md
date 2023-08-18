# **ELASTIC-LOGSTASH-KIBANA (ELK) Setup Guide**

***"ELK" refers to three open-source projects that work together to provide a powerful log management and analytics solution:***

1. Elasticsearch: A search and analytics engine.
2. Logstash: A server-side data processing pipeline that ingests data from various sources, transforms it, and sends it to Elasticsearch.
3. Kibana: A data visualization tool that allows users to explore, analyze, and visualize data stored in Elasticsearch.


## **Prerequisites**

This setup guide is tailored for a Linux environment (Oracle Linux 8).
Ensure you have root privileges on your system.

## **Elasticsearch Setup** 
1. Create a folder named ELK in the /opt/ directory.
2. Change the current directory to ELK and run the following commands:
    ```
    su
    cd /opt/ELK/
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.8.2-linux-x86_64.tar.gz
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.8.2-linux-x86_64.tar.gz.sha512
    shasum -a 512 -c elasticsearch-8.8.2-linux-x86_64.tar.gz.sha512 
    tar -xzf elasticsearch-8.8.2-linux-x86_64.tar.gz
    mv ./elasticsearch-8.8.2/ ./elasticsearch/
    cd ./elasticsearch/ 
    ```
3. Change ownership and permissions of the Elasticsearch files
    ```
    sudo chown -R finexus:finexus /opt/ELK/elasticsearch
    sudo chmod o+x /opt/ELK/elasticsearch
    sudo chgrp finexus /opt/ELK/elasticsearch
    ```
4. Open the elasticsearch.yml configuration file and add "xpack.security.enabled: false" to the bottom of the file:
    ```
    /opt/ELK/elasticsearch/config/elasticsearch.yml
    xpack.security.enabled: false
    ```
5. Switch user back to 'finexus' user and start Elasticsearch
    ```
    su - finexus
    cd /opt/ELK/elasticsearch
    ./bin/elasticsearch
    ```
6. Verify the Elasticsearch setup by opening a web browser and accessing http://localhost:9200 or writing the following command into the terminal. This should display information about the Elasticsearch cluster.
    ```
    http://localhost:9200
    curl --cacert $ES_HOME/config/certs/http_ca.crt -u elastic http://localhost:9200 
    ```
7. Keep the terminal running with Elasticsearch running.

## **Kibana Setup**
1. Change the current directory to ELK and run the following commands:
    ```
    su
    cd /opt/ELK/
    curl -O https://artifacts.elastic.co/downloads/kibana/kibana-8.8.2-linux-x86_64.tar.gz
    curl https://artifacts.elastic.co/downloads/kibana/kibana-8.8.2-linux-x86_64.tar.gz.sha512 | shasum -a 512 -c - 
    tar -xzf kibana-8.8.2-linux-x86_64.tar.gz
    cd kibana-8.8.2/ 
    mv ./kibana-8.8.2/ ./kibana/
    cd ./kibana/ 
    ```
2. Change ownership and permissions of the Kibana files
    ```
    sudo chown -R finexus:finexus /opt/ELK/kibana
    sudo chmod o+x /opt/ELK/kibana
    sudo chgrp finexus /opt/ELK/kibana
    ```
3. Open and edit kibana.yml by changing "server.host: "localhost" " to "server.host: "0.0.0.0" " 
    ```
    /opt/ELK/kibana/config/kibana.yml
    server.host: "0.0.0.0" 
    ```
4. Switch user back to 'finexus' user and run Kibana
    ```
    su - finexus
    cd /opt/ELK/kibana
    ./bin/kibana
    ```
5. Verify the Kibana setup by opening a web browser and accessing http://localhost:5601 or http://192.168.xx.xx:5601 on your host system. 
    ```
    http://localhost:5601
    ```
6. Keep the terminal running with Kibana running.


## **Logstash Setup**
1. Import the Elastic public signing key
    ```
    sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
    ```
2. Create a logstash repository file
    ```
    sudo nano /etc/yum.repos.d/logstash.repo
    ```
3. Add the following into logstash.repo 
    ```
    [logstash-8.x]
    name=Elastic repository for 8.x packages
    baseurl=https://artifacts.elastic.co/packages/8.x/yum
    gpgcheck=1
    gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
    enabled=1
    autorefresh=1
    type=rpm-md
    ```
4. Install logstash
    ```
    sudo yum install logstash
    ```
5. Move the logstash files to the ELK folder
    ```
    sudo mv /usr/share/logstash /opt/ELK/logstash
    ```
6. Change ownership and permissions of the Logstash files
    ```
    sudo chown -R finexus:finexus /opt/ELK/logstash
    sudo chmod o+x /opt/ELK/logstash
    sudo chgrp finexus /opt/ELK/logstash
    ```
7. Create a logstash.conf file and place it in "/opt/ELK/logstash/logstash.conf". Make sure to include the required input, filter, and output configurations. *(Note: everytime a different file is to be ingested by logstash, the logstash.conf file must be changed according to the fields of the file)* Here's an example of logstash.conf:
    ```
    input {
    file {
        path => "/kibanaproject/countriesdata.csv"
        start_position => "beginning"
        sincedb_path => "dev/nul"
    }
    }
    filter {
    csv {
        separator => ","
        columns => ["Country","Region","Population","Area"]
    }
    mutate {convert => ["Population", "integer"]}
    mutate {convert => ["Area", "integer"]}
    }
    output {
    elasticsearch {
        hosts => ["localhost:9200"]
        index => "countriesdata"
    }
    stdout {codec => json_lines }
    }
    ```
8. Switch user back to 'finexus' user and run Logstash
    ```
    su - finexus
    cd /opt/ELK/logstash/
    sudo bin/logstash -f /opt/ELK/logstash/logstash.conf
    (Make sure to replace /opt/ELK/logstash/logstash.conf with the path to your Logstash configuration file)
    ```
9. Keep the terminal running with Logstash running


## **Elasticsearch security setup**
Default username: elastic ;
Default password: changeme 
  
1. Run this command to change the password
    ```
    ./elasticsearch-setup-passwords interactive
    ```
2. To setup xpack.security.enabled: true :
   1.	Comment everything in elasticsearch.yml and kibana.yml by adding "#" at the beginning of the lines and save
        ```
        nano /opt/ELK/elasticsearch/config/elasticsearch.yml
        nano /opt/ELK/kibana/config/kibana.yml
        ```
   2.	Start Elasticsearch
   3.	Open another terminal from the directory /opt/ELK/elasticsearch/bin and run the command below
        ```
        ./elasticsearch-reset-password -u kibana_system --auto
        
        Note: We are resetting password for user "kibana_system" not "elastic".
        .\elasticsearch-reset-password.bat -u kibana_system --auto
        This command will give you password for user "kibana_system". Copy and store the password somewhere.
        ```
   4.	Edit kibana.yml file in /opt/ELK/kibana/config/ directory by setting below values.
        ```
        elasticsearch.username: "kibana_system"
        elasticsearch.password: "the kibana_system password generated above, not the elastic password"
        Then save the .yml file.
        ```
3.	Start kibana
4.	If there is no errors, open http://localhost:5601/app/home#/ in the browser. Enter username as "elastic" Enter the password as "the elastic password, not kibana password"

## **Systemctl services setup to start EKL on startup**
1. Create file 'elasticsearch.service' in '/etc/systemd/system'
    ```
    vim /etc/systemd/system/elasticsearch.service
    ```
2. Write this in 'elasticsearch.service'
    ```
    [Unit]
    Description=Elasticsearch Service
    After=network.target

    [Service]
    Type=simple
    User=finexus
    Group=finexus
    WorkingDirectory=/opt/ELK/elasticsearch
    ExecStart=/opt/ELK/elasticsearch/bin/elasticsearch

    [Install]
    WantedBy=multi-user.target
    ```
3. Create file 'kibana.service' in '/etc/systemd/system'
    ```
    vim /etc/systemd/system/kibana.service
    ```
4. Write this in 'kibana.service'
    ```
    [Unit]
    Description=Kibana Service
    After=elasticsearch.service

    [Service]
    Type=simple
    User=finexus
    Group=finexus
    WorkingDirectory=/opt/ELK/kibana
    ExecStart=/opt/ELK/kibana/bin/kibana

    [Install]
    WantedBy=multi-user.target
    ```
5. Create file 'logstash.service' in '/etc/systemd/system'
    ```
    vim /etc/systemd/system/logstash.service
    ```
6. Write this in 'logstash.service'
    ```
    [Unit]
    Description=Logstash Service
    After=kibana.service

    [Service]
    Type=simple
    User=finexus
    Group=finexus
    WorkingDirectory=/opt/ELK/logstash
    ExecStart=/opt/ELK/logstash/bin/logstash -f /opt/ELK/logstash/aiv_access.conf

    [Install]
    WantedBy=multi-user.target
    ```
7. Create file 'logstash2.service' in '/etc/systemd/system'
    ```
    vim /etc/systemd/system/logstash2.service
    ```
8. Write this in 'logstash2.service'
    ```
    [Unit]
    Description=Logstash2 Service
    After=logstash.service

    [Service]
    Type=simple
    User=finexus
    Group=finexus
    WorkingDirectory=/opt/ELK/logstash2
    ExecStart=/opt/ELK/logstash/bin/logstash -f /opt/ELK/logstash2/aiv_error.conf

    [Install]
    WantedBy=multi-user.target
    ```
9. Create file 'logstash3.service' in '/etc/systemd/system'
    ```
    vim /etc/systemd/system/logstash3.service
    ```
10. Write this in 'logstash3.service'
    ```
    [Unit]
    Description=Logstash3 Service
    After=logstash2.service

    [Service]
    Type=simple
    User=finexus
    Group=finexus
    WorkingDirectory=/opt/ELK/logstash3
    ExecStart=/opt/ELK/logstash/bin/logstash -f /opt/ELK/logstash3/Stomp.conf

    [Install]
    WantedBy=multi-user.target
    ```


## **Embedding Kibana graphs into a JSP page**
1. Create a new dynamic web project in Eclipse and set up the project with the necessary configurations.
2. Write the JSP code, for example:
    ```
    <%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
    <!DOCTYPE html>
    <html>
    <head>
    <title>ELK Graphs</title>
    <style>
        .graph-container {
        width: 33%;
        height: 0;
        padding-bottom: 33.33%;
        position: relative;
        display: inline-block;
        box-sizing: border-box;
        }

        .graph-container iframe {
        position: absolute;
        width: 100%;
        height: 550px;
        }

        body {
        margin: 0;
        padding: 0;
        }
    </style>
    </head>
    <body>
    <h1>ELK</h1>
    <div class="graph-container">
            <h2>aiv_access.log</h2>
            <iframe src="http://192.168.83.99:5601/app/dashboards#/view/823ccad0-2234-11ee-a888-8b6adef987a7?embed=true&_g=(refreshInterval:(pause:!t,value:60000),time:(from:now-15m,to:now))&_a=()&hide-filter-bar=true" height="500" width="800" frameborder="0"></iframe></iframe>
    </div>
    <div class="graph-container">
            <h2>aiv_error.log</h2>
            <iframe src="http://192.168.83.99:5601/app/dashboards#/view/6241d770-2234-11ee-a888-8b6adef987a7?embed=true&_g=(refreshInterval:(pause:!t,value:60000),time:(from:now-1y%2Fd,to:now))&_a=()&show-query-input=true&show-time-filter=true" height="500" width="800" frameborder="0"></iframe>
    </div>
    <div class="graph-container">
            <h2>Stomp.log</h2>
            <iframe src="http://192.168.83.99:5601/app/dashboards#/view/4c11e8f0-2234-11ee-a888-8b6adef987a7?embed=true&_g=(refreshInterval:(pause:!t,value:60000),time:(from:now-1y%2Fd,to:now))&_a=()&show-query-input=true&show-time-filter=true" height="500" width="800" frameborder="0"></iframe>
    </div>
    </body>
    </html>
    ```
3. You can get the iframe link of your graph from your Kibana dashboard and paste it in your JSP code
    ```
    Kibana -> Dashboard -> Share -> Embed Code -> Tick 'Time filter' -> Copy iFrame code
    ```
4. Adjust the dimensions of the iframe graphs appropriately  
5. Export your JSP as a .war file and deploy it into Apache Tomcat or any other servlet container
6. Start Apache server and go to:
    ```
    http://localhost:8080/ELK/UI/index.jsp (according to your server URL)
    ```
7. Set up your security preference:
    - If you do not want any security:
        - Configure elasticsearch.yml and kibana.yml
        ```
        /opt/ELK/elasticsearch/config/elasticsearch.yml/
        xpack.security.enabled: false
        ```
        ```
        /opt/ELK/elasticsearch/config/kibana.yml/
        # elasticsearch.username: xxxxxxxx
        # elasticsearch.password: xxxxxxxx
        comment these
        ```
    - If you want to have username and password authentication:
        - Do not change anything in elasticsearch.yml and kibana.yml
        - Write this in your machine's terminal to generate necessary certificates
        ```
        # Generate the PKCS #12 keystore for a CA, valid for 50 years
        bin/elasticsearch-certutil ca --out ca.p12 -days 18250 --pass castorepass

        # Generate the PKCS #12 keystore for Elasticsearch and sign it with the CA
        bin/elasticsearch-certutil cert --out elasticsearch.p12 -days 18250 --ca ca.p12 --ca-pass castorepass --name elasticsearch --dns localhost --pass storepass

        # Generate the PKCS #12 keystore for Kibana and sign it with the CA
        bin/elasticsearch-certutil cert --out kibana.p12 -days 18250 --ca ca.p12 --ca-pass castorepass --name kibana --dns localhost --pass storepass

        # Copy the PKCS #12 keystore for Elasticsearch with an empty password
        openssl pkcs12 -in elasticsearch.p12 -nodes -passin pass:"storepass" -passout pass:"" | openssl pkcs12 -export -out elasticsearch_emptypassword.p12 -passout pass:""

        # Manually create "elasticsearch_nopassword.p12" -- this can be done on macOS by importing the P12 key store into the Keychain and exporting it again

        # Extract the PEM-formatted X.509 certificate for the CA
        openssl pkcs12 -in elasticsearch.p12 -out ca.crt -cacerts -passin pass:"storepass" -passout pass:"storepass"

        # Extract the PEM-formatted PKCS #1 private key for Elasticsearch
        openssl pkcs12 -in elasticsearch.p12 -nocerts -passin pass:"storepass" -passout pass:"keypass" | openssl rsa -passin pass:keypass -out elasticsearch.key

        # Extract the PEM-formatted X.509 certificate for Elasticsearch
        openssl pkcs12 -in elasticsearch.p12 -out elasticsearch.crt -clcerts -passin pass:"storepass" -passout pass:"storepass"

        # Extract the PEM-formatted PKCS #1 private key for Kibana
        openssl pkcs12 -in kibana.p12 -nocerts -passin pass:"storepass" -passout pass:"keypass" | openssl rsa -passin pass:keypass -out kibana.key

        # Extract the PEM-formatted X.509 certificate for Kibana
        openssl pkcs12 -in kibana.p12 -out kibana.crt -clcerts -passin pass:"storepass" -passout pass:"storepass"
        ```
        - 4. Open the kibana.yml configuration file and add the following to the bottom of the file:
        ```
        server.ssl.enabled: true
        server.ssl.key: '/opt/ELK/elasticsearch/kibana.key' ## to the path of your kibana.key
        server.ssl.certificate: '/opt/ELK/elasticsearch/kibana.crt' ## to the path of your kibana.crt
        server.ssl.certificateAuthorities: '/opt/ELK/elasticsearch/ca.crt' ## to the path of your ca.crt
        xpack.security.secureCookies: true 
        xpack.security.sameSiteCookies: None 
        ```
        - Reboot your system and go to the kibana website using HTTPS
        - You will need to obtain a new iframe link and re-deploy your graphs to your JSP code
8. Reboot your system and try out your new webpage:
    ```
    sudo reboot
    ```


## Setting up Anonymous User to Embed Kibana Dashboard to Your 

### This is used to set permissions so that anonymous users/clients can only access content that are intended
1. Create encryption keys for your Kibana:
    ```
    /opt/ELK/kibana/bin/kibana-encryption-keys generate
    ```
2. Edit kibana.yml using the keys given in step 1 
    ```
    /opt/ELK/kibana/config/kibana.yml

    xpack.encryptedSavedObjects.encryptionKey: key
    xpack.reporting.encryptionKey: key
    xpack.security.encryptionKey: key
    xpack.reporting.capture.browser.chromium.disableSandbox: true
    ```
3. Start/restart kibana
4. Login using 'elastic'
5. Go to 'Stack management' -> 'Roles' and create a new role, create a new role named 'embed_dashboard' and give it the necessary permissions:
    ```
    In my case i put:

    Elasticsearch
    Cluster privileges: monitor
    Index privileges:
    Indices: {all my logs}          Privileges: monitor && read

    Kibana
    Add Kibana privilege 
    Spaces: Default
    Dashboard: Read
    Visualize Library: Read
    ```
6. Go to 'Stack management' -> 'Users' and create a new user:
    ```
    Username: Anon
    Password: readonly
    Privileges: embed_dashboard       (This is the role you created previously)
    ```
7. Then, go back to kibana.yml configuration file and add the following to the bottom of the file:  
    ```
    xpack.security.authc.providers:
    anonymous.anonymous1:
        order: 0
        session:
            idleTimeout: 1Y
        credentials:
            username: "anon"
            password: "SomeStrongPasswordIGuess"
    basic.basic1:
        order: 1
    ```
8. Reboot your system:
    ```
    sudo reboot
    ```
    
    
## Plugin for creating and storing snapshots of your data and cluster state to prevent 'collector time out'
    ```
    Run elasticsearch
    sudo /opt/ELK/elasticsearch/bin/elasticsearch-plugin -h
    sudo /opt/ELK/elasticsearch/bin/elasticsearch-plugin install repository-s3
    ```


