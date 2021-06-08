#!/bin/sh


if [ "$#" -ne 1 ]; then
    echo "Usage: $0 formatedMovieName" >&2
    exit 1
fi

videoUrl=`node main.js $1`
wget $videoUrl


