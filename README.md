xe-scraper
==========

A [Puppeteer](https://github.com/GoogleChrome/puppeteer) script to scrape currency conversion data from [xe](https://www.xe.com/).

### How to use

- Install Puppeteer

```
npm i puppeteer
```

- Change path of Chrome/Chromium in `xe-scraper.js`

- Run command to fetch data

```
node xe-scraper.js <fromCurrency> <toCurrency> <Amount>
```

Example: 100 EUR = ?USD

```
node xe-scraper.js eur usd 100
```
