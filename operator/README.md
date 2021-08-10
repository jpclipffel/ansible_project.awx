# Ansible project - AWX

Ansible project to deploy and manage AWX clusters.

## Playbooks

| Playbook       | Description                                 |
|----------------|---------------------------------------------|
| `operator.yml` | Apply & delete AWX operator and resource(s) |

### Playbook - `operator.yml`

Apply & delete AWX operator and resource(s).

Tags:

| Tag               | Description              |
|-------------------|--------------------------|
| `apply-operator`  | Deploy the AWX operator  |
| `delete-operator` | Delete the AWX operator  |
| `apply`           | Deploy an AWX stack      |
| `delete`          | Remove an AWX stack      |

Variables:

| Variable               | Description                                          | Required | Type                | Default |
|------------------------|------------------------------------------------------|----------|---------------------|---------|
| `awx_yaml`             | The AWX YAML name (`awx-managed` or `awx-migration`) | Yes      | `string`            | -       |
| `awx_operator_version` | The AWX operator version                             | Yes      | `string` as `X.Y.Z` | -       |

#### Example - Deploy and upgrade the operator

* You should **not** remove the current AWX stack before the operator deployment
* The operator should upgrade AWX deployment(s) by itself

```shell
ansible-playbook -i <AWX on K8S inventory> playbooks/operator.yml \
    -e awx_yaml='awx-migration' \
    -e awx_operator_version='0.12.0'
    --tags 'apply-operator'
```

#### Example - Migrate from AWX < 18.X

```shell
ansible-playbook -i <AWX on K8S inventory> playbooks/operator.yml \
    -e awx_yaml='awx-migration' \
    -e awx_operator_version='0.12.0'
    --tags 'apply'
```

#### Example - Migrate from migration to managed

* You **should** remove the current AWX stack before redeploying it

```shell
ansible-playbook -i <AWX on K8S inventory> playbooks/operator.yml \
    -e awx_yaml='awx-managed' \
    -e awx_operator_version='0.12.0'
    --tags 'apply'
```

#### Example - Remove the operator

```shell
ansible-playbook -i <AWX on K8S inventory> playbooks/operator.yml \
    -e awx_yaml='awx-managed' \
    -e awx_operator_version='0.12.0'
    --tags 'delete-operator'
```

#### Example - Remove an AWX deployment

```shell
ansible-playbook -i <AWX on K8S inventory> playbooks/operator.yml \
    -e awx_yaml='awx-managed' \
    -e awx_operator_version='0.12.0'
    --tags 'delete'
```
