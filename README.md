ici - the Imbecile Certificate Issuer

Introduction
------------

Once there was a package called 'CSP' [^aboutthename](https://launchpad.net/csp) which is rumored to have been used in a lot of places to build and run small-scale "in-house" CAs. The code has now degenerated to the point where I don't care to maintain it (also its perl which I've weend myself off over the years) anymore. I recently found myself wanting a simple CA again (its been a while) and decided to try my hand at rewriting CSP using an even more simple tool than perl: sh

As with 'CSP' the basic architecture is simple: use existing tools like openssl and pkcs11-tool but wrap them (and their config files) in a nice blanket of sensible defaults.

What is it good for?
-----------------

* small-scale inhouse CAs
* offline root CAs that still needs a public repository
* CA for your etcd or docker registry

What is it not good for?
----------------------

* Not having to pay for "real" certificates
* Public websites and e-commerce
* acme/letsencrypt setups

Acknowledgement
---------------

I stole a lot of the structure of the sh-code from Simon Josefssons excellet cosmos package https://gitorious.org/cosmos/ and applid the same License (GPL) to ici.

Installing
----------

Type

```
ici # make install
```

or use the debian package.

Get Started
-----------

I wrote CSP before I understood the value of using tokens to abstract key management so CSP had very poor support for HSMs and other security tokens. By contrast ici only works with PKCS11-based tokens. You can use SoftHSM if you insist on keeping your keys on disk and the example below uses SoftHSM for simplicity.

0. To run ICI in a Docker example environment, try this:

```
# make docker_build
# make docker_init_ca
  - inspect files created in hosts directory /var/lib/ici/example
# make docker_run
  - copy a CSR to /var/lib/ici/example/requests/server/ and look for the certificate in /var/lib/ici/example/out-*
```

1. Create a CA

First take a look at /etc/ici/ici.conf to verify that the defaults look ok to you [^vim]. They should.

```
# vi /etc/ici/ici.conf
# ici myca create
# ici myca init
# vi /var/lib/ici/myca/ca.config
# vi /var/lib/ici/myca/name.policy
# vi /var/lib/ici/myca/cert.policy
```

If you are going to publish an (offline) repository for you CA you should make sure to change the ICI_PUBLIC_URL setting.  The gentoken command creates a SoftHSM token inside the CA directory (/var/lib/ici/myca/) - if you want to use another PKCS11 token, change the ICI_PKCS11, ICI_PKCS11_SLOT and ICI_PKCS11_KEY_ID to the appropriate values (and you can also skip running ici gentoken in this case). If you want gentoken to set a more sensible password, alter ICI_PKCS11_PIN before running gentoken.

The two files name.policy and cert.policy are openssl config file fragments: name.policy limits subject DNs and cert.policy specifies the policy extension. Edit to taste.

2. Create a root CA certificate

```
# ici myca root -d 3650 -n '/CN=My Root CA/C=SE'
.... (you will be prompted for token PIN which is 'secret' in the demo setup)
```

3. Issue a cert

```
# ici myca issue -d 365 -n '/CN=www.example.com/O=MyOrg/C=SE' www.example.com.csr
```

Here www.example.com.csr is a standard PEM-encoded PKCS#10. Creating it is left as an exercise to the reader for now.

4. Generate a CRL and publish your repository

```
# ici myca gencrl
# ici myca publish html /var/www/html/
```

In a production environment you'll probably not keep your public web repository on the same machine as the CA.

[^aboutthename]: The name 'CSP' predated the MSFT certificate service provider specification but was clearly an unfortunate choice.

[^vim]: I won't insult your intelligence by using $EDITOR in the examples.
