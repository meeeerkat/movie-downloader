
const videoUrlGetter = require("./videoUrlGetter.js");
videoUrlGetter.getVideoUrl(process.argv[2]).then(videoUrl => console.log(videoUrl));


