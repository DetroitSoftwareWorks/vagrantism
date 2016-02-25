#!/bin/bash

BACKUP_SCRIPT=/usr/local/bin/runBackup.sh
PATHS_TO_BACKUP=/bak/pathsToBackup
CRONFILE=cronfile

(
cat <<-XXXEOFXXX
	#!/bin/bash

	# This should be kept as last step
	if [ -e ${PATHS_TO_BACKUP} ]
	then
		tar czvf /bak/$(hostname).tgz -T ${PATHS_TO_BACKUP} ${PATHS_TO_BACKUP}
	fi
XXXEOFXXX
) > ${BACKUP_SCRIPT}

chmod u+x ${BACKUP_SCRIPT}


crontab -l -u root > ${CRONFILE}

# Setup backups
LINES_LIST=("${BACKUP_SCRIPT}")

for I in "${LINES_LIST[@]}"
do
	grep -qs "${I}" "${CRONFILE}"
	GREP_RESULT=$?	# grep command returns 0 (true) if line exists in cron
	echo ${GREP_RESULT}
	if [ ${GREP_RESULT} -eq 0 ] 
	then 
		echo "${I} already invoked in root's cron--no action taken"
	else
		echo -e "0 2 * * *	${I}" >> ${CRONFILE}
	fi
done

echo -e "\nDisplaying root's crontab\n"
cat ${CRONFILE}

crontab -u root ${CRONFILE}
rm -Rf ${CRONFILE}
