#!/bin/sh


if [ "$#" -ne 2 ]; then
    echo "Usage: $0 formatedMovieName outputFile" >&2
    exit 1
fi

videoUrlOrError=`node main.js $1`

if [ $? ]; then
    echo $videoUrlOrError
    exit $?
fi

wget $videoUrl -O $2


