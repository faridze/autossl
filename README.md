# AutoSSL

AutoSSL is a small Bash helper for issuing and installing wildcard SSL certificates with `acme.sh` using a delegated DNS challenge zone.

It is designed for setups where you do **not** want to give your SSL automation full DNS access to every production domain. Instead, each real domain delegates only its ACME challenge record to a central alias zone such as `myautossl.com`.

Current stable version: `1.0.0`

## Features

- Uses `acme.sh`
- Supports wildcard certificates
- Uses delegated DNS challenge via `--challenge-alias`
- Stores configuration under `/etc/autossl`
- Installs certificates under `/etc/ssl/acme/<domain>`
- Auto-detects OpenLiteSpeed, Nginx, Apache/httpd reload commands
- Uses Let's Encrypt by default
- Currently supports Cloudflare; designed so more providers can be added later

## DNS architecture

For a domain such as:

```text
domain.com
```

add this CNAME record in the DNS zone of `domain.com`:

```dns
_acme-challenge.domain.com CNAME _acme-challenge.domain.com.myautossl.com
```

AutoSSL will then create the TXT challenge record inside the delegated alias zone.

## Installation

```bash
git clone https://github.com/faridze/autossl.git
cd autossl
chmod +x install-autossl.sh
sudo ./install-autossl.sh
```

The installer copies the `autossl` command to:

```text
/usr/local/bin/autossl
```

Re-running the installer is safe. Before replacing an existing command, it saves a timestamped backup under:

```text
/etc/autossl/backups/
```

## Setup

Run:

```bash
sudo autossl setup
```

During setup, you will be asked for:

- ACME account email
- delegated alias zone, for example `myautossl.com`
- reload command, auto-detected when possible
- Cloudflare API token
- Cloudflare Zone ID for the alias zone

To replace an existing configuration, use:

```bash
sudo autossl setup --reconfigure
```

## Cloudflare token permissions

Create a Cloudflare API token for the delegated alias zone only.

Required permissions:

```text
Zone - DNS - Edit
Zone - Zone - Read
```

Zone resources:

```text
Include - Specific zone - myautossl.com
```

## Doctor

Check the local configuration, required commands, `acme.sh`, and renewal scheduling:

```bash
sudo autossl doctor
```

## Check

Check the delegated CNAME:

```bash
autossl check -d domain.com
```

The required delegated record has this form:

```dns
_acme-challenge.domain.com CNAME _acme-challenge.domain.com.myautossl.com
```

## Issue

Issue a real certificate:

```bash
sudo autossl issue -d domain.com
```

After confirming the delegated CNAME is correct, use `-y` to skip the interactive issue confirmation:

```bash
sudo autossl issue -d domain.com -y
```

## Issue With Staging

Test the complete flow against the Let's Encrypt staging directory before requesting a production certificate:

```bash
sudo autossl issue -d domain.com --staging
```

`--staging` always uses Let's Encrypt staging, regardless of the configured default CA. Staging certificates are not trusted by browsers and must not be used in production.

## Other Commands

Renew manually:

```bash
sudo autossl renew -d domain.com
```

Force renew:

```bash
sudo autossl renew -d domain.com --force
```

Remove a domain from local AutoSSL/acme.sh storage:

```bash
sudo autossl remove -d domain.com
```

Removal asks for confirmation. Use `-y` only when non-interactive removal is intended.

List certificates:

```bash
autossl list
```

Show version:

```bash
autossl version
```

## Uninstall

Run:

```bash
sudo autossl uninstall
```

The command removes `/usr/local/bin/autossl`. It keeps all data by default and asks separately before removing each of:

- `/etc/autossl` configuration and backups
- `/root/.acme.sh` account and certificate data
- `/etc/ssl/acme` installed certificates

Only type `yes` when you intend to permanently remove that directory.

## Certificate paths

For `domain.com`, certificates are installed to:

```text
/etc/ssl/acme/domain.com/fullchain.pem
/etc/ssl/acme/domain.com/privkey.pem
```

Use these paths in OpenLiteSpeed, Nginx, Apache, or other services.

## OpenLiteSpeed

AutoSSL tries to detect OpenLiteSpeed and uses:

```bash
/usr/local/lsws/bin/lswsctrl restart
```

as the reload command.

## Security notes

- Do not store Cloudflare tokens in shell history or public repositories.
- AutoSSL stores credentials in `/etc/autossl/credentials.conf` with mode `600`.
- The recommended Cloudflare token should have access only to the delegated alias zone, not to production domain zones.

## Provider roadmap

Version 1.0 supports Cloudflare. The configuration already contains provider-related fields, so additional providers can be added later using acme.sh DNS plugins.

## License

MIT
