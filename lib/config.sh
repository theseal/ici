
c_init ()
{
cat<<EOC
openssl_conf = openssl_init
[openssl_init]
engines = engines_section
oid_section = oids

[oids]
domainComponent=0.9.2342.19200300.100.1.25

[engines_section]
pkcs11 = pkcs11_section

[pkcs11_section]
engine_id = pkcs11
dynamic_path = /usr/lib/engines/engine_pkcs11.so
MODULE_PATH = ${ICI_PKCS11}
PIN = ${ICI_PKCS11_PIN}
init = 0

EOC
}

c_req () 
{
cat<<EOC

[req]
default_bits           = ${ICI_BITS:=4096}
distinguished_name     = req_dn
prompt                 = no
x509_extensions        = extensions
default_md             = ${ICI_MD}
EOC
}

c_dn ()
{
echo
echo \# ${ICI_SUBJECT_DN}
echo "[req_dn]"
(
IFS=/
for rdn in ${ICI_SUBJECT_DN}; do
   if [ ! -z "$rdn" ]; then
      echo "$rdn" | awk -F= '{ print toupper($1) "=" $2 }'
   fi
done
)
}

c_ca ()
{
cat<<EOC
[ca]
default_ca = CA

[CA]
outdir                = "${ICI_CA_DIR}/certs"
certificate           = "${ICI_CA_DIR}/ca.crt"
default_md            = "${ICI_MD}"
serial                = "${ICI_CA_DIR}/serial"
database              = "${ICI_CA_DIR}/index.txt"
preserve              = no
unique_subject        = no
extensions            = extensions
crl_extensions        = crl_extensions
copy_extensions       = ${ICI_COPY_EXTENSIONS:-none}
EOC
if [ -f "${ICI_CA_DIR}/name.policy" ]; then
   echo "policy       = policy"
   echo
   cat "${ICI_CA_DIR}/name.policy"
fi
}

c_ext_common ()
{
cat<<EOC

[crl_extensions]

[extensions]
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid
EOC
ICI_AUTHORITY_INFO_ACCESS=
if [ ! -z "${ICI_PUBLIC_URL}" ]; then
if [ ! -z "${ICI_AUTHORITY_INFO_ACCESS}" ]; then
ICI_AUTHORITY_INFO_ACCESS="${ICI_AUTHORITY_INFO_ACCESS},"
fi
ICI_AUTHORITY_INFO_ACCESS="${ICI_AUTHORITY_INFO_ACCESS}caIssuers;URI:\"${ICI_PUBLIC_URL}/ca.crt\""
fi
if [ ! -z "${ICI_OCSP_URL}" ]; then
if [ ! -z "${ICI_AUTHORITY_INFO_ACCESS}" ]; then
ICI_AUTHORITY_INFO_ACCESS="${ICI_AUTHORITY_INFO_ACCESS},"
fi
ICI_AUTHORITY_INFO_ACCESS="${ICI_AUTHORITY_INFO_ACCESS}OCSP;URI:\"${ICI_OCSP_URL}\""
fi
if [ ! -z "${ICI_AUTHORITY_INFO_ACCESS}" ]; then
cat<<EOC
authorityInfoAccess     = ${ICI_AUTHORITY_INFO_ACCESS}"
EOC
fi
if [ ! -z "${ICI_PUBLIC_URL}" ]; then
cat<<EOC
crlDistributionPoints   = URI:"${ICI_PUBLIC_URL}/crl.pem"
issuerAltName           = URI:"${ICI_PUBLIC_URL}"
EOC
fi
if [ ! -z "$ICI_ALTNAMES" ]; then
cat<<EOC
subjctAltNames          = ${ICI_ALTNAMES}
EOC
fi
if [ -f "${ICI_CA_DIR}/ca.policy" ]; then
cat<<EOC
certificatePolicies     = ia5org,@certpolicy
EOC
fi
}

c_ext_ca ()
{
cat<<EOC

basicConstraints        = critical,CA:TRUE
keyUsage                = critical,cRLSign, keyCertSign
EOC
}

c_ext_tls_server ()
{
cat<<EOC

basicConstraints        = CA:FALSE
keyUsage                = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage        = serverAuth
EOC
}

c_ext_tls_client ()
{
cat<<EOC

basicConstraints        = CA:FALSE
keyUsage                = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage        = clientAuth
EOC
}

c_ext_user ()
{
cat<<EOC

basicConstraints        = CA:FALSE
keyUsage                = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage        = clientAuth,emailProtection
EOC
}


c_ext_tls_peer ()
{
cat<<EOC

basicConstraints        = CA:FALSE
keyUsage                = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage        = serverAuth, clientAuth
EOC
}

c_ext_tls_ocsp ()
{
cat<<EOC

basicConstraints        = CA:FALSE
keyUsage                = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage        = OCSPSigning
EOC
}

c_ext_policy ()
{
if [ -f "${ICI_CA_DIR}/ca.policy" ]; then
   cat "${ICI_CA_DIR}/ca.policy"
fi
}
