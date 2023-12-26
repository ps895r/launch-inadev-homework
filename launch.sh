#!/bin/bash

#clone below repo that contains terraform/helm to launch Jenkins in EKS cluster
git clone https://github.com/ps895r/inadev-homework.git
#terraform.tfstate ./inadev-homework/Terraform-Helm-EKS-Jenkins
cd inadev-homework/Terraform-Helm-EKS-Jenkins
#launch the eks cluster with Jenkins
terraform init 
terraform apply -auto-approve

# use service name to filter out the DNS name where Jenkins is located
aws eks --region us-east-2 update-kubeconfig --name dev10-cluster

SERVICE_NAME="jenkins"
##port="8080"
DNS_NAME=$(kubectl get service $SERVICE_NAME -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo $DNS_NAME

# install jenkins cli back where launch script is located
cd ../../
wget $DNS_NAME:8080/jnlpJars/jenkins-cli.jar

# give some time for things to update

sleep 30

# install some plugins using the CLI. Kindof a messy way - to do: break into separate script or add to manifest
# to do - export jenkins credentials to avoid hard coding

java -jar jenkins-cli.jar -s "http://$DNS_NAME:8080/" -auth $JENKINS_USER:$JENKINS_PASS install-plugin docker-workflow pipeline-stage-view

java -jar jenkins-cli.jar -s "http://$DNS_NAME:8080/" -auth $JENKINS_USER:$JENKINS_PASS install-plugin github

java -jar jenkins-cli.jar -s "http://$DNS_NAME:8080/" -auth $JENKINS_USER:$JENKINS_PASS safe-restart

# give some time for Jenkins to come back up after installing plugins

sleep 60

# Setup Jenkins credentials for github integration
java -jar jenkins-cli.jar -s "http://$DNS_NAME:8080/" -auth $JENKINS_USER:$JENKINS_PASS \
    create-credentials-by-xml system::system::jenkins \
    "(global)" \
    <<EOF
    <com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
        <scope>GLOBAL</scope>
        <id>git</id>
        <description>Your Credential Description</description>
        <username>$GIT_USER</username>
        <password>$GIT_PASS</password>
    </com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF

# Create pipeline job

java -jar jenkins-cli.jar -s "http://$DNS_NAME:8080/" -auth $JENKINS_USER:$JENKINS_PASS create-job generateWeather < ./weather.xml 

# Generate the GitHub webhook

./generate_webhook.sh $DNS_NAME

# run the weather build

java -jar jenkins-cli.jar -s "http://$DNS_NAME:8080/" -auth $JENKINS_USER:$JENKINS_PASS build generateWeather




