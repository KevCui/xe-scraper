const puppeteer = require('puppeteer');

(async () => {
    const chrome = '/usr/bin/chromium'
    const isheadless = true
    const FROM = process.argv[2]
    const TO = process.argv[3]
    const AMOUNT = process.argv[4]
    const URL= 'https://www.xe.com/currencyconverter/convert/?Amount=' + AMOUNT + '&From=' + FROM + '&To=' + TO
    const SELECTOR = '.converterresult-conversionWrap';

    const browser = await puppeteer.launch({executablePath: chrome, headless: isheadless});
    const page = await browser.newPage();

    await page.goto(URL, {timeout: 60000, waitUntil: 'domcontentloaded'});
    await page.waitForSelector(SELECTOR)

    const data = await page.evaluate(() => {
        return {
            toAmount: document.querySelector('.converterresult-toAmount').textContent,
            toCurrency: document.querySelector('.converterresult-toCurrency').textContent
        };
    });
    console.log(AMOUNT + ' ' + FROM.toUpperCase() + ' = ' + data.toAmount + ' ' + data.toCurrency);

    await browser.close();
})();
