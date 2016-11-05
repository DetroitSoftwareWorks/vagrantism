#!/bin/sh

if [[ $# != 1 ]]
then
    echo "You need one argument: the path to your downstream ansbile playbooks."
    exit
fi

TARGET_DIR="$1"
MAIN_DIR=$(dirname "$0")

if [[ ! -e "${TARGET_DIR}/site.yml" ]]
then
    cp "${MAIN_DIR}/site.yml" "${TARGET_DIR}/site.yml"
else
    echo "File exists ($(ls "${TARGET_DIR}/site.yml")), did not overwrite."
fi

for ELEM in $(ls "${MAIN_DIR}")
do
    if [[ -d "${MAIN_DIR}/${ELEM}" ]]
    then
        if [[ -e "${TARGET_DIR}/${ELEM}" ]]
        then
            echo "Old ${ELEM}: $(ls -d ${TARGET_DIR}/${ELEM})"
        else
            ln -s "$(pwd)/${MAIN_DIR}/${ELEM}" "${TARGET_DIR}/${ELEM}"
        fi
    fi
done
