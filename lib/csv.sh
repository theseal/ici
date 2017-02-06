#!/bin/sh

csv_index_entry ()
{
  status="$1"
  date="$2"
  serial="$3"
  foo="$4"
  dn="$5"

  echo "$status;$date;$serial;$dn"
}
