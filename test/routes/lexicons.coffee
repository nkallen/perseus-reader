fs = require('fs')
path = require('path')
request = require('supertest')

app = require('../../lib/app')

lexicons =
  ml: JSON.parse(fs.readFileSync(path.resolve(__dirname, '../../vendor/lexicon/ml.json')))

app.set('lexicons', lexicons)

describe 'lexicons', ->
  describe 'show', ->
    it 'works', (done) ->
      request(app)
        .get('/lexicons/ml?lemmas=ἀάατος')
        .expect(200, done)
