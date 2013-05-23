**MyPass** is a tool to generate *different passwords for different sites* with a given passphrase. It uses the same algorithm with [One Shall Pass](https://oneshallpass.com/) (1SP). You can specify options like password length, number of symbols, etc.

MyPass is implemented as:

- [Chrome extension](https://chrome.google.com/webstore/detail/pbaehcadchmngjeahmifjonliaaidgdj)
  - This is the easiest way to use MyPass
- [Standalone web page](http://chenyufei.info/p/mypass/)
  - Use this when you don't have access to your own Chrome
- [iOS optimized web page](http://chenyufei.info/p/mypass/ios.html)
  - Add this to home screen so you can use it (even when offline) on your iOS device

# Technical information

## About the options

- **Symbols**: how many symbol characters should be included in the generated password
- **Length**: generated password length
  - Generally better to choose longer password, just ensure it's not exceeding the password length limit of a site
- **Generation**: in case you need to generate a new password for a site, you can simply increase the generation
- **Hashes**: use how many hash iteration to generate a key
  - More iteration requires more time to generate password. The benefit is that it's even more difficult to crack your passphrase if someone get your generated password

## About choosing a passphrase

For differences between passwords and passphrases, refer to Jeff Artwood's article [Passwords vs. Pass Phrases](http://www.codinghorror.com/blog/2005/07/passwords-vs-pass-phrases.html).

Generally, choose a passphrase that's long (at least around 20 characters), easy to remember by yourself, hard to guess by others. Including capitalization, punctuation and numbers in your passphrase would be even better.

**Your passphrase is never stored anywhere by MyPass.** That's why you need to type it every time you use MyPass.

## How is the password generated

The password generation algorithm is the same as 1SP. Basically, a
512-bit key is generated using PBKDF2 from your passphrase, using your
email as the salt. That key is then used in HMAC-SHA512 to generate
password for each site. For the detailed algorithm and how secure it is, please refer to 1SP's [README](https://github.com/maxtaco/oneshallpass/blob/master/README.md).

## How are site options stored?

- Chrome extension: stored in `chrome.storage.sync`, will be synchronized by Chrome
- Standalone web page: **NOT** saved
- iOS web page: stored in local storage

MyPass itself does **NOT encrypt** site options when storing to either `chrome.sync.storage` or local storage and please let me explain why in a moment. For Chrome extension users, I *recommend* setting Chrome to encrypt all synced data and thus have your site options encrypted. (You need to manually set this in "Advanced sync options" in Chrome and use a *separate* passphrase.)

If someone get your site options data either by breaking into your computer or Google's cloud storage,

- If it's **NOT encrypted**, then he knows your password options which seems bad. But **this information provides little help if he wants to use brute force to guess your password** for *every* different site, and it **provides no help in guessing you passphrase**.
  - Of course, a long enough password (say more than 12 chars) is required to ensure safety
  - He can use brute force to guess passwords even if he has no options data
  - User name is usually your identity, it's not a secret in most cases
- If it's **encrypted using some key generated from your passphrase**, because he now gets the encrypted data, **he can brute force to guess your passphrase by trying to decrypt the data**. (Though this would be expensive, it's possible.) Once he succeeds to know the passphrase, you are in bad luck.

So encrypting site options by passphrase generated keys actually has more serious security risk, that's why I choose not to encrypt site options.

# Build

You need [Node.js](http://nodejs.org/) installed and file systems that supports symbolic links. Build in the project root directory:

    # Install dependencies
    npm install
    # Compile CoffeeScript source and create bundle with browserify
    make

## Customize Bootstrap

To reduce the amount of CSS/JavaScript to be included, I [customized bootstrap](http://twitter.github.io/bootstrap/customize.html) with only the following items selected:

- Components
  - Scaffolding
      - Body type and links
      - Layouts
  - Base CSS
      - Headings, body, etc
      - Tables
      - Forms
      - Buttons
  - JS Components
      - Dropdowns
- jQuery plugins
  - Typeahead

I also removed invalid input CSS so they don't look abrupt on iOS.

# Credits

The password generation code is mostly copied from 1SP.

Icon designed by @naruil.
