#!/bin/bash

BACKUP_SUBSCRIPTS_DIR=/etc/backups.d
BAK_DIR=/bak
CRONFILE=${BAK_DIR}/cronfile
INSTALLED_PKGS_LIST=${BAK_DIR}/installedPackages
PATHS_TO_BACKUP=${BAK_DIR}/pathsToBackup

crontab -l > ${CRONFILE}
aptitude search '~i .*' > \${INSTALLED_PKGS_LIST}

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
	tar czvf /bak/$(hostname).tgz -T ${PATHS_TO_BACKUP}
fi