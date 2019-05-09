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
S3_PATH="s3://${BUCKET}/$(hostname)"

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
	sh -c 'umask 0077 ; /bin/tar czvf '"${PATH_TO_FILE}"' \
		--preserve-permissions \
		-T '${PATHS_TO_BACKUP}
		
	if [ -e /backupbotCredentials.sh ]
	then
		. /backupbotCredentials.sh

		until [ "${UPLOAD_STATUS}" == '0' ]
		do
			echo "Uploading ${PATH_TO_FILE} to ${S3_PATH}/${FILENAME}"
			"${AWS}" s3 cp --region "us-west-1" "${PATH_TO_FILE}" "${S3_PATH}/${FILENAME}"
			UPLOAD_STATUS="$?"
		done
	
		echo "Datestamped file uploaded to S3"
		UPLOAD_STATUS='1'
	
		until [ "${UPLOAD_STATUS}" == '0' ]
		do
			"${AWS}" s3 cp --region "us-west-1" "${PATH_TO_FILE}" "${S3_PATH}/latest.tgz"
			UPLOAD_STATUS="$?"
		done
	
		echo "Latest file uploaded to S3"
	
		rm -f "${PATH_TO_FILE}"
	fi
fi
