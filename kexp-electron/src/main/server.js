const express = require('express')
const app = express()
const port = 0

const flutterAppPath = __dirname + '/../web'

const restrictByHeader = (req, res, next) => {
  const secretHeader = req.headers['x-application-id']
  
  if (secretHeader === process.argv[2]) {
    next()
  } else {
    res.status(403).json({ error: 'Access Denied: Missing or invalid header.' })
  }
}

// Middleware to restrict access by a custom header
app.use(restrictByHeader)
// Path to your Flutter build/web directory
app.use(express.static(flutterAppPath))

// Handle client-side routing by redirecting all other requests to index.html
app.get('/{*splat}', (req, res) => {
    res.sendFile('index.html', 
        { 
            root: path.join(__dirname, 'web')
        })
});

const server = app.listen(port, () => {
    const address = server.address()
    console.log(`Server listening on http://localhost:${address.port}`)
    process.parentPort.postMessage(address.port)
})
