#!/bin/sh


function usage {
        echo "Usage: $(basename $0) [OPTIONS] FORMATTED-NAME..." 2>&1
        echo '  -d                  debug mode (headless=false)'
        exit 1
}

# Argument parsing & checking
if [[ $# -eq 0 ]]; then
   usage
fi

# Params default value
URL_GETTER_IS_HEADLESS=1
while getopts "dh" opt; do
    case $opt in
        d) URL_GETTER_IS_HEADLESS=0 ;;
        h) usage ;;
        \?)
            echo "Invalid option: -${OPTARG}."
            usage
            ;;
    esac
done

shift $((OPTIND-1))

# The script is linked so the ressources around it should be taken with absolute path
# (Cause the link isn't near them)
baseDir=$(dirname $(realpath $0))
jsScriptPath="${baseDir}/main.js"

while test $# -gt 0; do
    # Getting url
    contentUrlOrError=`node $jsScriptPath $1 $URL_GETTER_IS_HEADLESS 2> /dev/null`
    echo $contentUrlOrError
    shift
done

