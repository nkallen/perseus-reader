util = require('perseus-util')
fs = require('fs')
libxml = require('libxmljs')
TreebankAnnotator = util.annotator.TreebankAnnotator
SimpleAnnotator = util.annotator.SimpleAnnotator
Edition = util.Edition

module.exports = (ctsIndex, perseusRepository, annotatorRepository) ->
  loadGroup: (req, res, next) ->
    return res.send(404) unless req.group = ctsIndex.group(req.params.group)
    next()

  loadWork: (req, res, next) ->
    return res.send(404) unless req.work = ctsIndex.work(req.params.group, req.params.work)
    next()

  loadEdition: (req, res, next) ->
    return res.send(404) unless req.work = ctsIndex.edition(req.params.group, req.params.work, req.params.edition)
    req.params.urn = req.work.urn
    next()

  loadUrn: (req, res, next) ->
    return res.send(404) unless req.work = ctsIndex.urn(req.params.urn)
    next()

  loadAnnotator: (req, res, next) ->
    annotatorRepository.urn(req.params.urn, (error, annotator) ->
      return res.send(500) if error
      req.annotator = annotator
      next()
    )
  
  group: (req, res) ->
    res.render('group')

  work: (req, res) ->
    res.render('work')

  edition: (req, res) ->
    text = req.text
    res.render('text',
      edition: new Edition(req.edition.citationMapping, text.passageSelector, req.annotator, req.text),
      urn: req.urn
      features: util.greek.Features)

###
  update: (req, res) ->
    self = this
    text = req.text

    for key, value of req.body.path
      node = text.document.get(unescape(key))
      replacement = libxml.parseXml(value).root()
      node.addNextSibling(replacement)
      node.remove()

    ctsIndex.urn(text.metadata.urn, text, (err) ->
      return res.send(500) if err

      res.render('text',
        edition: new Edition(text.metadata.citationMapping, text.passageSelector, req.annotator, text.document),
        urn: req.urn
        features: util.greek.Features))

  annotations:
    show: (req, res) ->
      annotator = req.annotator
      res.json(annotator.toJson())

    update: (req, res) ->
      text = req.text
      annotator = req.annotator
      annotator.update(req.params.id, req.body)
      annotatorRepository.pid(text.metadata.pid, annotator, (err) ->
        return res.send(500) if err

        res.render('text',
          edition: new Edition(text.metadata.citationMapping, text.passageSelector, req.annotator, text.document),
          urn: req.urn
          features: util.greek.Features))
###