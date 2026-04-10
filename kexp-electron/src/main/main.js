const { app, BrowserWindow, ipcMain, utilityProcess } = require('electron')
const { randomUUID } = require('node:crypto');

let embedded = false
if (process.env.NODE_ENV === 'development') {
  const yenv = require('yenv')
  const env = yenv(`${__dirname}/../../web_app/web_dev_config.yaml`, { env: 'server'})
  process.env.flutter_port = env.port
  process.env.flutter_host = env.host
} else {
  embedded = true
}

const createWindow = (port, app_id) => {
  ipcMain.on('set-counter', handleSetCounter)

  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: `${__dirname}/preload.js`
    }
  })

  if (process.env.NODE_ENV === 'development') {
    win.loadURL(`http://${process.env.flutter_host}:${port}/`)
  } else {
    win.loadURL(`http://localhost:${port}/`,{
      extraHeaders: `x-application-id: ${app_id}\n`
    })

    win.webContents.session.webRequest.onBeforeSendHeaders((details, callback) => {
      details.requestHeaders['x-application-id'] = app_id
      callback({ requestHeaders: details.requestHeaders })
    })
  }
}

app.whenReady().then(() => {
   if (embedded) {
      const app_id = randomUUID()
      const serverPath = `${__dirname}/server.js`
      const child = utilityProcess.fork(serverPath, [app_id])

      child.on('message', (port) => { 
        createWindow(port, app_id)
      })
   } else {
     const port = process.env.flutter_port
     createWindow(port)
   }
})

function handleSetCounter(event, counter) {
  console.log(`Counter value: ${counter}`)
}