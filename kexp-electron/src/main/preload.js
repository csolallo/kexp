const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('electronAPI', {
  setCounter: (counter) => ipcRenderer.send('set-counter', counter)
})