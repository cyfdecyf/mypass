BROWSERIFY=node_modules/.bin/browserify
SRC=src/popup.coffee src/ui.coffee src/passwdgen.coffee src/standalone.coffee src/popup.coffee

all: bundle

bundle:
	cake build
	$(BROWSERIFY) build/popup.js -o Chrome/js/popup-bundle.js
	$(BROWSERIFY) build/options.js -o Chrome/js/options-bundle.js
	$(BROWSERIFY) build/standalone.js -o html/js/standalone-bundle.js
	$(BROWSERIFY) build/ios.js -o html/js/ios-bundle.js

clean:
	rm -rf build
