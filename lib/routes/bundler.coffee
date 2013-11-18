Bundler = require('../bundler')
bundler = new Bundler(module, require)

bundler.dependency('../../node_modules/perseus-util/lib/greek', 'greek')
bundler.exclude('../../node_modules/perseus-util/node_modules/unorm/lib/unorm')

module.exports =
  show: (req, res, next) ->
    res.charset = 'utf-8'
    res.type('application/javascript')
    res.end(bundler.toString())
