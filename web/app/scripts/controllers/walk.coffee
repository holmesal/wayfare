'use strict'

angular.module('tilemapApp')
  .controller 'WalkCtrl', ($scope, angularFire) ->

	$scope.precision = 8

	init = ->
		# Get the current location
		navigator.geolocation.getCurrentPosition showPosition

	showPosition = (position) ->
		console.log position
		$scope.$apply ->
			$scope.position = position

	hover = () ->
		console.log 'hi!'

	init()
