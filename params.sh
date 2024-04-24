ROOT="/opt/cfengine/masterfiles_staging"
GIT_URL="https://github.com/craigcomstock/play-cfbs"
GIT_REFSPEC="simple"
GIT_USERNAME=""
GIT_PASSWORD=""
GIT_WORKING_BRANCH="CF_WORKING_BRANCH"
PKEY="/opt/cfengine/userworkdir/admin/.ssh/id_rsa.pvt"
SCRIPT_DIR="/var/cfengine/httpd/htdocs/api/dc-scripts"
VCS_TYPE="GIT_CFBS"

export PATH="${PATH}:/var/cfengine/bin"
export PKEY
export GIT_USERNAME
export GIT_PASSWORD
export GIT_SSH="${SCRIPT_DIR}/ssh-wrapper.sh"
export GIT_ASKPASS="${SCRIPT_DIR}/git-askpass.sh"
