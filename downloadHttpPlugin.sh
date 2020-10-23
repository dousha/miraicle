#!/bin/sh

curl -s https://api.github.com/repos/project-mirai/mirai-api-http/releases/latest \
| grep download_url \
| awk '{print $2}' \
| tr -d \" \
| xargs wget -O mirai-api-http.jar

