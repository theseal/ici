#!/bin/sh

set_status_display ()
{
case "$status" in
   "V")
      alert=""
      status_display="valid"
      ;;
   "R")
      alert="danger"
      status_display="revoked"
      ;;
   *)
      alert="warning"
      status_display="unknown"
      ;;
esac
}

html_index_head ()
{
cat<<EOH
<!DOCTYPE html>
<html lang="en-US">
<head>
<link rel="stylesheet" href="css/bootstrap.min.css">
<link rel="stylesheet" href="css/bootstrap-theme.min.css">
<link rel="stylesheet" href="css/style.css">
<title>${ICI_CA} CA Repository</title>
</head>
<body>
<div class="container">
<h1 class="page-header">${ICI_CA} CA Repository</h1>

<div class="btn-group" role="group">
   <a href="ca.crt" class="btn btn-success">Download CA Certificate (PEM)</a>
EOH
if [ -f "${ICI_CA_DIR}/crl.pem" ]; then
cat<<EOH
   <a href="crl.pem" class="btn btn-info">Download CRL (PEM)</a>
EOH
fi
cat<<EOH
</div>
<div class="certlist">
<table class="table table-condensed table-striped table-bordered">
<tr>
   <th>Subject</th>
   <th>Serial</th>
   <th>Expiry Date</th>
   <th>Status</th>
</tr>
EOH
}

html_index_foot ()
{
cat<<EOH
</table>
</div>
</div>
</body>
</html>
EOH
}

html_index_entry ()
{
status="$1"
date="$2"
serial="$3"
foo="$4"
dn="$5" 

set_status_display

cat<<EOH
   <tr class="${alert}">
      <td><a href="${serial}.html">${dn}</a></td>
      <td>${serial}</td>
      <td>${date}</td>
      <td>${status_display}</td>
   </tr>
EOH
}

html_cert_file ()
{
status="$1"
date="$2"
serial="$3"
foo="$4"
dn="$5"
fp_sha1=`$ICI_OPENSSL x509 -noout -fingerprint -sha1 < "${ICI_CA_DIR}/certs/${serial}.pem" | awk -F= '{print $NF}'`
fp_sha256=`$ICI_OPENSSL x509 -noout -fingerprint -sha256 < "${ICI_CA_DIR}/certs/${serial}.pem" | awk -F= '{print $NF}'`
not_before=`$ICI_OPENSSL x509 -noout -startdate < "${ICI_CA_DIR}/certs/${serial}.pem" | awk -F= '{print $NF}'`
not_after=`$ICI_OPENSSL x509 -noout -enddate < "${ICI_CA_DIR}/certs/${serial}.pem" | awk -F= '{print $NF}'`
text=`$ICI_OPENSSL x509 -noout -text < "${ICI_CA_DIR}/certs/${serial}.pem"`

set_status_display

cat<<EOH
<!DOCTYPE html>
<html lang="en-US">
<head>
<link rel="stylesheet" href="css/bootstrap.min.css">
<link rel="stylesheet" href="css/bootstrap-theme.min.css">
<link rel="stylesheet" href="css/style.css">
<title>${ICI_CA}: ${dn}</title>
</head>
<body>
<div class="container">
<h1 class="page-header">${dn}</h1>

<a class="btn btn-success" href="${serial}.pem">Download Certificate (PEM)</a>

<div class="certinfo">
<dl class="dl-horizontal">
   <dt>Subject DN</dt>
   <dd>${dn}</dd>
   <dt>Serial</dt>
   <dd>${serial}</dd>
   <dt>Status</dt>
   <dd>${status_display}</dt>
   <dt>Not Before</dt>
   <dd>${not_before}</dd>
   <dt>Not after</dt>
   <dd>${not_after}</dd>
   <dt>Fingerprint (sha1)</dt>
   <dd>${fp_sha1}</dd>
   <dt>Fingerprint (sha256)</dt>
   <dd>${fp_sha256}</dd>
</dl>
<pre>${text}</pre>
</div>
</div>
</body>
</html>
EOH
}
