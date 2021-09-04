
const videoUrlGetter = require("./video_url_getter.js");

async function main(url, isHeadless) {
    videoUrlGetter.getVideoUrl(url, isHeadless)
        .then(videoUrl => console.log(videoUrl))
        .catch(e => {
            console.log(e);
            process.exit(1);
        })
}

main(process.argv[2], process.argv[3] == '1');

