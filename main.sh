#!/bin/sh



# The script is linked so the ressources around it should be taken with absolute path
# (Cause the link isn't near them)
BASE_DIR=$(dirname $(realpath $0))
VIDEO_URL_GETTER_SCRIPT_PATH="${BASE_DIR}/main.js"


function usage {
        echo "Usage: $(basename $0) [OPTIONS] FORMATTED-NAME..." 2>&1
        echo '  -s                  FORMATTED-NAME(s) refers to a serie episode'
        echo '  -o                  output name, can get the current url index by using %index'
        echo '  -d                  debug mode (headless=false)'
        exit 1
}

function makeUrl {
    if [[ "$2" -eq 0 ]]; then
        echo "https://123moviesplayer.com/movie/$1?src=mirror2"
    else
        echo "https://123moviesplayer.com/show/$1?src=mirror2"
    fi
}

# Argument parsing & checking
if [[ $# -eq 0 ]]; then
   usage
fi

# Params default value
URL_GETTER_IS_HEADLESS=1
IS_SERIE=0
OUTPUT_FORMAT=""
while getopts "so:dh" opt; do
    case $opt in
        s) IS_SERIE=1 ;;
        d) URL_GETTER_IS_HEADLESS=0 ;;
        o) OUTPUT_FORMAT="$OPTARG" ;;
        h) usage ;;
        \?)
            echo "Invalid option: -${OPTARG}."
            usage
            ;;
    esac
done

shift $((OPTIND-1))

i=0
while test $# -gt 0; do
    url=`makeUrl $1 $IS_SERIE`
    output_filename=`echo "$OUTPUT_FORMAT" | sed -e "s/%index/$i/g"`

    contentUrlOrError=`node $VIDEO_URL_GETTER_SCRIPT_PATH $url $URL_GETTER_IS_HEADLESS 2> /dev/null`
    if [[ ! "$OUTPUT_FORMAT" ]]; then
        echo $contentUrlOrError
    else
        if ! wget $contentUrlOrError -O $output_filename; then
            echo "Download of $output_filename failed"
            exit -1
        fi
    fi

    shift
    i=$((i+1))
done

