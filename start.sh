#!/bin/bash

if [ ! -z ${MIRAI_QQ} ]; then
# Emit auto login file
    mkdir -p plugins/Console
    if [ ! -z ${MIRAI_PASSWORD} ]; then
        cat > plguins/Console/AutoLogin.yml << EOF
plainPasswords:
  ${MIRAI_QQ}: ${MIRAI_PASSWORD}
EOF
    fi
    if [ ! -z ${MIRAI_MD5_PASSWORD} ]; then
        cat > plugins/Console/AutoLogin.yml << EOF
md5Passwords:
  ${MIRAI_QQ}: ${MIRAI_MD5_PASSWORD}
EOF
    fi
fi

./mcl $*

