# AutoSSL

AutoSSL is a small Bash helper for issuing and installing wildcard SSL certificates with `acme.sh` using a delegated DNS challenge zone.

It is designed for setups where you do **not** want to give your SSL automation full DNS access to every production domain. Instead, each real domain delegates only its ACME challenge record to a central alias zone such as `myautossl.com`.

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

Then run:

```bash
sudo autossl setup
```

During setup, you will be asked for:

- ACME account email
- delegated alias zone, for example `myautossl.com`
- reload command, auto-detected when possible
- Cloudflare API token
- Cloudflare Zone ID for the alias zone

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

## Usage

Check the delegated CNAME:

```bash
autossl check -d domain.com
```

Issue a real certificate:

```bash
autossl issue -d domain.com
```

Issue a staging/test certificate:

```bash
autossl issue -d domain.com --staging
```

Renew manually:

```bash
autossl renew -d domain.com
```

Force renew:

```bash
autossl renew -d domain.com --force
```

Remove a domain from local AutoSSL/acme.sh storage:

```bash
autossl remove -d domain.com
```

List certificates:

```bash
autossl list
```

Check local configuration:

```bash
autossl doctor
```

Show version:

```bash
autossl version
```

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
