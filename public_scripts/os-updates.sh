#!/bin/bash

# Set up timezone
mv /etc/timezone /etc/timezone.orig
echo "America/Detroit" > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# Set up the ${EDITOR} VAR
PROFILE_SCRIPT=/etc/profile.d/editor.sh

if [ ! -e ${PROFILE_SCRIPT} ]
then
(
cat <<-XXXEOFXXX
		#!/bin/sh

		export EDITOR=/usr/bin/vi
XXXEOFXXX
) > ${PROFILE_SCRIPT}
fi
