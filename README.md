# Eclipse

Eclipse is a network scanner for monitoring open ports that uses RustScan to identify open ports.

## Tools and libraries
* Perl
* Curl
* RustScan
* Nmap
* Log-Any
* XML-Parser

## Install

1. Get the script:

```bash
git clone https://github.com/AnilAntari/Eclipse.git
```

2. Setting up ip.pm:

In ip.pm the IP addresses of the servers and the allowed ports are registered.

Exapmle:

```perl
our @servers = (
    '192.168.1.1' => [22, 80],
    '192.168.1.2' => [21, 443]
);
```

Alternatively, you can use the `--create-ip-pm` option to generate ip.pm.

Example:
```bash
eclipse.pl --create-ip-pm 192.168.1.1
```

3. Generating the hosts file:

Before starting eclipse, you need to generate a hosts file that stores all the ip addresses that were specified in ip.pm.

```bash
eclipse.pl --create-ip-list
```

4. Setting up config.pm:

The `$options` variable is responsible for the options that will be passed to rustscan.

5. Add eclipse.pl in your favorite time-based job scheduler.

## Telegram Notifications
If you want Eclipse to send notifications to telegram, you need to:
1. It is necessary to assign the number 1 to the `$th` variable;
2. Enter the token into the `$token` variable;
3. Enter the chat id in the `$chat_id` variable;
4. Make sure that curl is installed in the system.

## Blood Moon Mode
Blood Moon Mode is the mode in which Eclipse will use Nmap to detect running services on forbidden ports.
To start this mode, set the `$blood_moon_mode` variable to one.
This mode is disabled by default.
