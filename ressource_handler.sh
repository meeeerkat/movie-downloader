#!/bin/sh


# The script is linked so the ressources around it should be taken with absolute path
# (Cause the link isn't near them)
BASE_DIR=$(dirname $(realpath $0))
VIDEO_URL_GETTER_SCRIPT_PATH="${BASE_DIR}/main.js"


IS_HEADLESS="$1"
URL="$2"
OUTPUT_FILENAME="$3"

ressource_url=`node $VIDEO_URL_GETTER_SCRIPT_PATH $URL $IS_HEADLESS 2> /dev/null`
exit_code=$?
while [[ $exit_code -lt 0 ]]; do
    ressource_url=`node $VIDEO_URL_GETTER_SCRIPT_PATH $URL $IS_HEADLESS 2> /dev/null`
    exit_code=$?
done 

if [[ $exit_code -ne 0 ]]; then
    exit $exit_code
fi

if [[ ! "$OUTPUT_FILENAME" ]]; then
    echo "$ressource_url"
else
    if ! wget "$ressource_url" -c -O $OUTPUT_FILENAME; then
        echo "Download of $OUTPUT_FILENAME failed"
        exit -1
    fi
fi

