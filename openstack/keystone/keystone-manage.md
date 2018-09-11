https://docs.openstack.org/keystone/ocata/man/keystone-manage.html


#### DESCRIPTION

keystone-manage is the command line tool which interacts with the Keystone service to initialize and update data within Keystone. Generally, keystone-manage is only used for operations that cannot be accomplished with the HTTP API, such data import/export and database migrations.

#### USAGE

keystone-manage [options] action [additional args]



* bootstrap: Perform the basic bootstrap process.

* credential_migrate: Encrypt credentials using a new primary key.

* credential_rotate: Rotate Fernet keys for credential encryption.

* credential_setup: Setup a Fernet key repository for credential encryption.

* db_sync: Sync the database.*同步数据库*

* db_version: Print the current migration version of the database.

* doctor: Diagnose common problems with keystone deployments.

* domain_config_upload: Upload domain configuration file.

* fernet_rotate: Rotate keys in the Fernet key repository.

* fernet_setup: Setup a Fernet key repository for token encryption.
*设置用于令牌加密的Fernet密钥存储库*

* mapping_populate: Prepare domain-specific LDAP backend.

* mapping_purge: Purge the identity mapping table.

* mapping_engine: Test your federation mapping rules.

* pki_setup: Initialize the certificates used to sign revocation lists. deprecated

* saml_idp_metadata: Generate identity provider metadata.

* token_flush: Purge expired tokens.
