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

app.get('/:group',                [text.loadIndex, text.loadGroup],                                  text.group)
app.get('/:group/:work',          [text.loadIndex, text.loadGroup, text.loadWork],                   text.work)
app.get('/:group/:work/:edition', [text.loadIndex, text.loadGroup, text.loadWork, text.loadEdition, text.loadText, text.loadAnnotator], text.edition)
app.get('/',                      [text.loadIndex], text.index)

module.exports = app