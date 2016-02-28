#!/bin/bash

BACKUP_SCRIPT=/usr/local/bin/runBackup.sh
BACKUP_SUBSCRIPTS_DIR=/etc/backups.d
CRONFILE=/bak/cronfile
INSTALLED_PKGS_LIST=/bak/installedPackages
PATHS_TO_BACKUP=/bak/pathsToBackup
TMP_CRONFILE=cronfile

# 1 - HERE doc for ${BACKUP_SCRIPT}
# cp /bak/runBackup.sh /usr/local/bin/
(
cat <<-XXXEOFXXX
	#!/bin/bash

	BACKUP_SCRIPT=${BACKUP_SCRIPT}
	BACKUP_SUBSCRIPTS_DIR=${BACKUP_SUBSCRIPTS_DIR}
	CRONFILE=${CRONFILE}
	INSTALLED_PKGS_LIST=${INSTALLED_PKGS_LIST}
	PATHS_TO_BACKUP=${PATHS_TO_BACKUP}

	crontab -l > \${CRONFILE}
	aptitude search '~i .*' > \${INSTALLED_PKGS_LIST}

	# Run scripts in /etc/backups.d
	for SCRIPT in \${BACKUP_SUBSCRIPTS_DIR}/*
	do
	    echo \${SCRIPT}
	    chmod u+x \${SCRIPT}
	    \${SCRIPT}
	    chmod u-x \${SCRIPT}
	done

	# This should be kept as last step
	if [ -e \${PATHS_TO_BACKUP} ]
	then
	    tar czvf /bak/$(hostname).tgz -T \${PATHS_TO_BACKUP}
	fi
XXXEOFXXX
) > ${BACKUP_SCRIPT}
chmod u+x ${BACKUP_SCRIPT}

mkdir -p ${BACKUP_SUBSCRIPTS_DIR}

# Add ${BACKUP_SCRIPT} to the list of files to backup
# if [ ! $(grep ^${BACKUP_SCRIPT}$ ${PATHS_TO_BACKUP}) ]
# then
# 	echo "${BACKUP_SCRIPT}" >> ${PATHS_TO_BACKUP}
# fi
BACKUP_PATHS=( ${PATHS_TO_BACKUP} ${BACKUP_SCRIPT} ${CRONFILE} ${INSTALLED_PKGS_LIST} ${BACKUP_SUBSCRIPTS_DIR} )

touch ${PATHS_TO_BACKUP}

# Add ${BACKUP_PATHS} to the list of files to backup
for BACKUP_PATH in ${BACKUP_PATHS[*]}
do
	if [ ! $(grep ^${BACKUP_PATH}$ ${PATHS_TO_BACKUP}) ]
	then
		echo "${BACKUP_PATH}" >> ${PATHS_TO_BACKUP}
	fi
done


# Setup a crontab for calling ${BACKUP_SCRIPT}
crontab -l -u root > ${TMP_CRONFILE}
touch ${TMP_CRONFILE}

if [ ! $(grep "^0 2 \* \* \*	${BACKUP_SCRIPT}$" ${TMP_CRONFILE}) ]
then
	echo "0 2 * * *	${BACKUP_SCRIPT}" >> ${TMP_CRONFILE}
fi
crontab -u root ${TMP_CRONFILE}
rm -Rf ${TMP_CRONFILE}
