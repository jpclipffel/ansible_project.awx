#!/bin/bash

# Eases AXW-on-K8S management.


# Globals
ANSIBLE="ansible-playbook"
PLAYBOOK_BACKUP="$(dirname $0)/playbooks/backup_restore.yml"
PLAYBOOK_RESTORE="$(dirname $0)/playbooks/backup_restore.yml"

# Format
_norm=$(tput sgr0)
_bold=$(tput bold)
_undr=$(tput smul)
_warn=$(tput setaf 1; tput bold)


# Script usage
function usage() {
    local script_name="./$(basename ${0})"
    # ---
    cat << EOF
Usage: ${script_name} {${_bold}backup|restore|deploy${_norm}} [arguments]

${_bold}backup${_norm} - Backup an AWX database to a dump file

    ${_undr}Usage${_norm}
    ${script_name} backup <inventory> <database dump file>

    ${_undr}Example${_norm}
    ${script_name} backup ../inventories/awx_prod/ ~/Downloads/awx_prod.dump


${_bold}restore${_norm} - Restore an AWX database from a dump file

    ${_undr}Usage${_norm}
    ${script_name} restore <inventory> <database dump file>

    ${_undr}Example${_norm}
    ${script_name} restore ../inventories/awx_prod/ ~/Downloads/awx_prod.dump


${_bold}deploy${_norm} - Deploy or redeploy AWX

By default, ${_bold}deploy${_norm} will backup the AWX database to the current working directory as ${_bold}awx_autosave_deploy.dump.<date>_<time>${_norm}.
You can pass a third optional argument to change the backup file name and location.

    ${_undr}Usage${_norm}
    ${script_name} deploy <inventory> <installation playbook> [database dump file]

    ${_undr}Examples${_norm}
    ${script_name} deploy ../inventories/awx_prod/ ~/Downloads/awx_git/installer/install.yml
    ${script_name} deploy ../inventories/awx_prod/ ~/Downloads/awx_git/installer/install.yml ~/Downlads/awx.dump
EOF
}


# Prompt
function confirm() {
    echo "${@}"
    read -p "Continue ? [y/N]: " cont
    [[ "${cont}" != "y" ]] && exit 1
}


# Backup AWX database from a PSQL server running on K8S.
function backup_db() {
    local inventory=${1}
    local db_dump=$(readlink -f ${2})
    # ---
    # Assertions
    [[ ! -e ${inventory} ]] && echo "Error: inventory '${inventory}' not found" && usage && exit 1
    [[ ! -n ${db_dump} ]] && echo "Error: database dump file name may not be null" && usage && exit 1
    # Check database dump file existence
    [[ -e ${db_dump} ]] && confirm "Warning: Database dump file '${db_dump}' already exists"
    # Dump database
    confirm "Will now backup database from cluster '${inventory}' to '${db_dump}'"
    ${ANSIBLE} -i ${inventory} ${PLAYBOOK_BACKUP} --tags 'backup' -e awx_db_dump=\""${db_dump}"\"
}


# Restore AWX database to a PSQL server running on K8S.
function restore_db() {
    local inventory=${1}
    local db_dump=$(readlink -f ${2})
    # ---
    # Assertions
    [[ ! -e ${inventory} ]] && echo "Error: inventory '${inventory}' not found" && usage && exit 1
    [[ ! -e ${db_dump} ]] && echo "Error: database dump file '${db_dump}' not found" && exit 1
    # Restore database
    confirm "Will now restore database to cluster '${inventory}' from '${db_dump}'"
    ${ANSIBLE} -i ${inventory} ${PLAYBOOK_RESTORE} --tags 'restore' -e awx_db_dump=\""${db_dump}"\"
}


function deploy() {
    local inventory=${1}
    local installer=${2}
    local db_dump=${3:-"awx_autosave_deploy.dump.$(date +'%F_%R')"}
    # ---
    # Assertions
    [[ ! -e ${inventory} ]] && echo "Error: inventory '${inventory}' not found" && usage && exit 1
    [[ ! -e ${installer} ]] && echo "Error: installation playbook '${installer}' not found" && usage && exit 1
    # Enforce AWX database backup
    echo "AWX database backup is mandatory before (re)deployment"
    backup_db ${inventory} "${db_dump}"
    # (re)Deploy AWX
    confirm "Will now deploy AWX on cluster '${inventory}''"
    ${ANSIBLE} -i ${inventory} ${installer} -l "awx_cluster"
}


# Entry point
case ${1} in
    usage|help) usage; exit 0;;
    backup)     shift; backup_db ${@};;
    restore)    shift; restore_db ${@};;
    deploy)     shift; deploy ${@};;
    *)          echo "${_warn}Error: unknown action '${1}'${_norm}"; echo; usage; exit 1;;
esac
