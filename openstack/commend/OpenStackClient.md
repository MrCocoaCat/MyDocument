https://docs.openstack.org/python-openstackclient/latest/

#### SYNOPSIS

openstack [<global-options>] <command> [<command-arguments>]

openstack help <command>

openstack --help

#### 描述(DESCRIPTION)  

openstack为openstack api提供了一个通用的命令行接口。其提供了和 CLIs相同的作用，通过 OpenStack project client函数库的支持,但是其具有独特一直的命令结构。

#### 认证方式(AUTHENTICATION METHODS)

openstack使用类似于openstack项目CLIs的身份验证方案，凭据信息可以作为环境变量提供，也可以作为命令行上的选项提供。

主要区别是在选项OS_PROJECT_NAME/OS_PROJECT_ID的名称中使用“project”而不是旧的tenant-based名称。

```
export OS_AUTH_URL=<url-to-openstack-identity>
export OS_PROJECT_NAME=<project-name>
export OS_USERNAME=<user-name>
export OS_PASSWORD=<password>  # (optional)
```
openstack可以使用keystoneclient库提供的不同类型的认证插件。下面的默认插件是可用的:

* token: Authentication with a token
* password: Authentication with a username and a password

有关这些插件及其选项的详细信息，请参阅keystoneclient库文档，以及可用插件的完整列表。但有些插件可能不支持openstack的所有功能;例如，v3unscopedsaml插件只能交付没有作用域的令牌，一些命令可能无法通过此身份验证方法使用。

另外，通过设置选项—— --os-token 和 --os-url(或者分别设置环境变量OS_TOKEN和OS_URL)，使用Keystone的服务令牌进行身份验证。该方法优先于身份验证插件。


#### OPTIONS
openstack采用全局选项来控制整体行为，以及command-specific选项控制命令具体操作。

大多数全局选项都有相应的环境变量，也可以通过命令设置值。如果两者都存在，command-specific优先。环境变量名从选项名派生而来，方法是删除前导破折号' - '，并将嵌入的破折号' - '转换为下划线' _ '，并转换为大写。

openstack定义了了以下全局选项:


* --os-cloud <cloud-name>

    openstack will look for a clouds.yaml file that contains a cloud configuration to use for authentication. See CLOUD CONFIGURATION below for more information.

* --os-auth-type <auth-type>

    The authentication plugin type to use when connecting to the Identity service.

    If this option is not set, openstack will attempt to guess the authentication method to use based on the other options.

    If this option is set, its version must match --os-identity-api-version

* --os-auth-url <auth-url>

    Authentication URL *认证URL*

* --os-url <service-url>

    Service URL, when using a service token for authentication
    *服务URL，即使用的 service 令牌*

* --os-domain-name <auth-domain-name>¶

    Domain-level authorization scope (by name)

* --os-domain-id <auth-domain-id>¶

    Domain-level authorization scope (by ID)

* --os-project-name <auth-project-name>

    Project-level authentication scope (by name)

* --os-project-id <auth-project-id>¶

    Project-level authentication scope (by ID)

* --os-project-domain-name <auth-project-domain-name>¶

    Domain name containing project

* --os-project-domain-id <auth-project-domain-id>¶

    Domain ID containing project

* --os-username <auth-username>¶

    Authentication username
    *认证的用户名*

* --os-password <auth-password>¶

    Authentication password
    *认证的用户密码*

--os-token <token>¶

    Authenticated token or service token

--os-user-domain-name <auth-user-domain-name>¶

    Domain name containing user

--os-user-domain-id <auth-user-domain-id>¶

    Domain ID containing user

--os-trust-id <trust-id>¶

    ID of the trust to use as a trustee user

--os-default-domain <auth-domain>¶

    Default domain ID (Default: ‘default’)

--os-region-name <auth-region-name>¶

    Authentication region name

--os-cacert <ca-bundle-file>¶

    CA certificate bundle file

--verify` | :option:`--insecure¶

    Verify or ignore server certificate (default: verify)

--os-cert <certificate-file>¶

    Client certificate bundle file

--os-key <key-file>¶

    Client certificate key file

--os-identity-api-version <identity-api-version>¶

    Identity API version (Default: 2.0)

--os-XXXX-api-version <XXXX-api-version>¶

    Additional API version options will be available depending on the installed API libraries.

--os-interface <interface>¶

    Interface type. Valid options are public, admin and internal.


Note

If you switch to openstackclient from project specified clients, like: novaclient, neutronclient and so on, please use –os-interface instead of –os-endpoint-type.

--os-profile <hmac-key>¶

    Performance profiling HMAC key for encrypting context data

    This key should be the value of one of the HMAC keys defined in the configuration files of OpenStack services to be traced.

--os-beta-command¶

    Enable beta commands which are subject to change

--log-file <LOGFILE>¶

    Specify a file to log output. Disabled by default.

-v, --verbose¶

    Increase verbosity of output. Can be repeated.

-q, --quiet¶

    Suppress output except warnings and errors

--debug

    Show tracebacks on errors and set verbosity to debug

--help

    Show help message and exit
