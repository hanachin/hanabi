'use strict'

angular.module('hanabiApp', [
  'ngCookies'
  'ngResource'
  'ngSanitize'
  'ngRoute'
  'ui.bootstrap'
  'angular-pubnub'
])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .otherwise
        redirectTo: '/'
