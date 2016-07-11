#!/bin/bash

AWS='/usr/bin/aws'
BUCKET='backupbotv1'

. /backupbotCredentials.sh

BACKUP_SUBSCRIPTS_DIR='/etc/backups.d'
BAK_DIR='/bak'
CRONFILE="${BAK_DIR}/cronfile"
INSTALLED_PKGS_LIST="${BAK_DIR}/installedPackages"
PATHS_TO_BACKUP="${BAK_DIR}/pathsToBackup"
PATH_TO_FILE="${BAK_DIR}/$(hostname).tgz"
FILENAME="$(basename ${PATH_TO_FILE})"

/usr/bin/crontab -l > "${CRONFILE}"
/usr/bin/aptitude search '~i .*' > "${INSTALLED_PKGS_LIST}"

# Run scripts in /etc/backups.d
for SCRIPT in ${BACKUP_SUBSCRIPTS_DIR}/*
do
	echo ${SCRIPT}
	chmod u+x ${SCRIPT}
	${SCRIPT}
	chmod u-x ${SCRIPT}
done

# This should be kept as last step
if [ -e ${PATHS_TO_BACKUP} ]
then
	/bin/tar czvf ${PATH_TO_FILE} -T ${PATHS_TO_BACKUP}
	ETAG="ETAG"
	MD5="MD5"
	MD5_SUCCESS="SUCCESS"
	until [  "${MD5_SUCCESS}" == '0' ]; 
	do
		${AWS} s3 cp ${PATH_TO_FILE} s3://${BUCKET}/${FILENAME}
		ETAG=$(${AWS} s3api head-object --bucket "${BUCKET}" --key "${FILENAME}" | grep ETag | sed -e 's/^.*ETag\": \"\\\"//g' | sed -e 's/\\\"\",.*//g')
		/bin/echo "${ETAG}  ${PATH_TO_FILE}" > /tmp/ETAG
		/usr/bin/md5sum --status -c /tmp/ETAG
		MD5_SUCCESS="${?}"
	done
fi
