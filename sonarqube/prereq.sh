#!/bin/bash
# Sonarqube Prerequisites
# Docker User
USERNAME="ubuntu"
# Let's Encrypt Email ID
EMAIL="xxxxxx@live.com"
DOMAIN_NAME="sonar.aws.melvincv.com"

# Check if run as root
if [ "$EUID" -ne 0 ]; then
    echo This script should be run as root. Exiting...
    exit 1
fi

# Check if USERNAME is set
if [[ -z "${USERNAME}" ]]; then
    echo Please set the value of USERNAME in the script. Exiting...
    exit 1
fi

# Upgrade Ubuntu
apt update && apt upgrade -y

# Kernel Settings
sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072
ulimit -n 131072
ulimit -u 8192

# Kernel Settings - Permanent
cat <<EOF > /etc/sysctl.d/99-sonarqube.conf
vm.max_map_count=524288
fs.file-max=131072
EOF

cat <<EOF > /etc/security/limits.d/99-sonarqube.conf
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
EOF

# Install Docker
curl -fsSL https://get.docker.com -o install-docker.sh
sh install-docker.sh
usermod -aG docker ${USERNAME}
rm -f install-docker.sh

# Install Caddy reverse proxy
apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
apt update
apt install -y caddy
systemctl stop caddy

# Configure Caddy
cp -av /etc/caddy/Caddyfile /etc/caddy/Caddyfile.bk
tee /etc/caddy/Caddyfile <<EOF
{
    email "${EMAIL}"
}

${DOMAIN_NAME} {
	reverse_proxy localhost:9000
}
EOF

# Start caddy after configuring DNS

exit 0