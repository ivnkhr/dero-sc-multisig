// Modules to control application life and create native browser window
const {app, BrowserWindow, Menu, MenuItem, ipcMain} = require('electron')
path = require('path');
url = require('url');

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow
let explorerWindow

function openBlockExplorer(url) {
  explorerWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: false
    }
  });
  explorerWindow.loadURL(url);
}

function createWindow () {
  // Create the browser window.
  mainWindow = new BrowserWindow({width: 1280, height: 900})

  // and load the index.html of the app.
  mainWindow.loadFile('index.html')

  
  
	var template = [
			{
				label: "Application",
				submenu: [
					{
						label: "Debug Console",
						click: function () { mainWindow.webContents.openDevTools() }
					},
					{
						label: "Contract Git",
						click: function () { openBlockExplorer('https://github.com/plrspro/dero-sc-multisig') }
					},
					{
						label: "Exit",
						click: function () { app.exit(0) }
					}
				]
			},
			{
				label: "Utilities",
				submenu: [
					{
						label: "Blockexplorer (testnet)",
						click: function () { openBlockExplorer('http://pool.dero.io:8080/') }
					},
					{
						label: "Relaunch",
						click: function () { 
						  app.relaunch({ args: process.argv.slice(1).concat(['--relaunch']) })
						  app.exit(0)
						}
					}
				]
			}
		];        
	// build menu from template
	var menu = Menu.buildFromTemplate(template);  

  Menu.setApplicationMenu(menu); 
  
  

  
  // Open the DevTools.
  // mainWindow.webContents.openDevTools()

  // Emitted when the window is closed.
  mainWindow.on('closed', function () {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null
  })
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow)

// Quit when all windows are closed.
app.on('window-all-closed', function () {
  // On macOS it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

ipcMain.on('click', function(event, data){
    console.log(data);
	openBlockExplorer('http://pool.dero.io:8080/tx/'+data);
});

app.on('activate', function () {
  // On macOS it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) {
    createWindow()
  }
})

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.