Command scripts
===============

What ici does
-------------

ici is very simply a wrapper that calls subcommands, so the important
part to work with are the latter.

ici itself will parse the global options as well as the CA name and
the subcommand name from the command line, and finally the
per-subcommand options (see lib/args.sh).  The rest of the command
line arguments are simply passed down to the subcommand scripts.

Structure
---------

To create a subcommand, you have to do the following (replace $cmd
with the command's name):

- mkdir $cmd.d
- $EDITOR $cmd.d/desc		# A one liner description
- $EDITOR $cmd.d/help		# Detailed usage text

Additionally, add the command scripts themselves.  Those need to have
names starting with a digit, not ending with ~ and have the executable
bit set.  They are expected to be written in any variant of Borne
Shell (such as Korn Shell, Bash, ...), but can really be written in
any scripting language with a bit of effort (not really recommended).

What subcommand scripts should do
---------------------------------

With the exception of the subcommand scripts in init.d/, all of them
should source $ICA_CA_DIR/ca.config.

The subcommand scripts are expect to 'exit 0' when successful and
'exit n' (where n is a number != 0) when not.  The latter will have
ici stop processing subcommand scripts, and exit as well with the same
exit code.


Environment
===========

There are some useful environment available, all with names starting
with 'ICI_'.  Some are provided by ici, others through the CA config
file, and finally, some come from helper scripts in lib/.

Variables defined by ici
------------------------

ici defines the following variables:

* ICI_OPENSSL     - the openssl command.
* ICI_PKCS11_TOOL - the pkcs11-tool command.

* ICI_CONF_DIR    - the directory where ici.conf is found.
* ICI_CONF        - the path to ici.conf.  Basically $ICI_COND_DIR/ici.conf 
* ICI_LIB_DIR     - the directory where the subcommand directories are
                    found, as well as some helper scripts (in $ICI_LIB_DIR/lib).

* ICI_VERBOSE     - has value 'y' if the user asked for verbosity.
* ICI_CA          - the name of the CA, given on the command line.
* ICI_CMD         - the subcommand name, given on the command line.
* ICI_CA_DIR      - the top of the CA directory tree.
* ICI_CONFIG      - the temporary configuration file to be used with
                    'openssl ca'.
* ICI_PRG         - the ici command itself, as entered on the command line.

Variables defined by the CA configuration
-----------------------------------------

* ICI_CA_KEY_ID   - the identity of the key to be used when a key is needed.
* ICI_CA_KEY_ID   - the slot of the same key.
* ICI_PKCS11      - the pkcs11 library.
* ICI_PKCS11_PIN  - the passphrase to use when access the key.
* ICI_MD          - the digest algorithm to be used when creating certificates.
* ICI_PUBLIC_URL  - the URL where the CA stores its public information.

* SOFTHSM_CONF    - The configuration oof shfthsm.


A word on git
=============

The current design of the git repository is to have two branches, one
with actual ici code, and one with debian-specific additions:

- upstream, the branch where ici itself is worked on
- master, the branch that adds the debian/ subdirectory

This structure is deeply affected by the functioning of
git-buildpackage.  It might, however, change in the future.
