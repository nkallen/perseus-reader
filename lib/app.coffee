express = require('express')
libxml = require('libxmljs')
fs = require('fs')
path = require('path')

text = require('./routes/text')

app = express()
app.use(express.responseTime())
app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(express.compress())
app.use(express.static(path.join(__dirname, 'public')))
app.set('view engine', 'ejs')
app.set('views', __dirname + '/views')

app.use((err, req, res, next) ->
  console.error(err.stack)
  res.send(500)
)

app.param('edition', (req, res, next, edition) ->
  if result = /([\w\s]+):((\d+\.)*\d+)$/.exec(edition)
    req.params.edition = result[1]
    req.params.passageSelector = result[2]
    next()
  else if result = /([\w\s]+)$/.exec(edition)
    req.params.edition = result[0]
    next()
  else
    next('route'))

app.get('/:group',                [text.loadIndex, text.loadGroup],
  text.group)
app.get('/:group/:work',          [text.loadIndex, text.loadGroup, text.loadWork],
  text.work)
app.get('/:group/:work/:edition', [text.loadIndex, text.loadGroup, text.loadWork, text.loadEdition, text.loadText, text.loadAnnotator, text.loadSelection],
  text.edition)
app.get('/',                      [text.loadIndex],
  text.index)

module.exports = app