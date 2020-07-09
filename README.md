# Ansible project - AWX

Ansible project to deploy and manage AWX clusters.

## Inventory setup

This project requires a host group named `awx_cluster` to hold AWX variables and clusters hosts list (usually K8S master node / VIP).

## Playbooks

| Playbook             | Description                                                | Ready for AWX |
|----------------------|------------------------------------------------------------|---------------|
| `backup_restore.yml` | Backup and restore the AWX database.                       | No            |
| `preapre.yml`        | Prepare a generic AWX installation on a Kubernetes cluster | No            |

### Playbook - `backup_restore.yml`

Backup and restore the AWX database.

By default, the database backup will be write and read to/from `${PWD}/database.dump`; You can customize the path by setting the variable `awx_db_dump`.

Usage:

* Backup: `ansible-playbook -i ${source_cluster_inventory} backup_restore.yml --tags backup`
* Restore: `ansible-playbook -i ${source_cluster_inventory} backup_restore.yml --tags restore`

### Playbook - `prepare.yml`

Prepare a generic AWX installation on a Kubernetes cluster:

* Create the AWX namespace
* Install or update PostgresQL Helm chart

Usage: `ansible-playbook -i ${inventory} prepare.yml --tags setup`

---

## Management tips

### Scale AWX deployment

You can scale AWX deployment (add or remove instances) by running the appropriate `kubectl` command. Assuming the number of desired replicas/instances is `${instances}`:

```shell
kubectl -n awx scale --replicas=${instances} deployment/awx
```

### Upgrade AWX

Sequence:

* Scale deployment size to 0: `kubectl -n awx scale --replicas=0 deployment/awx`
* Backup database: `ansible-playbook -i ${inventory} backup_restore.yml --tags backup`
* Run AWX installer: `ansible-playbook -i ${inventory} ${awx_repo}/installer/install.yml -l awx_cluster`
