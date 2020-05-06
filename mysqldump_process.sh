#!/bin/bash
dbuser="$1"
dbpass="$2"
dbname="$3"
dbhost="$4"
if [ -z "$dbname" ]; then
  echo "$0: Missing database operand."
  echo "Usage: $0 user passd database_name host"
  exit 1
fi

outfile="$(date +%Y%m%d)".$dbname.sql.gz

size=$(mysql --skip-column-names -h$dbhost -u$dbuser -p$dbpass  \
  -e "SELECT CEIL(SUM(data_length) / 1024 / 1024) \
      FROM information_schema.TABLES \
      WHERE table_schema='$dbname';")

echo "Export will be around "$size"MB."

mysqldump --routines=true --single-transaction --compress -h$dbhost -u$dbuser -p$dbpass $dbname | pv --progress --size "$size"m | gzip -9 > $outfile

echo "File written to: $outfile"

realsize=$(ls -lsh --block-size=1024/1024 $outfile | cut -d' ' -f1)
echo "Actual filesize is "$realsize"MB."

exit 0
