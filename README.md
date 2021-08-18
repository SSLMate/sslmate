## SSLMate command line client

`sslmate` is the command line client for [SSLMate](https://sslmate.com), a service for purchasing and managing SSL certificates. SSLMate provides easy-to-use tools for buying, renewing, and revoking certificates, for monitoring the expiration date of your certificates, and for synchronizing your certificates between your servers.

SSLMate emphasizes speed, ease-of-use, and automation.  For example, the command to purchase a certificate (sslmate buy) typically completes in under a minute and automates the steps of generating a private key, generating a CSR, and building a certificate bundle.  SSLMate can automatically renew your certificates, and you can run sslmate download from a cron job so that renewed certificates are automatically downloaded to your server.

To use the `sslmate` command, you must create a free account at https://sslmate.com.

## Dependencies

SSLMate officially supports:

 * Debian 9 and newer
 * Ubuntu 18.04 and newer
 * RHEL/CentOS 7 and 8
 * Amazon Linux 1 and 2
 * Fedora 27 and newer

Packages (.deb, .rpm) for the above operating systems [are available](https://sslmate.com/help/cmdline/install).

SSLMate can run on other Unix-based operating systems provided the following software is installed:

 * Perl v5.10.0 or newer.
 * The following Perl modules, which can be installed by running `cpan MODULENAME` or by installing the corresponding distro package.

   ```
   Module Name               Debian/Ubuntu Package       RHEL/CentOS Package
   -----------------------------------------------------------------------------
   URI                       liburi-perl                 perl-URI
   Term::ReadKey             libterm-readkey-perl        perl-TermReadKey
   JSON::PP [1]              libjson-perl                perl-JSON
   LWP (>= 6) [2]            libwww-perl                 perl-libwww-perl
   LWP::Protocol::https [2]  liblwp-protocol-https-perl  perl-LWP-Protocol-https
   ```

  Notes:

   1. `JSON::PP` is included with Perl 5.14 and later.
   2. `LWP` is optional; if not available SSLMate will fall back to executing the `curl` command directly.


## Installation

Run `make` and `make install`.

The following Makefile variables can be passed on the command line to `make` and `make install`:

* `PREFIX=/path` - Install to given path (default: `/usr/local`)
* `DESTDIR=/path` -  Stage installed files under the given path instead of installing directly to the filesystem (intended for package building)

Example:

```
make PREFIX=/usr
make install PREFIX=/usr DESTDIR=/tmp/pkgroot
```

## Getting started

See SSLMate's [guide to getting started](https://sslmate.com/help/cmdline/getting_started).

## Getting help

* Run `sslmate help`.
* Read the sslmate(1) man page.
* Consult [SSLMate's help documentation](https://sslmate.com/help).
* Email [support@sslmate.com](mailto:support@sslmate.com).
