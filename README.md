### Simple Vagrant project that creates two VMs, one of them runs MySQL server, the other one is HashiCorp Vault server that provides dynamic credentials for the MySQL server.

#### How to use it :

- Execute `vagrant up` and in two different terminals `vagrant ssh vaultServer` and `vagrant ssh mysql`
- In `vaultServer` terminal request credentials for `my-role` with `vault read database/creds/my-role`, output should be like :
```
Key                Value
---                -----
lease_id           database/creds/my-role/ROoJMwzzwM3PQXMOYryttT6W
lease_duration     768h
lease_renewable    true
password           A1a-7Qsr90jPdyeMo6oY
username           v-root-my-role-OPDr0f3uAG5RkT9Kk
```
> The role is configured to return root credentials, this can be adjusted in `vaultSetup.sh` script.
- Verify in `mysql` terminal that the user is actually created with `select host, user from mysql.user;`, login to mysql first.
```
+-----------+----------------------------------+
| host      | user                             |
+-----------+----------------------------------+
| %         | root                             |
| %         | v-root-my-role-OPDr0f3uAG5RkT9Kk |
| localhost | debian-sys-maint                 |
| localhost | mysql.session                    |
| localhost | mysql.sys                        |
| localhost | root                             |
+-----------+----------------------------------+
```
- To revoke the credentials either lease ID is needed or `vault lease revoke -prefix /database` to revoke all creds.

### TO DO :
- [x] Create read-only role
- [ ] Create static-role
- [ ] Create rotation station statement
- [ ] Rotate root creds
