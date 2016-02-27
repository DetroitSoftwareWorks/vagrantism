#!/bin/bash

BACKUP_SCRIPT=/usr/local/bin/runBackup.sh
PATHS_TO_BACKUP=/bak/pathsToBackup
CRONFILE=cronfile
INSTALLED_PKGS_LIST=/bak/installedPackages
TMP_CRONFILE=cronfile

# 1 - HERE doc for ${BACKUP_SCRIPT}
# cp /bak/runBackup.sh /usr/local/bin/
(
cat <<-XXXEOFXXX
	#!/bin/bash

	crontab -l > /bak/cronfile
	aptitude search '~i .*' > ${INSTALLED_PKGS_LIST}

	# Run scripts in /etc/backups.d
	for SCRIPT in /etc/backups.d/*
	do
	    echo \${SCRIPT}
	    \${SCRIPT}
	done

	# This should be kept as last step
	if [ -e ${PATHS_TO_BACKUP} ]
	then
	    tar czvf /bak/$(hostname).tgz -T ${PATHS_TO_BACKUP} ${PATHS_TO_BACKUP}
	fi
XXXEOFXXX
) > ${BACKUP_SCRIPT}
chmod u+x ${BACKUP_SCRIPT}

mkdir -p /etc/backups.d

# Add ${BACKUP_SCRIPT} to the list of files to backup
if [ ! $(grep ^${BACKUP_SCRIPT}$ ${PATHS_TO_BACKUP}) ]
then
	echo "${BACKUP_SCRIPT}" >> ${PATHS_TO_BACKUP}
fi

# Setup a crontab for calling ${BACKUP_SCRIPT}
crontab -l -u root > ${TMP_CRONFILE}

if [ ! $(grep "^0 2 \* \* \*	${BACKUP_SCRIPT}$" ${TMP_CRONFILE}) ]
then
	echo "0 2 * * *	${BACKUP_SCRIPT}" >> ${TMP_CRONFILE}
fi
crontab -u root ${TMP_CRONFILE}
rm -Rf ${TMP_CRONFILE}
