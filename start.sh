#!/bin/bash

mkdir -p config/Console
touch config/Console/AutoLogin.yml
if [ -z "${USER}" ]; then
	echo "Manual configuration"
else
	echo << EOF > config/Console/AutoLogin.yml
plainPasswords:
  ${USER}: ${PASS}
EOF
fi

if [ ! -f "device.json" ]; then
	echo "No device.json found in /"
	echo "You may have to run verification first"
fi

./mcl

