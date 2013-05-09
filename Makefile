BROWSERIFY=node_modules/.bin/browserify
SRC=src/popup.coffee src/ui.coffee src/passwdgen.coffee src/standalone.coffee src/popup.coffee

all: bundle

bundle:
	cake build
	$(BROWSERIFY) js/popup.js -o Chrome/js/popup-bundle.js
	$(BROWSERIFY) js/standalone.js -o js/standalone-bundle.js
