# Ansible project - AWX

Ansible project to deploy and manage AWX clusters.

An utility script, `manage.sh`, will help you in the (re)deployment, upgrade, backup and restoration of AWX.

## Inventory setup

This project requires a host group named `awx_cluster` to hold AWX variables and clusters hosts list (usually the K8S master node / VIP).

## Playbooks

| Playbook                       | Description                                                | Ready for AWX |
|--------------------------------|------------------------------------------------------------|---------------|
| `playbooks/backup_restore.yml` | Backup and restore the AWX database.                       | No            |
| `playbooks/preapre.yml`        | Prepare a generic AWX installation on a Kubernetes cluster | No            |

### Playbook - `playbooks/backup_restore.yml`

Backup and restore the AWX database.

By default, the database backup will be write and read to/from `./database.dump`; You can customize the path by setting the variable `awx_db_dump`.

Usage:

* Backup: `ansible-playbook -i <path to inventory> playbooks/backup_restore.yml --tags backup`
* Restore: `ansible-playbook -i <path to inventory> playbooks/backup_restore.yml --tags restore`

### Playbook - `playbooks/prepare.yml`

Prepare a generic AWX installation on a Kubernetes cluster:

* Create the AWX namespace
* Install or update PostgresQL Helm chart
* Clone and update AWX repository on Ansible controller (local host)

Usage: `ansible-playbook -i <path to inventory> playbooks/prepare.yml --tags setup`

### Playbook - `awx_{ awx_version }/installer/install.yml`

Install AWX using the official and default AWX installation playbook for Kubernetes.

> Note  
> This playbook is located in the AWX repository, which is cloned and updated when running `prepare.yml`.

Usage: `ansible-playbook -i <path to inventory> <awx repository>/installer/install.yml -l awx_cluster`

---

## Management tips

### Backup

* Using `manage.sh`: `./manage.sh backup <path to inventory> <path to DB dump>`
* Using `ansible-playbook`: `ansible-playbook -i <path to inventory> playbooks/backup_restore.yml --tags backup -e awx_db_dump="<path to DB dump>"`

### Restore

* Using `manage.sh`: `./manage.sh restore <path to inventory> <path to DB dump>`
* Using `ansible-playbook`: `ansible-playbook -i <path to inventory> playbooks/backup_restore.yml --tags restore -e awx_db_dump="<path to DB dump>`

### Refresh, deploy, redeploy, upgrade

* Using `manage.sh`: `./manage.sh deploy <path to inventory> <path to AWX installation playbook>`
* Using `ansible-playbook`:
  * Backup database: `ansible-playbook -i <path to inventory> playbook/backup_restore.yml --tags backup`
  * Run AWX installer: `ansible-playbook -i <path to inventory> <awx repository>/installer/install.yml -l awx_cluster`

### Scale AWX deployment

You can scale AWX deployment (add or remove instances) by running the appropriate `kubectl` command. Assuming the number of desired replicas/instances is `<instances count>`:

```shell
kubectl -n awx scale --replicas=<instances count> deployment/awx
```
