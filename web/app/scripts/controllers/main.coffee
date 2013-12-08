'use strict'

angular.module('tilemapApp')
  .controller 'MainCtrl', ($scope, $resource, angularFire) ->

    console.log 'main controller loaded'

    $scope.hash = "drt2yyy0"