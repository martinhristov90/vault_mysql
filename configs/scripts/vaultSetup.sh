#!/usr/bin/env bash

# Setting Vault Address, it is running on localhost at port 8200
export VAULT_ADDR=http://127.0.0.1:8200


# Setting the Vault Address in Vagrant user bash profile
grep "VAULT_ADDR" ~/.bash_profile  > /dev/null 2>&1 || {
echo "export VAULT_ADDR=http://127.0.0.1:8200" >> ~/.bash_profile
}


# Stopping Vault
echo "Stopping Vault..."
sudo systemctl stop vault

# Overriding the Vault config file of the default box
sudo tee /etc/vault.d/vault.hcl > /dev/null << EOL
backend "file" {
path = "/vaultDataDir"
}
listener "tcp" {
address = "0.0.0.0:8200"
tls_disable = 1
}
# Enable UI
ui = true
EOL

# Starting Vault
echo "Starting Vault..."
sudo systemctl start vault

# Wait for Vault to start
echo "Waiting for Vault to start"
sleep 1

echo "Check if Vault is already initialized..."
if [ `vault status | awk 'NR==4 {print $2}'` == "true" ]
then
    echo "Vault already initialized...Exiting..."
    exit 1
fi

# Making working dir for Vault setup
mkdir -p /home/vagrant/_vaultSetup
touch /home/vagrant/_vaultSetup/keys.txt

echo "Initializing Vault..."
vault operator init -address=${VAULT_ADDR} > /home/vagrant/_vaultSetup/keys.txt
export VAULT_TOKEN=$(grep 'Initial Root Token:' /home/vagrant/_vaultSetup/keys.txt | awk '{print substr($NF, 1, length($NF))}')

echo "Unsealing vault..."
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 1:' /home/vagrant/_vaultSetup/keys.txt | awk '{print $NF}') > /dev/null 2>&1
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 2:' /home/vagrant/_vaultSetup/keys.txt | awk '{print $NF}') > /dev/null 2>&1
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 3:' /home/vagrant/_vaultSetup/keys.txt | awk '{print $NF}') > /dev/null 2>&1

echo "Auth with root token..."
vault login -address=${VAULT_ADDR} token=${VAULT_TOKEN} > /dev/null 2>&1

# Enabling userpass auth method.
echo "Enabling userpass auth method."
vault auth enable -address=${VAULT_ADDR} userpass > /dev/null 2>&1

# Enabling logging to a file
echo "Enabling logging to a file"
sudo touch /var/log/auditVault.log
sudo chown vault:vault /var/log/auditVault.log
vault audit enable file file_path=/var/log/auditVault.log

# Enabled database secret engine
echo "Enabling database secrets engine"
vault secrets enable database

# Configuring connection to the DB
vault write database/config/test_db \
    plugin_name="mysql-database-plugin" \
    connection_url="{{username}}:{{password}}@tcp(192.168.0.11:3306)/" \
    allowed_roles="my-role" \
    username="root" \
    password="SET_YOUR_PASS"

# Setting up role, creation and revocation statements are needed
vault write database/roles/my-role \
    db_name=test_db \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    revocation_statements="REVOKE ALL PRIVILEGES, GRANT OPTION FROM '{{name}}'@'%';DROP USER '{{name}}'@'%';"
    default_ttl="1h" \
    max_ttl="24h"

