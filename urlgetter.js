


// Constants
const playerUrlFormat = 'https://123moviesplayer.com/movie/%s?src=mirror2';


// General helpers
const util = require('util');

// Setting up puppeteer
const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
puppeteer.use(StealthPlugin());

const AdblockerPlugin = require('puppeteer-extra-plugin-adblocker')
puppeteer.use(AdblockerPlugin({ blockTrackers: true }))

const browserArgs = [
    '--disable-features=site-per-process', // Necessary to work with an iframe
    '--start-maximized'
];


async function getVideoUrl(formatedName) {


    return await puppeteer.launch({ args: browserArgs, headless: false }).then(async browser => {
        // Loading page
        const page = await browser.newPage();
        await page.goto(util.format(playerUrlFormat, formatedName), { waitUntil: 'domcontentloaded' });

        // Going to player (inside an iframe)
        const playerIframeUrl = await page.waitForSelector("#openloadIframe").then(async iframe => await (await iframe.getProperty('src')).jsonValue());
        await page.goto(playerIframeUrl, { waitUntil: 'networkidle2' });

        // Launching the movie
        await page.waitForSelector(".jwpreview.jwuniform").then(async button => await button.click());

        // Getting the movie's url
        const videoUrl = await page.waitForSelector(".jwmain .jwvideo video").then(async video => await (await video.getProperty('src')).jsonValue());

        browser.close();
        return videoUrl;
    });

}

getVideoUrl('avatar').then(url => console.log(url));


