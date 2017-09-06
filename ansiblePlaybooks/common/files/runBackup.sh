#!/bin/bash

AWS='/usr/bin/aws'
BUCKET='backupbotv1'

BACKUP_SUBSCRIPTS_DIR='/etc/backups.d'
BAK_DIR='/bak'
CRONFILE="${BAK_DIR}/cronfile"
INSTALLED_PKGS_LIST="${BAK_DIR}/installedPackages"
PATHS_TO_BACKUP="${BAK_DIR}/pathsToBackup"
FILENAME="$(/bin/date '+%Y%m%d%H%M%S').tgz"
PATH_TO_FILE="${BAK_DIR}/$(hostname).tgz"

/usr/bin/crontab -l > "${CRONFILE}"
/usr/bin/aptitude search '~i .*' > "${INSTALLED_PKGS_LIST}"

# Run scripts in /etc/backups.d
for SCRIPT in ${BACKUP_SUBSCRIPTS_DIR}/*
do
	if [ -e ${SCRIPT} ]
	then
		echo ${SCRIPT}
		chmod u+x ${SCRIPT}
		${SCRIPT}
		chmod u-x ${SCRIPT}
	fi
done

# This should be kept as last step
if [ -e ${PATHS_TO_BACKUP} ]
then
	/bin/tar czvf ${PATH_TO_FILE} -T ${PATHS_TO_BACKUP}
	. /backupbotCredentials.sh
	ETAG="ETAG"
	MD5="MD5"
	MD5_STATUS="SUCCESS"
	until [  "${MD5_STATUS}" == '0' ]; 
	do
		"${AWS}" s3 cp "${PATH_TO_FILE}" "s3://${BUCKET}/$(hostname)/${FILENAME}"
		UPLOAD_STATUS="$?"
		if [ "${UPLOAD_STATUS}" == '0' ]
		then
			ETAG=$(${AWS} s3api head-object --bucket "${BUCKET}" --key "$(hostname)/${FILENAME}" | grep ETag | sed -e 's/^.*ETag\": \"\\\"//g' | sed -e 's/\\\"\",.*//g')
			/bin/echo "${ETAG}  ${PATH_TO_FILE}" > /tmp/ETAG
			/usr/bin/md5sum --status -c /tmp/ETAG
			MD5_STATUS="${?}"
		else
			echo "Upload failed"
			exit -1
		fi
	done
	rm -f "${PATH_TO_FILE}"
fi
