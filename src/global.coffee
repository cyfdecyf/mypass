openOptions = ->
	url = safari.extension.baseURI + 'options.html'
	activeTab = safari.application.activeBrowserWindow.activeTab
	return if activeTab.url == url
	safari.application.activeBrowserWindow.openTab('foreground').url = url

settingsChanged = (event) ->
	if event.key == 'options'
		openOptions()

safari.extension.settings.addEventListener("change", settingsChanged, false)
