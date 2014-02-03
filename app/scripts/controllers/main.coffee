'use strict'

class Color
  @RAINBOW: 'x'
  @RED:     'r'
  @GREEN:   'g'
  @WHITE:   'w'
  @YELLOW:  'y'
  @BLUE:    'b'

  @SINGLE_COLORS: [@RED, @GREEN, @WHITE, @YELLOW, @BLUE]

class Card
  constructor: ({@color, @number}) ->
    @id = "#{@color}#{@number}"

  isRainbow: ->
    @color is Color.RAINBOW

  serialize: ->
    @id

  @load: (id) ->
    new Card color: id[0], number: +id[1..]

class Player
  constructor: ({@name}) ->
    @playable          = no
    @cards             = []
    @rememberedCards   = []
    @callbacks         = []

    @on 'turn', ({@canHints}) =>
      @playable = yes

  takeCard: (deck) ->
    card = deck.takeCard()
    @cards.push card
    @trigger 'takeCard', @, card

  play: (card, color = card.color) ->
    @playable        = no
    @cards           = _.without(@cards, (c) -> c.id is card.id)
    @rememberedCards = _.without(@rememberedCards, (c) -> c.id is card.id)
    @trigger 'play', @, card, color

  discard: (card) ->
    console.log 'Player#discard', card
    @playable = no
    @cards    = _.without(@cards, (c) -> c.id is card.id)
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
    _.contains @rememberedCards, (c) -> c.id is card.id

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

  serialize: ->
    name:            @name
    playable:        @playable
    cards:           (c.serialize() for c in @cards)
    rememberedCards: (c.serialize() for c in @cards)

  @load: (data) ->
    console.log 'Player.load', data
    player = new Player name: data.name
    player.playable        = data.playable
    player.cards           = (Card.load card for card in data.cards)
    player.rememberedCards = (Card.load card for card in data.rememberedCards)
    player

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

  serialize: ->
    (c.serialize() for c in @cards)

  @load: (cards) ->
    deck = new Deck
    deck.cards = (Card.load card for card in cards)
    deck

class ExplosionError extends Error
  constructor: ->

class GameOverError extends Error
  constructor: ->

class Hanabi
  @MAX_EXPLOSION: 3
  @MAX_HINT:      8

  constructor: (options = {}) ->
    {@players} = options
    @players            ||= []
    @turn               = 0
    @deck               = new Deck
    @deck.shuffle()
    @hints              = Hanabi.MAX_HINT
    @explosions         = 0
    @fireworks          = _.object Color.SINGLE_COLORS, ([] for _i in [1..Color.SINGLE_COLORS.length])
    @lastTurnCount      = 0
    @discardedFireworks = []

  login: (name) ->
    return player if (player = @player name)
    @players.push new Player name: name

  player: (name) ->
    _.find(@players, (player) -> player.name is name)

  start: ->
    @listenPlayerEvents()
    @deal()
    @nextTurn()

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

  serialize: ->
    console.log 'Hanabi#serialize'

    # [XXX] - あとでFireworksクラス作ってserialize呼ぶだけにしたい
    fireworks = {}
    fireworks[k] = (c.serialize() for c in @fireworks[k]) for k, v of @fireworks

    players:            (p.serialize() for p in @players)
    currentPlayerName:  @currentPlayer?.name
    turn:               @turn
    deck:               @deck.serialize()
    hints:              @hints
    explosions:         @explosions
    fireworks:          fireworks
    lastTurnCount:      @lastTurnCount
    discardedFireworks: (c.serialize() for c in @discardedFireworks)

  @load: (data) ->
    console.log 'Hanabi.load', data
    hanabi                    = new Hanabi
    hanabi.players            = (Player.load p for p in data.players)
    hanabi.currentPlayer      = hanabi.login(data.currentPlayerName) if data.currentPlayerName
    hanabi.turn               = data.turn
    hanabi.deck               = Deck.load data.deck
    hanabi.hints              = data.hints
    hanabi.explosions         = data.explosions
    hanabi.fireworks          = {}
    hanabi.fireworks[color]   = (Card.load c for c in data.fireworks[color]) for color in Color.SINGLE_COLORS
    hanabi.lastTurnCount      = data.lastTurnCount
    hanabi.discardedFireworks = (Card.load c for c in data.discardedFireworks)
    hanabi

class HanabiRoom
  constructor: (@PubNub, @roomName) ->
    @initialized = no
    @connected   = no
    @PubNub.subscribe
      channel: @roomName
      restore: no
      disconnect: ->
        console.log 'PubNub disconnected'
      reconnect: ->
        console.log 'PubNub re-connected'
      connect: =>
        console.log 'PubNub connected'
        @connected = yes

    , ({eventName, data}) =>
      console.log 'event', eventName, data
      switch eventName
        when 'ping' then @pong() && @sync()
        when 'pong' then @clearHanabiSetupTimeoutId()
        when 'sync' then @restore(data)

  clearHanabiSetupTimeoutId: ->
    console.log 'clearHanabiSetupTimeoutId'
    clearTimeout @hanabiSetupTimeoutId if @hanabiSetupTimeoutId

  connect: (@hanabiInitializedCallback) ->
    console.log 'connect'
    @connectIntervalId = setInterval =>
      console.log 'connect interval'
      return unless @connected
      clearInterval @connectIntervalId
      @hanabiSetupTimeoutId = setTimeout =>
        console.log 'connect timeout'
        @setup()
        @hanabiInitializedCallback()
      , 1000
      @ping()
    , 100

  ping: ->
    console.log 'ping'
    @publish 'ping'

  pong: ->
    return unless @initialized
    console.log 'pong'
    @publish 'pong'
    yes

  sync: ->
    @publish 'sync', @hanabi.serialize()

  setup: ->
    console.log 'setup'
    @initialized = yes
    @hanabi = new Hanabi

  restore: (data) ->
    console.log 'restore', data
    @hanabi = Hanabi.load data
    unless @initialized
      @initialized = yes
      @hanabiInitializedCallback()

  publish: (eventName, data) ->
    console.log 'publish', eventName, data
    @PubNub.publish
      channel: @roomName
      message: { eventName: eventName, data: data }

angular.module('hanabiApp')
  .controller 'MainCtrl', ($scope, $PubNub) ->
    $scope.Color = Color

    $scope.roomName    = 'geeaki'
    $scope.playerName  = 'hanachin'
    $scope.loggedIn    = no

    $scope.login = ->
      return if $scope.loggedIn
      console.log '$scope.login'
      $scope.loggedIn = yes
      $scope.hanabiRoom = new HanabiRoom $PubNub, $scope.roomName
      $scope.hanabiRoom.connect ->
        $scope.$apply ->
          $scope.hanabiRoom.hanabi.login $scope.playerName
          $scope.hanabiRoom.sync()

    $scope.start = ->
      $scope.hanabiRoom.hanabi.start()
      $scope.hanabiRoom.sync()

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
