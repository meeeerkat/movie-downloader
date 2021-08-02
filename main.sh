#!/bin/sh



# The script is linked so the ressources around it should be taken with absolute path
# (Cause the link isn't near them)
BASE_DIR=$(dirname $(realpath $0))
VIDEO_URL_GETTER_SCRIPT_PATH="${BASE_DIR}/main.js"


function handle_ressource {
    url="$1"
    output_filename="$2"

    contentUrlOrError=`node $VIDEO_URL_GETTER_SCRIPT_PATH $url $URL_GETTER_IS_HEADLESS 2> /dev/null`
    if [[ $? -ne 0 ]]; then
        echo $contentUrlOrError
    else
        if [[ ! "$OUTPUT_FORMAT" ]]; then
            echo $contentUrlOrError
        else
            if ! wget $contentUrlOrError -c -O $output_filename; then
                echo "Download of $output_filename failed"
                return -1
            fi
        fi
    fi

    return 0
}

function get_season_nb {
    echo "$1" | sed -n 's/.\+\/\([[:digit:]]\+\)-\([[:digit:]]\+\)/\1/p'
}
function get_episode_nb {
    echo "$1" | sed -n 's/.\+\/\([[:digit:]]\+\)-\([[:digit:]]\+\)/\2/p'
}

function usage {
        echo "Usage: $(basename $0) [OPTIONS] FORMATTED-NAME..." 2>&1
        echo '  -s                  FORMATTED-NAME(s) refers to a serie episode'
        echo '  -p                  parallel mode'
        echo '  -o                  output name: 
                                        %index -> index in args
                                        %episode -> episode number (-s only)
                                        %season -> season number (-s only)'
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
IS_SERIE=0
IS_PARALLEL=0
OUTPUT_FORMAT=""
URL_GETTER_IS_HEADLESS=1
while getopts "spo:dh" opt; do
    case $opt in
        s) IS_SERIE=1 ;;
        p) IS_PARALLEL=1 ;;
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

i=1
while test $# -gt 0; do
    url=`makeUrl $1 $IS_SERIE`
    output_filename=`echo "$OUTPUT_FORMAT"`

    # Setting the variables
    output_filename=`echo "$output_filename" | sed -e "s/%index/$i/g"`
    if [[ "$IS_SERIE" -eq 1 ]]; then
        season_nb=`get_season_nb $1`
        episode_nb=`get_episode_nb $1`
        output_filename=`echo "$output_filename" | sed -e "s/%season/$season_nb/g"`
        output_filename=`echo "$output_filename" | sed -e "s/%episode/$episode_nb/g"`
    fi

    if [[ "$IS_PARALLEL" -eq 1 ]]; then
        handle_ressource "$url" "$output_filename" &
    else
        handle_ressource "$url" "$output_filename"
    fi

    shift
    i=$((i+1))
done

wait
