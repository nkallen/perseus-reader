util = require('perseus-util')
fs = require('fs')
libxml = require('libxmljs')
TreebankAnnotator = util.annotator.TreebankAnnotator
SimpleAnnotator = util.annotator.SimpleAnnotator
FailoverAnnotator = util.annotator.FailoverAnnotator
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

    res.locals.urn = req.urn = req.edition.urn
    next()

  loadUrn: (req, res, next) ->
    unless res.locals.edition = req.edition = req.index.urn(req.urn)
      return res.send(404) 
    next()

  loadText: (req, res, next) ->
    req.app.get('cache').get(req.urn,
      (annotatedEdition) ->
        res.locals.annotatedEdition = req.annotatedEdition = annotatedEdition
        next()
      , (callback) ->
        req.app.get('treebankAnnotatorRepository').urn(req.urn, (error, treebankAnnotator) ->
          req.app.get('nlpAnnotatorRepository').urn(req.urn, (error, nlpAnnotator) ->
            nlpAnnotator ||= new SimpleAnnotator
            req.app.get('perseusRepository').urn(req.urn, (error, text) ->
              return res.send(404) if error

              res.locals.annotatedEdition = req.annotatedEdition = annotatedEdition =
                new AnnotatedEdition(req.edition.citationMapping, nlpAnnotator, libxml.parseXml(text))
              callback(annotatedEdition)
              next()
            )
          )
        )
    )

  loadSelection: (req, res, next) ->
    res.locals.selection = req.selection =
      if req.params.passageSelector then req.annotatedEdition.select(req.params.passageSelector)
      else req.annotatedEdition.selectFirst()
    next()

  index: (req, res) ->
    res.render('index')
  
  group: (req, res) ->
    res.render('group')

  work: (req, res) ->
    res.render('work')

  edition: (req, res) ->
    res.render('edition')
