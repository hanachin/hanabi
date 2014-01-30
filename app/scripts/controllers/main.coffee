'use strict'

class Color
  @RAINBOW: 'rainbow'
  @RED:     'red'
  @GREEN:   'green'
  @WHITE:   'white'
  @YELLOW:  'yellow'
  @BLUE:    'blue'

  @SINGLE_COLORS: [@RED, @GREEN, @WHITE, @YELLOW, @BLUE]

class Card
  constructor: ({@color, @number}) ->

  isRainbow: ->
    @color is Color.RAINBOW

class Player
  constructor: ({@name}) ->
    @playable          = no
    @cards             = []
    @others            = []
    @rememberedCards   = []
    @callbacks         = []

    @on 'turn', ({@canHints}) =>
      @playable = yes

  discover: (other) ->
    @others.push other

  takeCard: (deck) ->
    @cards.push deck.takeCard()

  play: (card, color = card.color) ->
    @playable        = no
    @cards           = _.without(@cards, card)
    @rememberedCards = _.without(@rememberedCards, card)
    @trigger 'play', @, card, color

  discard: (card) ->
    @playable = no
    @cards    = _.without(@cards, card)
    @trigger 'discard', @, card

  tellColor: (other, color) ->
    cards = _.select other.cards, (card) -> card.color is color || card.color is Color.RAINBOW
    other.rememberColor cards: cards, color: color
    @trigger 'hint'

  tellNumber: (other, number) ->
    cards = _.select other.cards, (card) -> card.number is number
    other.rememberNumber cards: cards, number: number
    @trigger 'hint'

  isRemembered: (card) ->
    _.contains @rememberedCards, card

  remember: (memory) ->
    @rememberedCards.push memory.card unless @isRemembered memory.card
    @trigger 'remember', memory

  rememberColor: ({cards, color}) ->
    @remember card: card, color: color for card in cards

  rememberNumber: ({cards, number}) ->
    @remember card: card, number: number for card in cards

  trigger: (eventName, rest...) ->
    callback rest... for callback in (@callbacks[eventName] ? [])

  cardColors: ->
    _.uniq(_.map(@cards, (c) -> c.color))

  cardNumbers: ->
    _.uniq(_.map(@cards, (c) -> c.number))

  on: (eventName, callback) ->
    @callbacks[eventName] ?= []
    @callbacks[eventName].push callback

class Deck
  constructor: ->
    @cards = []
    @cards.push new Card color: Color.RAINBOW, number: n for n in [1..5]
    for color in Color.SINGLE_COLORS
      @cards.push new Card color: color, number: 1 for _ in [1..3]
      @cards.push new Card color: color, number: n for _ in [1..2] for n in [2..4]
      @cards.push new Card color: color, number: 5

  shuffle: ->
    @cards = _.shuffle(@cards)

  takeCard: ->
    @cards.shift()

  isEmpty: ->
    @cards.length is 0

class ExplosionError extends Error
  constructor: ->

class GameOverError extends Error
  constructor: ->

class Hanabi
  @MAX_EXPLOSION: 3
  @MAX_HINT:      8

  constructor: ({@players}) ->
    @turn               = 0
    @deck               = new Deck
    @hints              = Hanabi.MAX_HINT
    @explosions         = 0
    @fireworks          = _.object Color.SINGLE_COLORS, ([] for _i in [1..Color.SINGLE_COLORS.length])
    @lastTurnCount      = 0
    @discardedFireworks = []

  start: ->
    @discoverEachOther()
    @listenPlayerEvents()
    @deck.shuffle()
    @deal()
    @nextTurn()

  discoverEachOther: ->
    player.discover other for other in @players when other isnt player for player in @players

  listenPlayerEvents: ->
    player.on eventName, _.bind @[eventName], @ for eventName in ['play', 'discard', 'hint'] for player in @players

  deal: ->
    player.takeCard @deck for _ in [1..4] for player in @players

  play: (player, card, color) ->
    try
      @fire card, color
      @recoverHints() if @isFireworksFinished(color)
    catch explosion
      throw explosion unless explosion instanceof ExplosionError

      console.log 'explosion', explosion
      @discardedFireworks.push card
      @explosions = @explosions + 1
      throw explosion if Hanabi.MAX_EXPLOSION <= @explosions
    player.takeCard @deck unless @deck.isEmpty()
    @nextTurn()

  discard: (player, card) ->
    @discardedFireworks.push card
    @recoverHints()
    player.takeCard @deck unless @deck.isEmpty()
    @nextTurn()

  hint: ->
    @loseHint()
    @nextTurn()

  loseHint: ->
    @hints = @hints - 1

  fire: (card, color) ->
    return @fireworks[color].push(card) if (!@isFireworksStared(color) && card.number is 1) || @lastFireworks(color)?.number is card.number - 1
    throw new ExplosionError

  isFireworksStared: (color) ->
    @fireworks[color].length isnt 0

  isFireworksFinished: (color) ->
    @fireworks[color].length is 5

  isGameOver: ->
    @lastTurnCount >= @players.length

  lastFireworks: (color) ->
    _.last @fireworks[color]

  recoverHints: ->
    @hints = @hints + 1 if @hints < Hanabi.MAX_HINT

  nextPlayer: ->
    @players[@turn % @players.length]

  nextTurn: ->
    @lastTurnCountUp() if @deck.isEmpty()
    throw GameOverError if @isGameOver()
    @currentPlayer = @nextPlayer()
    @currentPlayer.trigger 'turn', canHints: @hints isnt 0
    @turn = @turn + 1

  lastTurnCountUp: ->
    @lastTurnCount = @lastTurnCount + 1

angular.module('hanabiApp')
  .controller 'MainCtrl', ($scope) ->
    $scope.Color = Color

    $scope.start = ->
      $scope.game = new Hanabi players: (new Player name: "player#{x}" for x in [1..4])
      $scope.game.start()

    $scope.play = (player, card) ->
      player.play(card)

    $scope.playRainbow = (player, card, color) ->
      console.log 'rainbow', color
      player.play(card, color)

    $scope.discard = (player, card) ->
      player.discard(card)

    $scope.tellColor = (other, color) ->
      $scope.game.currentPlayer.tellColor other, color

    $scope.tellNumber = (other, number) ->
      $scope.game.currentPlayer.tellNumber other, number

    # card = player.cards[0]
    # player.play card
    # player.takeCard game.deck
