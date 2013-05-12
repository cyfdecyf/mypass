BROWSERIFY=node_modules/.bin/browserify
SRC=src/popup.coffee src/ui.coffee src/passwdgen.coffee src/standalone.coffee src/popup.coffee

all: bundle

bundle:
	cake build
	$(BROWSERIFY) js/popup.js -o Chrome/js/popup-bundle.js
	$(BROWSERIFY) js/options.js -o Chrome/js/options-bundle.js
	$(BROWSERIFY) js/standalone.js -o js/standalone-bundle.js
	$(BROWSERIFY) js/ios.js -o js/ios-bundle.js

# Build a zip ball and transfer it to GoodReader on iPhone
mypass-ios.zip: ios.html css js/ios-bundle.js js/ui.js js/lib js/cryptojs
	zip $@ -r $^
