$(function() {
  function toTree($this) {
    var annotation = $this.data('annotation')
    var $p = $this.parents('.paragraph').first()
    var id2annotation = {}
    $p.find('.words > span').each(function() {
      var $this = $(this)
      var thisAnnotation = $this.data('annotation')
      
      if (annotation.sentenceId == thisAnnotation.sentenceId) {
        id2annotation[thisAnnotation.id] = thisAnnotation
      }
    })

    for (var id in id2annotation) {
      var annotation = id2annotation[id]
      var parent = id2annotation[annotation.parentId]
      if (!parent) continue

      (parent.children || (parent.children = [])).push(annotation)
      annotation.parent = parent
    }
  }

  var MAX_LEVEL = 4

  var sentence = {
    show: function() {
      var $this = $(this)
      var annotation = $this.data('annotation')

      $this.addClass('highlight').addClass('pivot')

      if (annotation.sentenceId) {
        if (!annotation.parent && !annotation.children)
          toTree($this)

        var node = annotation
        var level = 0
        while ((node = node.parent) && ++level <= MAX_LEVEL) {
          $('#' + node.sentenceId + '-' + node.id)
            .addClass('highlight')
            .addClass('parent')
            .css('opacity', 1.0 - (level / (MAX_LEVEL + 1)))
        }
        level = 0
        var bfs = [[annotation]]
        while ((nodes = bfs.pop()) && level++ <= MAX_LEVEL - 1) {
          var nextLevel = []
          for (n in nodes) {
            var node = nodes[n]
            nextLevel = nextLevel.concat(node.children || [])
            $('#' + node.sentenceId + '-' + node.id)
              .addClass('highlight')
              .addClass('child')
              .css('opacity', 1.0 - ((level-1) / MAX_LEVEL))
          }
          bfs.push(nextLevel)
        }
      }
    }
  }

  var lemma = {
    highlight: function() {
      var $this = $(this)
      var annotation = $this.data('annotation')
      setTimeout(function() {
        // Hack because jquery/sizzle can't handle unicode classnames:
        var wordsWithSameLemma = $(document.getElementsByClassName('lemma-' + annotation.lemma))
        wordsWithSameLemma.not($this).addClass('highlight')
      }, 10)
    }
  }

  var state = {
    reset: function() {
      $('.highlight, .child, .parent, .pivot')
        .removeClass('highlight child parent pivot')
        .attr('style', '')
    }
  }

  var info = {
    showWord: function() {},
    editWord: function() {}
  }

  $('.words > span')
    .click(state.reset)
    .click(info.showWord)
    .click(sentence.show)
    .click(lemma.highlight)
})
