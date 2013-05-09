**MyPass** is a Chrome extension for [One Shall Pass](https://oneshallpass.com/) (1SP).

# Build

You need [Node.js](http://nodejs.org/) installed and file systems that supports symbolic links. Build in the project root directory:

    # Install dependencies
    npm install
    # Compile CoffeeScript source and create bundle with browserify
    make

# TODO

- Encrypt site options stored in `chrome.storage`

# Credits

The password generation code is mostly copied from 1SP.

Icon designed by @naruil.
