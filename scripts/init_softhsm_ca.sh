#!/bin/bash

#
# This is an EXAMPLE of how ICI can be set up using softhsm2.
#

set -e

source /etc/ici/ici.conf

if [[ ! $ICI_CA_NAME ]]; then
    echo "$0: Environment variable ICI_CA_NAME not set"
    exit 1
fi

conf="${ICI_CA_ROOT}/${ICI_CA_NAME}/ca.config"
if [[ ! -f "${conf}" ]]; then
    # This command will create ca.config etc.
    ici -v "${ICI_CA_NAME}" init
fi

source "${conf}"

req_dir="${ICI_CA_ROOT}/${ICI_CA_NAME}/requests"
if [[ ! -d "${req_dir}" ]]; then
    mkdir "${req_dir}"
    # Configure CSR queues matching what is used in the example inotify_issue_and_publish.sh
    mkdir "${req_dir}"/{server,client,peer}
fi

if [[ ! -f "${SOFTHSM2_CONF}" || ! $(softhsm2-util --show-slots | grep "Label:\\s*${ICI_CA_NAME}_token") ]]; then
    echo "Did not find a token with label '${ICI_CA_NAME}_key', initialising SoftHSM"
    ici -v "${ICI_CA_NAME}" gentoken
else
    echo "SoftHSM already initialised"
fi

echo "Creating CA certificate"
ici "${ICI_CA_NAME}" root -d 30 -n '/CN=My Root CA/C=SE'

outgitdir="${ICI_CA_ROOT}/${ICI_CA_NAME}/out-git"
if [[ ! -d "${outgitdir}" ]]; then
    # Create git repository for the 'git' publishing done in the example inotify_issue_and_publish.sh
    git init "${outgitdir}"

    cd "${outgitdir}"
    git config user.email "ici@localhost"
    git config user.name "ICI CA"

    echo "Certificates created by ICI" > README
    git add README
    git commit -m init README
fi

echo ""
echo "ICI in Docker set up successfully, CA certificate:"
echo ""
cat "${ICI_CA_ROOT}/${ICI_CA_NAME}/ca.crt"

