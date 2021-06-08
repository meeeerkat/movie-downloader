
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
    return await puppeteer.launch({ args: browserArgs, headless: true }).then(async browser => {
        // Loading page
        const page = await browser.newPage();
        await page.goto(util.format(playerUrlFormat, formatedName), { waitUntil: 'domcontentloaded' });
        await page.screenshot({ path: '1.png', fullPage: true })

        // Going to player (inside an iframe)
        const playerIframeUrl = await page.waitForSelector("#openloadIframe").then(async iframe => await (await iframe.getProperty('src')).jsonValue());
        await page.goto(playerIframeUrl, { waitUntil: 'networkidle2' });
        await page.screenshot({ path: '2.png', fullPage: true })

        // Launching the movie
        await page.waitForSelector(".jwpreview.jwuniform").then(async button => await button.click());
        await page.screenshot({ path: '3.png', fullPage: true })

        // Getting the movie's url
        const videoUrl = await page.waitForSelector(".jwmain .jwvideo video").then(async video => await (await video.getProperty('src')).jsonValue());
        await page.screenshot({ path: '4.png', fullPage: true })

        browser.close();
        return videoUrl;
    });

}

module.exports = { getVideoUrl };


