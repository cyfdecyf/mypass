BROWSERIFY=node_modules/.bin/browserify
JSDIR=Chrome/js
SRC=src/popup.coffee src/ui.coffee src/passwdgen.coffee src/standalone.coffee src/popup.coffee

all: bundle

bundle:
	cake build
	$(BROWSERIFY) $(JSDIR)/popup.js -o $(JSDIR)/popup-bundle.js
	$(BROWSERIFY) $(JSDIR)/standalone.js -o $(JSDIR)/standalone-bundle.js
