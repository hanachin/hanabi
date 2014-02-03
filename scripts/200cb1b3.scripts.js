(function(){"use strict";angular.module("hanabiApp",["ngCookies","ngResource","ngSanitize","ngRoute","ui.bootstrap","angular-pubnub"]).config(["$routeProvider",function(a){return a.when("/",{templateUrl:"views/main.html",controller:"MainCtrl"}).otherwise({redirectTo:"/"})}])}).call(this),function(){"use strict";var a,b,c,d,e,f,g,h,i=[].slice,j={}.hasOwnProperty,k=function(a,b){function c(){this.constructor=a}for(var d in b)j.call(b,d)&&(a[d]=b[d]);return c.prototype=b.prototype,a.prototype=new c,a.__super__=b.prototype,a};b=function(){function a(){}return a.RAINBOW="x",a.RED="r",a.GREEN="g",a.WHITE="w",a.YELLOW="y",a.BLUE="b",a.SINGLE_COLORS=[a.RED,a.GREEN,a.WHITE,a.YELLOW,a.BLUE],a}(),a=function(){function a(a){this.color=a.color,this.number=a.number,this.id=""+this.color+this.number}return a.prototype.isRainbow=function(){return this.color===b.RAINBOW},a.prototype.serialize=function(){return this.id},a.load=function(b){return new a({color:b[0],number:+b.slice(1)})},a}(),h=function(){function c(a){var b=this;this.name=a.name,this.playable=!1,this.cards=[],this.rememberedCards=[],this.callbacks=[],this.on("turn",function(a){return b.canHints=a.canHints,b.playable=!0})}return c.prototype.takeCard=function(a){var b;return b=a.takeCard(),this.cards.push(b),this.trigger("takeCard",this.name,b)},c.prototype.play=function(a,b){return null==b&&(b=a.color),this.playable=!1,this.cards=_.reject(this.cards,function(b){return b.id===a.id}),this.rememberedCards=_.reject(this.rememberedCards,function(b){return b.id===a.id}),this.trigger("play",this.name,a,b)},c.prototype.discard=function(a){return console.log("Player#discard",a,this.cards),this.playable=!1,this.cards=_.reject(this.cards,function(b){return b.id===a.id}),console.log("Player#discard after",a,this.cards),this.trigger("discard",this.name,a)},c.prototype.tellColor=function(a,c){var d;return d=_.select(a.cards,function(a){return a.color===c||a.color===b.RAINBOW}),a.rememberColor({cards:d,color:c}),this.trigger("hint")},c.prototype.tellNumber=function(a,b){var c;return c=_.select(a.cards,function(a){return a.number===b}),a.rememberNumber({cards:c,number:b}),this.trigger("hint")},c.prototype.isRemembered=function(a){return _.some(this.rememberedCards,function(b){return b.id===a.id})},c.prototype.remember=function(a){return this.isRemembered(a.card)||this.rememberedCards.push(a.card),this.trigger("remember",a)},c.prototype.rememberColor=function(a){var b,c,d,e,f,g;for(c=a.cards,d=a.color,g=[],e=0,f=c.length;f>e;e++)b=c[e],g.push(this.remember({card:b,color:d}));return g},c.prototype.rememberNumber=function(a){var b,c,d,e,f,g;for(c=a.cards,d=a.number,g=[],e=0,f=c.length;f>e;e++)b=c[e],g.push(this.remember({card:b,number:d}));return g},c.prototype.trigger=function(){var a,b,c,d,e,f,g,h;for(b=arguments[0],c=2<=arguments.length?i.call(arguments,1):[],g=null!=(f=this.callbacks[b])?f:[],h=[],d=0,e=g.length;e>d;d++)a=g[d],h.push(a.apply(null,c));return h},c.prototype.cardColors=function(){return _.uniq(_.map(this.cards,function(a){return a.color}))},c.prototype.cardNumbers=function(){return _.uniq(_.map(this.cards,function(a){return a.number}))},c.prototype.on=function(a,b){var c;return null==(c=this.callbacks)[a]&&(c[a]=[]),this.callbacks[a].push(b)},c.prototype.serialize=function(){var a;return{name:this.name,playable:this.playable,cards:function(){var b,c,d,e;for(d=this.cards,e=[],b=0,c=d.length;c>b;b++)a=d[b],e.push(a.serialize());return e}.call(this),rememberedCards:function(){var b,c,d,e;for(d=this.cards,e=[],b=0,c=d.length;c>b;b++)a=d[b],e.push(a.serialize());return e}.call(this)}},c.load=function(b){var d,e;return console.log("Player.load",b),e=new c({name:b.name}),e.playable=b.playable,e.cards=function(){var c,e,f,g;for(f=b.cards,g=[],c=0,e=f.length;e>c;c++)d=f[c],g.push(a.load(d));return g}(),e.rememberedCards=function(){var c,e,f,g;for(f=b.rememberedCards,g=[],c=0,e=f.length;e>c;c++)d=f[c],g.push(a.load(d));return g}(),e},c}(),c=function(){function c(){var c,d,e,f,g,h,i,j,k,l;for(this.cards=[],d=f=1;5>=f;d=++f)this.cards.push(new a({color:b.RAINBOW,number:d}));for(l=b.SINGLE_COLORS,g=0,j=l.length;j>g;g++){for(c=l[g],e=h=1;3>=h;e=++h)this.cards.push(new a({color:c,number:1}));for(d=i=2;4>=i;d=++i)for(e=k=1;2>=k;e=++k)this.cards.push(new a({color:c,number:d}));this.cards.push(new a({color:c,number:5}))}}return c.prototype.shuffle=function(){return this.cards=_.shuffle(this.cards)},c.prototype.takeCard=function(){return this.cards.shift()},c.prototype.isEmpty=function(){return 0===this.cards.length},c.prototype.serialize=function(){var a,b,c,d,e;for(d=this.cards,e=[],b=0,c=d.length;c>b;b++)a=d[b],e.push(a.serialize());return e},c.load=function(b){var d,e;return e=new c,e.cards=function(){var c,e,f;for(f=[],c=0,e=b.length;e>c;c++)d=b[c],f.push(a.load(d));return f}(),e},c}(),d=function(a){function b(){}return k(b,a),b}(Error),e=function(a){function b(){}return k(b,a),b}(Error),f=function(){function f(a){var d;null==a&&(a={}),this.players=a.players,this.players||(this.players=[]),this.turn=0,this.deck=new c,this.deck.shuffle(),this.hints=f.MAX_HINT,this.explosions=0,this.fireworks=_.object(b.SINGLE_COLORS,function(){var a,c,e;for(e=[],d=a=1,c=b.SINGLE_COLORS.length;c>=1?c>=a:a>=c;d=c>=1?++a:--a)e.push([]);return e}()),this.lastTurnCount=0,this.discardedFireworks=[]}return f.MAX_EXPLOSION=3,f.MAX_HINT=8,f.prototype.login=function(a){var b;return(b=this.player(a))?b:this.players.push(new h({name:a}))},f.prototype.player=function(a){return _.find(this.players,function(b){return b.name===a})},f.prototype.start=function(){return this.started=!0,this.listenPlayerEvents(),this.deal(),this.nextTurn()},f.prototype.listenPlayerEvents=function(){var a,b,c,d,e,f;for(e=this.players,f=[],c=0,d=e.length;d>c;c++)b=e[c],f.push(function(){var c,d,e,f;for(e=["play","discard","hint"],f=[],c=0,d=e.length;d>c;c++)a=e[c],f.push(b.on(a,_.bind(this[a],this)));return f}.call(this));return f},f.prototype.deal=function(){var a,b,c,d,e,f;for(e=this.players,f=[],c=0,d=e.length;d>c;c++)a=e[c],f.push(function(){var c,d;for(d=[],b=c=1;4>=c;b=++c)d.push(a.takeCard(this.deck));return d}.call(this));return f},f.prototype.play=function(a,b,c){var e,g;g=this.player(a);try{this.fire(b,c),this.isFireworksFinished(c)&&this.recoverHints()}catch(h){if(e=h,!(e instanceof d))throw e;if(console.log("explosion",e),this.discardedFireworks.push(b),this.explosions=this.explosions+1,f.MAX_EXPLOSION<=this.explosions)throw e}return this.deck.isEmpty()||g.takeCard(this.deck),this.nextTurn()},f.prototype.discard=function(a,b){var c;return c=this.player(a),console.log("Hanabi#discard",c.name,b),this.discardedFireworks.push(b),console.log(this.discardedFireworks),this.recoverHints(),this.deck.isEmpty()||c.takeCard(this.deck),this.nextTurn()},f.prototype.hint=function(){return this.loseHint(),this.nextTurn()},f.prototype.loseHint=function(){return this.hints=this.hints-1},f.prototype.fire=function(a,b){var c;if(!this.isFireworksStared(b)&&1===a.number||(null!=(c=this.lastFireworks(b))?c.number:void 0)===a.number-1)return this.fireworks[b].push(a);throw new d},f.prototype.isFireworksStared=function(a){return 0!==this.fireworks[a].length},f.prototype.isFireworksFinished=function(a){return 5===this.fireworks[a].length},f.prototype.isGameOver=function(){return this.lastTurnCount>=this.players.length},f.prototype.lastFireworks=function(a){return _.last(this.fireworks[a])},f.prototype.recoverHints=function(){return this.hints<f.MAX_HINT?this.hints=this.hints+1:void 0},f.prototype.nextPlayer=function(){return this.players[this.turn%this.players.length]},f.prototype.nextTurn=function(){if(this.deck.isEmpty()&&this.lastTurnCountUp(),this.isGameOver())throw e;return this.currentPlayer=this.nextPlayer(),this.currentPlayer.trigger("turn",{canHints:0!==this.hints}),this.turn=this.turn+1},f.prototype.lastTurnCountUp=function(){return this.lastTurnCount=this.lastTurnCount+1},f.prototype.serialize=function(){var a,b,c,d,e,f,g;console.log("Hanabi#serialize"),b={},f=this.fireworks;for(c in f)e=f[c],b[c]=function(){var b,d,e,f;for(e=this.fireworks[c],f=[],b=0,d=e.length;d>b;b++)a=e[b],f.push(a.serialize());return f}.call(this);return{started:this.started,players:function(){var a,b,c,e;for(c=this.players,e=[],a=0,b=c.length;b>a;a++)d=c[a],e.push(d.serialize());return e}.call(this),currentPlayerName:null!=(g=this.currentPlayer)?g.name:void 0,turn:this.turn,deck:this.deck.serialize(),hints:this.hints,explosions:this.explosions,fireworks:b,lastTurnCount:this.lastTurnCount,discardedFireworks:function(){var b,c,d,e;for(d=this.discardedFireworks,e=[],b=0,c=d.length;c>b;b++)a=d[b],e.push(a.serialize());return e}.call(this)}},f.load=function(d){var e,g,i,j,k,l,m;for(console.log("Hanabi.load",d),i=new f,i.started=d.started,i.players=function(){var a,b,c,e;for(c=d.players,e=[],a=0,b=c.length;b>a;a++)j=c[a],e.push(h.load(j));return e}(),d.currentPlayerName&&(i.currentPlayer=i.login(d.currentPlayerName)),i.turn=d.turn,i.deck=c.load(d.deck),i.hints=d.hints,i.explosions=d.explosions,i.fireworks={},m=b.SINGLE_COLORS,k=0,l=m.length;l>k;k++)g=m[k],i.fireworks[g]=function(){var b,c,f,h;for(f=d.fireworks[g],h=[],b=0,c=f.length;c>b;b++)e=f[b],h.push(a.load(e));return h}();return i.lastTurnCount=d.lastTurnCount,i.discardedFireworks=function(){var b,c,f,g;for(f=d.discardedFireworks,g=[],b=0,c=f.length;c>b;b++)e=f[b],g.push(a.load(e));return g}(),i},f}(),g=function(){function a(a,b){var c=this;this.PubNub=a,this.roomName=b,this.initialized=!1,this.connected=!1,this.PubNub.subscribe({channel:this.roomName,restore:!1,disconnect:function(){return console.log("PubNub disconnected")},reconnect:function(){return console.log("PubNub re-connected")},connect:function(){return console.log("PubNub connected"),c.connected=!0}},function(a){var b,d;switch(d=a.eventName,b=a.data,console.log("event",d,b),d){case"ping":return c.pong()&&c.sync();case"pong":return c.clearHanabiSetupTimeoutId();case"sync":return c.restore(b)}})}return a.prototype.clearHanabiSetupTimeoutId=function(){return console.log("clearHanabiSetupTimeoutId"),this.hanabiSetupTimeoutId?clearTimeout(this.hanabiSetupTimeoutId):void 0},a.prototype.connect=function(a){var b=this;return this.hanabiInitializedCallback=a,console.log("connect"),this.connectIntervalId=setInterval(function(){return console.log("connect interval"),b.connected?(clearInterval(b.connectIntervalId),b.hanabiSetupTimeoutId=setTimeout(function(){return console.log("connect timeout"),b.setup(),b.hanabiInitializedCallback()},1e3),b.ping()):void 0},100)},a.prototype.ping=function(){return console.log("ping"),this.publish("ping")},a.prototype.pong=function(){return this.initialized?(console.log("pong"),this.publish("pong"),!0):void 0},a.prototype.sync=function(){return this.publish("sync",this.hanabi.serialize())},a.prototype.setup=function(){return console.log("setup"),this.initialized=!0,this.hanabi=new f},a.prototype.restore=function(a){return console.log("restore",a),this.hanabi=f.load(a),this.hanabi.listenPlayerEvents(),this.initialized?void 0:(this.initialized=!0,this.hanabiInitializedCallback())},a.prototype.publish=function(a,b){return console.log("publish",a,b),this.PubNub.publish({channel:this.roomName,message:{eventName:a,data:b}})},a}(),angular.module("hanabiApp").controller("MainCtrl",["$scope","$PubNub",function(a,c){return a.Color=b,a.roomName="geeaki",a.playerName="hanachin",a.loggedIn=!1,a.login=function(){return a.loggedIn?void 0:(console.log("$scope.login"),a.loggedIn=!0,a.hanabiRoom=new g(c,a.roomName),a.hanabiRoom.connect(function(){return a.$apply(function(){return a.hanabiRoom.hanabi.login(a.playerName),a.hanabiRoom.sync()})}))},a.start=function(){return a.hanabiRoom.hanabi.start(),a.hanabiRoom.sync()},a.play=function(b){return a.hanabiRoom.hanabi.player(a.playerName).play(b),a.hanabiRoom.sync()},a.playRainbow=function(b,c){return console.log("rainbow",c),a.hanabiRoom.hanabi.player(a.playerName).play(b,c),a.hanabiRoom.sync()},a.discard=function(b){return console.log("discard",a.playerName),a.hanabiRoom.hanabi.player(a.playerName).discard(b),a.hanabiRoom.sync()},a.tellColor=function(b,c){return a.hanabiRoom.hanabi.player(a.playerName).tellColor(b,c),a.hanabiRoom.sync()},a.tellNumber=function(b,c){return a.hanabiRoom.hanabi.player(a.playerName).tellNumber(b,c),a.hanabiRoom.sync()}}])}.call(this);