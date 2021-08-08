
# Movie downloader 
A 1080p movie url getter using https://www.fmovies.top/ HD player  
The entry point is the main.sh script (call main.sh and not another file)  
Uses wget to download movies & series when the -o option is given  

## Formatted name
To find the right name you must go to this website and use their search (search from this tool hasn't been implemented yet).  
The name you're looking for is the last part of the url: https://www.fmovies.top/movies/movie-name/  
Usually, it's the movie's name without "and" and where the spaces are replaced by '-'  
Some examples:
- Fight club => fight-club
- Thelma and Louise => thelma-louise
- The World's End => the-worlds-end

## Downloading movies example
./main -o fight-club.mp4 fight-club  

## Important
Downloading multiple files in parallel may fail & **not using the -d option can throw the same error (the url getting part gets timeouted)**.  
The upload rate on each ressource may be slow which is why a large number of parallel processes is so great but the ressources' source only accepts 5-6 connexions at once and returns a HTTP 503 error for any other request, limiting the number of concurrent requests to less than 6 is necessary for a smooth download.  
One can try to download more than 6 files simutaneously (and this will be faster) but some files may get errors and never be downloaded (so each file will have to be specifically downloaded by the user).  

## Tv series
TV Series support is somewhat implemented  
Need to use -s option and bash ranges  
In the output name, %index is replaced with the index of the url in the url list  
Example: to get the urls of all the episode of the first season of scrubs  
./main.sh -sp -o scrubs/S%season/%episode.mp4 scrubs/01-{01..25}  
Or to get all the episodes:  
./main.sh -sp -o scrubs/S%season/%episode.mp4 scrubs/{01..07}-{01..25}  
Seasons & episodes numbers MUST be 2 digit long (add 0 before 1 digit numbers)  
If the number of episodes is unknown, just put a big one (ex: 99), it will stop at the first that doesn't work.  
Getting a download url for each episodes & then downloading them may not work because by the time the first episodes are downloaded, the tokens for the others (contained in the links) become outdated. Hence, the -o option is strongly recommanded for the downloading of many ressources at once (generates a link for a ressource & download it right away before generating the link for the next ressource).  

## Todo
Fix parallel execution (some ressources are not downloaded):  
- Handle video\_url\_getter errors & retries  
Add an option so that downloads are not stopped when an entry isn't available  
Add a search function  
