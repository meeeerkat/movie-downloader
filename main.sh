#!/bin/sh


function usage {
        echo "Usage: $(basename $0) [-no]" 2>&1
        echo '   -n formattedName   to set the movie formated name'
        echo '   -o outputPath      to set the output file'
        exit 1
}

# Argument parsing & checking
if [[ $# -eq 0 ]]; then
   usage
fi

while getopts "n:o:" opt; do
    case $opt in
        n) NAME="$OPTARG" ;;
        o) OUTPUT_OPTION="-O $OPTARG" ;;
        \?)
            echo "Invalid option: -${OPTARG}."
            usage
            ;;
    esac
done

# The script is linked so the ressources around it should be taken with absolute path
# (Cause the link isn't near them)
baseDir=$(dirname $(realpath $0))

# Getting url
videoUrlOrError=`node ${baseDir}/main.js $NAME`

# Checking movie existance
if [ $? -eq 1 ]; then
    echo $videoUrlOrError
    exit $?
fi

# Downloading it
wget $videoUrlOrError $OUTPUT_OPTION


