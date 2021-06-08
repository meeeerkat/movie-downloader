#!/bin/sh


if [ "$#" -ne 2 ]; then
    echo "Usage: $0 formatedMovieName outputFile" >&2
    exit 1
fi

videoUrl=`node main.js $1`
wget $videoUrl -O $2


