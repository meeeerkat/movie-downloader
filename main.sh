#!/bin/sh

BASE_DIR=$(dirname $(realpath $0))
RESSOURCE_HANDLER_SCRIPT_PATH="${BASE_DIR}/ressource_handler.sh"



function usage {
        echo "Usage: $(basename $0) [OPTIONS] FORMATTED-NAME..." 2>&1
        echo '  -s                  FORMATTED-NAME(s) refers to a serie episode'
        echo '  -p process_nbs      parallel mode'
        echo '  -o                  output name: 
                                        %index -> index in args
                                        %episode -> episode number (-s only)
                                        %season -> season number (-s only)'
        echo '  -d                  debug mode (headless=false)'
        exit 1
}






## Arguments getting
if [[ $# -eq 0 ]]; then
   usage
fi

IS_SERIE=0
MAX_PARALLEL_PROCESSES_NB=1
OUTPUT_FORMAT=""
URL_GETTER_IS_HEADLESS=1
while getopts "sp:o:dh" opt; do
    case $opt in
        s) IS_SERIE=1 ;;
        p) MAX_PARALLEL_PROCESSES_NB="$OPTARG" ;;
        d) URL_GETTER_IS_HEADLESS=0 ;;
        o) OUTPUT_FORMAT="$OPTARG" ;;
        h) usage ;;
        \?)
            echo "Invalid option: -$OPTARG."
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

function make_url {
    if [[ $IS_SERIE -eq 0 ]]; then
        echo "https://123moviesplayer.com/movie/$1?src=mirror2"
    else
        echo "https://123moviesplayer.com/show/$1?src=mirror2"
    fi
}





## Actual code
args=""
i=1
while test $# -gt 0; do
    ressource_locator="$1"
    url=`make_url "$ressource_locator"`
    if [[ "$OUTPUT_FORMAT" ]]; then
        output_filename=`get_output_filename "$ressource_locator" $i`
        args="$args $URL_GETTER_IS_HEADLESS "$url" "$output_filename""
    else
        args="$args $URL_GETTER_IS_HEADLESS "$url""
    fi
    
    i=$(( $i+1 ))
    shift
done

max_args_nb=2
if [[ "$OUTPUT_FORMAT" ]]; then
    max_args_nb=$(( $max_args_nb+1 ))
fi

echo $args | xargs --max-args=$max_args_nb -P $MAX_PARALLEL_PROCESSES_NB $RESSOURCE_HANDLER_SCRIPT_PATH

