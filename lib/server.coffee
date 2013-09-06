util = require('perseus-util')
libxml = require('libxmljs')
fs = require('fs')
path = require('path')

textIndex = util.textIndex
annotator = util.annotator

app = require('./app')

app.configure('development', ->
  xml = libxml.parseXml(fs.readFileSync(path.resolve(__dirname, '../vendor/catalog_data/perseus/perseuscts.xml')))
  perseusFileReader =
    readFile: (file, callback) -> fs.readFile(path.join(__dirname, '../vendor/canonical/CTS_XML_TEI/perseus', file), callback)
  annotatorFileReader =
    readFile: (file, callback) -> fs.readFile(path.join(__dirname, '../vendor/treebank/perseus', file), callback)

  app.set('ctsIndex', textIndex.CtsIndex.load(xml))
  app.set('perseusRepository', new textIndex.PerseusRepository(perseusFileReader))
  app.set('annotatorRepository', new annotator.TreebankAnnotatorRepository(annotatorFileReader))

  app.listen(process.env.PORT)
)

