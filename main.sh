#!/bin/sh



# The script is linked so the ressources around it should be taken with absolute path
# (Cause the link isn't near them)
BASE_DIR=$(dirname $(realpath $0))
VIDEO_URL_GETTER_SCRIPT_PATH="${BASE_DIR}/main.js"


function usage {
        echo "Usage: $(basename $0) [OPTIONS] FORMATTED-NAME..." 2>&1
        echo '  -s                  FORMATTED-NAME(s) refers to a serie episode'
        echo '  -p                  parallel mode (downloading part only)'
        echo '  -o                  output name: 
                                        %index -> index in args
                                        %episode -> episode number (-s only)
                                        %season -> season number (-s only)'
        echo '  -d                  debug mode (headless=false)'
        exit 1
}

function download_ressource {
    ressource_url="$1"
    output_filename="$2"

    if ! wget "$ressource_url" -c -O $output_filename; then
        echo "Download of $output_filename failed"
        return -1
    fi
    
    return 0
}

function makeUrl {
    if [[ "$2" -eq 0 ]]; then
        echo "https://123moviesplayer.com/movie/$1?src=mirror2"
    else
        echo "https://123moviesplayer.com/show/$1?src=mirror2"
    fi
}




## Arguments getting
if [[ $# -eq 0 ]]; then
   usage
fi

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


## Functions using arguments (they are never modified, only read)
function get_season_nb {
    echo "$1" | sed -n 's/.\+\/\([[:digit:]]\+\)-\([[:digit:]]\+\)/\1/p'
}
function get_episode_nb {
    echo "$1" | sed -n 's/.\+\/\([[:digit:]]\+\)-\([[:digit:]]\+\)/\2/p'
}
function get_output_filename {
    ressource_locator="$1"
    index="$2"

    if [[ "$OUTPUT_FORMAT" ]]; then
        output_filename="$OUTPUT_FORMAT"
        # Setting the variables
        output_filename=`echo "$output_filename" | sed -e "s/%index/$index/g"`
        if [[ "$IS_SERIE" -eq 1 ]]; then
            season_nb=`get_season_nb $ressource_locator`
            episode_nb=`get_episode_nb $ressource_locator`
            output_filename=`echo "$output_filename" | sed -e "s/%season/$season_nb/g"`
            output_filename=`echo "$output_filename" | sed -e "s/%episode/$episode_nb/g"`
        fi
    else
        output_filename=""
    fi

    echo "$output_filename"
}

function handle_ressource {
    ressource_locator="$1"
    ressource_url="$2"
    index=$3

    if [[ ! "$OUTPUT_FORMAT" ]]; then
        echo "$ressource_url"
    else
        output_filename=`get_output_filename "$ressource_locator" $index`
        if [[ $IS_PARALLEL -eq 1 ]]; then
            download_ressource "$ressource_url" "$output_filename" &
        else
            download_ressource "$ressource_url" "$output_filename"
        fi
    fi
}


## Actual code
declare -a ressources_urls
declare -a ressources_locators 
i=1
while test $# -gt 0; do
    url=`makeUrl "$1" $IS_SERIE`

    ressources_locators[$i]="$1"
    ressources_urls[$i]=`node $VIDEO_URL_GETTER_SCRIPT_PATH $url $URL_GETTER_IS_HEADLESS 2> /dev/null`
    if [[ $? -ne 0 ]]; then
        # TODO: handle errors
        echo ERROR
    fi

    if [[ $IS_PARALLEL -eq 0 ]]; then
        handle_ressource "${ressources_locators[$i]}" "${ressources_urls[$i]}" $i
    fi
    
    i=$(( $i+1 ))
    shift
done


if [[ $IS_PARALLEL -eq 1 ]]; then
    for i in "${!ressources_locators[@]}"; do
        handle_ressource "${ressources_locators[$i]}" "${ressources_urls[$i]}" $i
    done

    wait
fi

