app = require('../../lib/app')
request = require('supertest')

describe 'repos', ->
  describe 'group', ->
    it 'works', (done) ->
      request(app)
        .get('/Homer')
        .set('Accept', 'text/html')
        .expect('Content-Type', /html/)
        .expect(200, done)

  describe 'work', ->
    it 'works', (done) ->
      request(app)
        .get('/Homer/Iliad')
        .set('Accept', 'text/html')
        .expect('Content-Type', /html/)
        .expect(200, done)

  describe 'edition', ->
    it 'works', (done) ->
      request(app)
        .get('/Homer/Iliad/Iliad')
        .set('Accept', 'text/html')
        .expect('Content-Type', /html/)
        .expect(200, done)