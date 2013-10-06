module.exports =
  loadLexicon: (req, res, next) ->
    unless res.locals.lexicon = req.lexicon = req.app.get('lexicons')[req.params.lexicon]
      return res.send(400)
    next()

  show: (req, res) ->
    lemmas = req.query.lemmas || req.body.lemmas
    lemmas =
      if Array.isArray(lemmas) then lemmas
      else [lemmas]
    slice = {}
    for lemma in lemmas
      slice[lemma] = req.lexicon[lemma]

    res.format(
      'application/json': () ->
        res.json(slice)
    )

