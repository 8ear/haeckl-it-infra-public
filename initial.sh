#/bin/sh
set -ex

#
# Initial public script on https://github.com/8ear/haeckl-it-infra-public
#

# Check if sudo is available?
SUDO_AVAILABLE=$(command -v sudo)
[ -z "$SUDO_AVAILABLE" ] && echo "Script requires sudo, please install first." && exit 1


# Check if you are root?
# https://linuxhandbook.com/if-else-bash/
if [ $(whoami) = 'root' ]; then
	echo "You are root"
else
	echo "You are not root"
    # sudo is available:
    [ ! -z "$SUDO_AVAILABLE" ] && echo "I restart me self via sudo..." && sudo "$0" && exit 0
    exit 1
fi


# Check which OS is?
# https://stackoverflow.com/questions/2264428/how-to-convert-a-string-to-lower-case-in-bash
OS="$(grep DISTRIB_ID /etc/lsb-release|cut -d '=' -f 2|tr '[:upper:]' '[:lower:]')"
# For Example = ubuntu


# Update OS
if [ "${OS}" = "ubuntu" ]; then
    sudo apt-get update
    sudo apt-get upgrade -y
elif [ "${OS}" = "rhel" ]; then
    echo "Not integrated. Exit now."
    exit 1
fi


# Install Docker
if [ -z "$(command -v docker)" ] && [ "${OS}" = "ubuntu" ]; then
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    [ ! -f /etc/apt/keyrings/docker.gpg ] && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    # Add the repository to Apt sources:
    [ ! -f /etc/apt/sources.list.d/docker.list ] && echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    # Install packages
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
elif [ "${OS}" = "rhel" ]; then
    echo "Not integrated"
fi

# Install further Tools
if [ "${OS}" = "ubuntu" ]; then
    sudo apt-get update
    sudo apt-get install -y make git-crypt sudo git
fi

# Add SSH-Key
[ -d /root/.ssh ] || mkdir -p /root/.ssh
[ -f /root/.ssh/authorized_keys ] && echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFap7TE8SEu+HpcCmW53/xRalnwIhf0DourNRrWpgss" >> /root/.ssh/authorized_keys

# prepare for Git initialization
[ -d /srv/git ] || mkdir /srv/git
[ -z "$GIT_REPO_URL" ] && echo "Please set first GIT_REPO_URL env var to contine. Exit now." && exit 1
[ -z "$GIT_REPO_URL" ] && cd /srv/git && git clone $GIT_REPO_URL

# Add mgmt host inventory file
echo "Add Inventory file for mgmgt-host with correct hostname and user."
cat <<EOT >> /srv/git/infra/ansible/inventory/inv.mgmt-host.yml
all:
  vars:
    ansible_user: root
    ansible_ssh_private_key_file: ssh_keys/haeckl-it-infra-deploy.pem
  mgmt_host:
    hosts:
      $(hostname -f):
EOT

echo "All tasks done, docker is installed and git repo is cloned to /srv/git. Exit now."
exit 0
