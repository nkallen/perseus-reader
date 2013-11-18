util = require('perseus-util')
libxml = require('libxmljs')
fs = require('fs')
path = require('path')

textIndex = util.textIndex
annotator = util.annotator

class Cache
  constructor: () ->
    @hash = {}
  get: (key, hit, miss) ->
    if key of @hash
      hit(@hash[key])
    else
      self = this
      miss((result) -> self.hash[key] = result)

app = require('./app')

app.configure('development', ->
  lexicons =
    ml: JSON.parse(fs.readFileSync(path.resolve(__dirname, '../vendor/lexicon/ml.json')))

  ctsXml = libxml.parseXml(fs.readFileSync(path.resolve(__dirname, '../vendor/catalog_data/perseus/perseuscts.xml')))

  perseusFileReader =
    readFile: (file, callback) -> fs.readFile(path.join(__dirname, '../vendor/canonical/CTS_XML_TEI/perseus', file), callback)
  treebankAnnotatorFileReader =
    readFile: (file, callback) -> fs.readFile(path.join(__dirname, '../vendor/treebank/perseus', file), callback)
  nlpAnnotatorFileReader =
    readFile: (file, callback) -> fs.readFile(path.join(__dirname, '../vendor/tagged/perseus', file), callback)

  app.set('ctsIndex', textIndex.CtsIndex.load(ctsXml))
  app.set('perseusRepository', new textIndex.PerseusRepository(perseusFileReader))
  app.set('treebankAnnotatorRepository', new annotator.TreebankAnnotatorRepository(treebankAnnotatorFileReader))
  app.set('nlpAnnotatorRepository', new annotator.TreebankAnnotatorRepository(nlpAnnotatorFileReader))
  app.set('lexicons', lexicons)
  app.set('cache', new Cache)
  app.listen(process.env.PORT)
)

app.configure('production', ->
  request = require('request').defaults(json: true)

  gitDbUrl = process.env.GITDB_URL

  request(gitDbUrl + "/repos/lexicon/refs/heads/master/tree/ml.json", (error, res, ml) ->
    lexicons =
      ml: JSON.parse(new Buffer(ml.blob.content, ml.blob.encoding))

    request(gitDbUrl + "/repos/catalog_data/refs/heads/master/tree/perseus/perseuscts.xml", (error, res, cts) ->
      ctsXml = libxml.parseXml(new Buffer(cts.blob.content, cts.blob.encoding).toString())

      perseusFileReader =
        readFile: (file, callback) ->
          request(gitDbUrl + '/repos/canonical/refs/heads/master/tree/CTS_XML_TEI/perseus/' + file, (error, res, file) ->
            return callback(error) if error
            return callback(new Error("Not found")) if res.statusCode == 404

            callback(null, new Buffer(file.blob.content, file.blob.encoding).toString())
          )
      treebankAnnotatorFileReader =
        readFile: (file, callback) ->
          request(gitDbUrl + '/repos/treebank/refs/heads/master/tree/perseus/' + file, (error, res, file) ->
            return callback(error) if error
            return callback(new Error("Not found")) if res.statusCode == 404

            callback(null, new Buffer(file.blob.content, file.blob.encoding).toString())
          )
      nlpAnnotatorFileReader =
        readFile: (file, callback) -> 
          request(gitDbUrl + '/repos/tagged/refs/heads/master/tree/perseus/' + file, (error, res, file) ->
            return callback(error) if error
            return callback(new Error("Not found")) if res.statusCode == 404

            callback(null, new Buffer(file.blob.content, file.blob.encoding).toString())
          )

      app.set('ctsIndex', textIndex.CtsIndex.load(ctsXml))
      app.set('perseusRepository', new textIndex.PerseusRepository(perseusFileReader))
      app.set('treebankAnnotatorRepository', new annotator.TreebankAnnotatorRepository(treebankAnnotatorFileReader))
      app.set('nlpAnnotatorRepository', new annotator.TreebankAnnotatorRepository(nlpAnnotatorFileReader))
      app.set('lexicons', lexicons)
      app.set('cache', new Cache)
      app.listen(process.env.PORT)
    )
  )
)
