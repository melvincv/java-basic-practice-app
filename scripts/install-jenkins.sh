#!/bin/bash
# Jenkins Controller

### Variables ###
# Set your email for Let's Encrypt notifications
EMAIL="xxxxxx@live.com"
DOMAIN_NAME="jenkins.aws.melvincv.com"
# Set Maven version and download URL
JAVA_VERSION="17"
MAVEN_VERSION="3.9.6"
MAVEN_DOWNLOAD_URL="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"

# Set Maven installation directory
MAVEN_INSTALL_DIR=/opt/apache-maven
# Disable needrestart
sudo sed -i 's/#\$nrconf{restart} = '\''i'\'';/\$nrconf{restart} = '\''a'\'';/' /etc/needrestart/needrestart.conf
### Variables End ###

# Update System
sudo apt update && sudo apt upgrade -y

# Install Java 17 and Maven
sudo apt install -y openjdk-${JAVA_VERSION}-jdk
# Download Maven
wget ${MAVEN_DOWNLOAD_URL} -P /tmp
# Extract Maven to the installation directory
sudo mkdir -p ${MAVEN_INSTALL_DIR}
sudo tar -xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz -C ${MAVEN_INSTALL_DIR} --strip-components=1
# Update system PATH and set M2_HOME
sudo sh -c "echo 'export M2_HOME=${MAVEN_INSTALL_DIR}' >> /etc/profile.d/maven.sh"
sudo sh -c "echo 'export PATH=\${M2_HOME}/bin:\${PATH}' >> /etc/profile.d/maven.sh"
sudo chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc   https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]   https://pkg.jenkins.io/debian-stable binary/ | sudo tee   /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins

# Install Docker
curl -fsSL https://get.docker.com -o install-docker.sh
sudo sh install-docker.sh
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins
rm -f install-docker.sh

# Install Ansible
sudo apt install -y ansible

# Install Caddy reverse proxy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install -y caddy
sudo systemctl stop caddy

# Configure Caddy
sudo cp -av /etc/caddy/Caddyfile /etc/caddy/Caddyfile.bk
sudo tee /etc/caddy/Caddyfile <<EOF
{
    email "${EMAIL}"
}

${DOMAIN_NAME} {
	reverse_proxy localhost:8080
}
EOF

# Start caddy after configuring DNS

exit 0