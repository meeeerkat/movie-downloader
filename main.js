
const videoUrlGetter = require("./videoUrlGetter.js");

async function main() {
    videoUrlGetter.getVideoUrl(process.argv[2])
        .then(videoUrl => console.log(videoUrl))
        .catch(e => {
            console.log(e);
            process.exit(1);
        })
}

main()

