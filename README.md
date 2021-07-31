
# Movie url getter
A 1080p movie url getter using https://www.fmovies.top/ HD player  
The entry point is the main.sh script (call main.sh and not another file)  
To use with wget to download movies  
TV Series support isn't implemented yet  

## Formatted name
To find the right name you must go to this website and use their search (search from this tool hasn't been implemented yet).  
The name you're looking for is the last part of the url: https://www.fmovies.top/movies/movie-name/  
Usually, it's the movie's name without "and" and where the spaces are replaced by '-'  
Some examples:
- Fight club => fight-club
- Thelma and Louise => thelma-louise
- The World's End => the-worlds-end

# Downloading movies example
With wget:  
wget `movie-url-getter -n fight-club` -O fight-club.mp4  

# Todo
Add a research function  
Add tv serie downloading support
