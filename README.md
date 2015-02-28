## SSLMate command line client

`sslmate` is the command line client for [SSLMate](https://sslmate.com), a service for purchasing and managing SSL certificates. SSLMate provides easy-to-use tools for buying, renewing, and revoking certificates, for monitoring the expiration date of your certificates, and for synchronizing your certificates between your servers.

SSLMate emphasizes speed, ease-of-use, and automation.  For example, the command to purchase a certificate (sslmate buy) typically completes in under a minute and automates the steps of generating a private key, generating a CSR, and building a certificate bundle.  SSLMate can automatically renew your certificates, and you can run sslmate download from a cron job so that renewed certificates are automatically downloaded to your server.

To use the `sslmate` command, you must create a free account at https://sslmate.com.

## Dependencies

SSLMate officially supports:

 * Debian 6 and 7
 * Ubuntu 10.04, 12.04, 13.10, and 14.04
 * RHEL/CentOS 6 and 7
 * Mac OS X 10.9 and above

Packages (.deb, .rpm, and .pkg) for the above operating systems [are available](https://sslmate.com/help/install).

SSLMate can run on other Unix-based operating systems provided the following software is installed:

* Perl v5.10.0 or newer.
* The following Perl modules, which can be installed by running `cpan MODULENAME` or by installing the corresponding distro package.

```
Module Name         Debian/Ubuntu Package        RHEL/CentOS Package
-------------------------------------------------------------------------
URI                 liburi-perl                  perl-URI
Term::ReadKey       libterm-readkey-perl         perl-TermReadKey
JSON::PP (*)        libjson-perl                 perl-JSON
WWW::Curl (**)      libwww-curl-perl             perl-WWW-Curl
```

Notes:

* `JSON::PP` is included with Perl 5.14 and later.
* `WWW::Curl` is optional; if not available SSLMate will fall back to executing the `curl` command directly.


## Installation

* Run `make install` to install to /usr/local.
* Run `make install PREFIX=/usr` to install to /usr.

## Getting started

See SSLMate's [guide to getting started](https://sslmate.com/help/getting_started).

## Getting help

* Run `sslmate help`.
* Read the sslmate(1) man page.
* Consult [SSLMate's help documentation](https://sslmate.com/help).
* Email [support@sslmate.com](mailto:support@sslmate.com) or tweet to [@SSLMate](https://twitter.com/sslmate).
