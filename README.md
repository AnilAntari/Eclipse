# Eclipse

Eclipse is a network scanner for monitoring open ports that uses RustScan to identify open ports.

## Install

1. Get the script:

```bash
git clone https://github.com/AnilAntari/Eclipse.git
```

2. Installing dependencies:

RustScan and Log-Any are required to run.
Installation example:

```bash
sudo pacman -S perl-log-any rustscan
```

3. Setting up ip.pm:

In ip.pm the IP addresses of the servers and the allowed ports are registered.
Exapmle:

```perl
our @servers = (
    '192.168.1.1' => [22, 80],
    '192.168.1.2' => [21, 443]
);
```

Alternatively, you can use the --create-ip-pm option to generate ip.pm.

Example:
```bash
eclipse.pl --create-ip-pm 192.168.1.1
```

4. Generating the hosts file:

Before starting eclipse, you need to generate a hosts file that stores all the ip addresses that were specified in ip.pm.

```perl
eclipse.pl --create-ip-list
```

5. Setting up config.pm:

The `$options` variable is responsible for the options that will be passed to rustscan.
In order for notifications from the telegram bot to work, you need to fill in the `$token` and `$chat_id` variables.

6. Add eclipse.pl in your favorite time-based job scheduler.
