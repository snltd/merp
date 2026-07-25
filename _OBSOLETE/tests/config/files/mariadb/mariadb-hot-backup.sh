#!/bin/ksh

# Perform hot backups of important databases.

BACKUP_USER=backup
BACKUP_PASSWORD=************
ARC_DIR=/backup/archive
LATEST_DIR=/backup/latest

umask 077

SUCCESS=0
FAILS=0

for db in \
  mysql \
  records
do
  LATEST="${LATEST_DIR}/mysqldump-${db}-latest.sql"
  OUT="${ARC_DIR}/mysqldump-${db}-$(date "+%Y-%m-%dT%H:%M").sql"

  if /opt/ooce/bin/mysqldump \
	  --single-transaction \
	  -u$BACKUP_USER \
	  -p$BACKUP_PASSWORD \
	  $db >"$OUT"
  then
	  print "$(date) ${db}: successfully exported to $OUT"
	  (( SUCCESS = SUCCESS + 1 ))
  else
	  print "$(date) ${db}: FAILED TO EXPORT to $OUT"
	  (( FAILS = FAILS + 1 ))
  fi

  /opt/ooce/bin/wf write point -qE wavefront 'backup.db.exports' \
	  -T state=success "$SUCCESS"

  /opt/ooce/bin/wf write point -qE wavefront 'backup.db.exports' \
	  -T state=fail "$FAILS"

  /bin/cp -p "$OUT" "$LATEST"
done

find "$ARC_DIR" -type f -a -mtime +30 | while read -r file
do
  /bin/rm "$file"
done

exit $FAILS
