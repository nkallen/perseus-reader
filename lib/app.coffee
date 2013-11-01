express = require('express')
libxml = require('libxmljs')
fs = require('fs')
path = require('path')

Bundler = require('./bundler')
bundler = new Bundler(module, require)
bundler.dependency('../node_modules/perseus-util/lib/greek', 'greek')
bundler.exclude('../node_modules/perseus-util/node_modules/unorm/lib/unorm')

texts = require('./routes/texts')
lexicons = require('./routes/lexicons')

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
  if result = /([\w\s]+):(([^.]+\.)*[^.]+)$/.exec(edition)
    req.params.edition = result[1]
    req.params.passageSelector = result[2]
    next()
  else if result = /([\w\s]+)$/.exec(edition)
    req.params.edition = result[0]
    next()
  else
    next('route'))

app.get('/texts/:group',                [texts.loadIndex, texts.loadGroup],
  texts.group)
app.get('/texts/:group/:work',          [texts.loadIndex, texts.loadGroup, texts.loadWork],
  texts.work)
app.get('/texts/:group/:work/:edition', [texts.loadIndex, texts.loadGroup, texts.loadWork, texts.loadEdition, texts.loadText, texts.loadTreebankAnnotator, texts.loadNlpAnnotator, texts.loadAnnotator, texts.loadSelection],
  texts.edition)
app.all('/lexicons/:lexicon',           [lexicons.loadLexicon]
  lexicons.show)
app.get('/',                            [texts.loadIndex],
  texts.index)

app.get('/application.js', (req, res) ->
  res.charset = 'utf-8'
  res.type('application/javascript')
  res.end(bundler.toString())
)
module.exports = app