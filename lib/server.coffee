util = require('perseus-util')
libxml = require('libxmljs')
fs = require('fs')
path = require('path')

textIndex = util.textIndex
annotator = util.annotator

app = require('./app')

app.configure('development', ->
  lexicons =
    ml: JSON.parse(fs.readFileSync(path.resolve(__dirname, '../vendor/lexicon/ml.json')))

  ctsXml = libxml.parseXml(fs.readFileSync(path.resolve(__dirname, '../vendor/catalog_data/perseus/perseuscts.xml')))

  perseusFileReader =
    readFile: (file, callback) -> fs.readFile(path.join(__dirname, '../vendor/canonical/CTS_XML_TEI/perseus', file), callback)
  annotatorFileReader =
    readFile: (file, callback) -> fs.readFile(path.join(__dirname, '../vendor/treebank/perseus', file), callback)

  app.set('ctsIndex', textIndex.CtsIndex.load(ctsXml))
  app.set('perseusRepository', new textIndex.PerseusRepository(perseusFileReader))
  app.set('annotatorRepository', new annotator.TreebankAnnotatorRepository(annotatorFileReader))
  app.set('lexicons', lexicons)

  app.listen(process.env.PORT)
)

