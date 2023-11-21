#/bin/sh
set -x

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
    echo "Not integrated"
fi


# Install Docker
if [ "${OS}" = "ubuntu" ]; then
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    # Add the repository to Apt sources:
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    # Install packages
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
elif [ "${OS}" = "rhel" ]; then
    echo "Not integrated"
fi
