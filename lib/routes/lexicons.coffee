module.exports =
  loadLexicon: (req, res, next) ->
    unless res.locals.lexicon = req.lexicon = req.app.get('lexicons')[req.params.lexicon]
      return res.send(400)
    next()

  show: (req, res) ->
    lemmas =
      if Array.isArray(req.query.lemmas) then req.query.lemmas
      else [req.query.lemmas]
    slice = (req.lexicon[lemma] for lemma in lemmas)

    res.format(
      'application/json': () ->
        res.json(slice)
    )

