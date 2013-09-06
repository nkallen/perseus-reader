util = require('perseus-util')
fs = require('fs')
libxml = require('libxmljs')
TreebankAnnotator = util.annotator.TreebankAnnotator
SimpleAnnotator = util.annotator.SimpleAnnotator
AnnotatedEdition = util.AnnotatedEdition

module.exports =
  loadIndex: (req, res, next) ->
    res.locals.ctsIndex = req.ctsIndex = req.app.get('ctsIndex')
    next()

  loadGroup: (req, res, next) ->
    unless res.locals.group = req.group = req.ctsIndex.group(req.params.group)
      return res.send(404)
    next()

  loadWork: (req, res, next) ->
    unless res.locals.work = req.work = req.ctsIndex.work(req.params.group, req.params.work)
      return res.send(404) 
    next()

  loadEdition: (req, res, next) ->
    unless res.locals.edition = req.edition = req.ctsIndex.edition(req.params.group, req.params.work, req.params.edition)
      return res.send(404)

    res.locals.urn = req.params.urn = req.edition.urn
    next()

  loadUrn: (req, res, next) ->
    unless res.locals.edition = req.edition = req.index.urn(req.params.urn)
      return res.send(404) 
    next()

  loadAnnotator: (req, res, next) ->
    req.app.get('annotatorRepository').urn(req.params.urn, (error, annotator) ->
      return res.send(500) if error
      req.annotator = annotator
      next()
    )

  loadText: (req, res, next) ->
    req.app.get('perseusRepository').urn(req.params.urn, (error, text) ->
      return res.send(404) if error
      req.text = libxml.parseXml(text)
      next()
    )

  index: (req, res) ->
    res.render('index')
  
  group: (req, res) ->
    res.render('group')

  work: (req, res) ->
    res.render('work')

  edition: (req, res) ->
    res.render('edition',
      annotatedEdition: AnnotatedEdition.make(req.edition.citationMapping, req.params.passageSelector, req.annotator, req.text),
      features: util.greek.Features)