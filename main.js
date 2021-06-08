
const videoUrlGetter = require("./videoUrlGetter.js");

async function main(formattedName, isHeadless) {
    videoUrlGetter.getVideoUrl(formattedName, isHeadless)
        .then(videoUrl => console.log(videoUrl))
        .catch(e => {
            console.log(e);
            process.exit(1);
        })
}

main(process.argv[2], process.argv[3] == '1');

