'use strict'

angular.module('tilemapApp')
  .controller 'MainCtrl', ($scope, $resource, angularFire) ->

    console.log 'main controller loaded'