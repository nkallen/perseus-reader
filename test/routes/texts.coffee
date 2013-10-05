path = require('path')
fs = require('fs')
request = require('supertest')
util = require('perseus-util')
libxml = require('libxmljs')

textIndex = util.textIndex
annotator = util.annotator

app = require('../../lib/app')

xml = libxml.parseXml(fs.readFileSync(path.resolve(__dirname, '../../vendor/catalog_data/perseus/perseuscts.xml')))
fileReader =
  readFile: (file, callback) -> fs.readFile(path.join(__dirname, '../../vendor/canonical/CTS_XML_TEI/perseus', file), callback)

app.set('ctsIndex', textIndex.CtsIndex.load(xml))
app.set('perseusRepository', new textIndex.PerseusRepository(fileReader))
app.set('annotatorRepository',
  urn: (urn, callback) -> callback(null, new annotator.SimpleAnnotator))

describe 'text', ->
  describe 'group', ->
    it 'works', (done) ->
      request(app)
        .get('/texts/Homer')
        .expect(200, done)

  describe 'work', ->
    it 'works', (done) ->
      request(app)
        .get('/texts/Homer/Iliad')
        .expect(200, done)

  describe 'edition', ->
    it 'works', (done) ->
      request(app)
        .get('/texts/Homer/Iliad/Iliad:1')
        .expect(200, done)