#!/bin/sh


function usage {
        echo "Usage: $(basename $0) [-no]" 2>&1
        echo '  -n formattedName    to set the movie formated name'
        echo '  -o outputPath       to set the output file (not using this option will echo the download url)'
        echo '  -d                  debug mode (headless=false)'
        exit 1
}

# Argument parsing & checking
if [[ $# -eq 0 ]]; then
   usage
fi

# Params default value
URL_GETTER_IS_HEADLESS=1
while getopts "n:o:dh" opt; do
    case $opt in
        n) NAME="$OPTARG" ;;
        o) OUTPUT_OPTION="-O $OPTARG" ;;
        d) URL_GETTER_IS_HEADLESS=0 ;;
        h) usage ;;
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
videoUrlOrError=`node ${baseDir}/main.js $NAME $URL_GETTER_IS_HEADLESS 2> /dev/null`

# Checking movie existance
if [ $? -eq 1 ]; then
    echo $videoUrlOrError
    exit $?
fi

if [ "$OUTPUT_OPTION" ]; then
    # Downloading it
    wget $videoUrlOrError $OUTPUT_OPTION
else
    echo $videoUrlOrError
fi


