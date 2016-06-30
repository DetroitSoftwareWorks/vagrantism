#!/bin/bash

PYTHON_REQUIRED_VERSION='Python 2.7.11+'

echo "Checking aptitude"
command -v aptitude || sudo apt install -y aptitude

# install python 2
echo "Checking python version, "
DEFAULT_CURRENT_PYTHON_VERSION=$(python --version 2>&1)
if [ "${DEFAULT_CURRENT_PYTHON_VERSION}" != "${PYTHON_REQUIRED_VERSION}" ]
then
	echo "Installing python via aptitude, since we only have ${DEFAULT_CURRENT_PYTHON_VERSION}"
	aptitude install -y python
else
	echo "Don't need to install python 2.7"
fi