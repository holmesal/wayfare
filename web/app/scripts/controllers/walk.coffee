'use strict'

angular.module('tilemapApp')
  .controller 'WalkCtrl', ($scope, $routeParams, angularFire) ->

	$scope.precision = 8

	init = ->
		# Get the current location
		console.log $routeParams.hash
		if $routeParams.hash
			$scope.hash = $routeParams.hash
		else
			navigator.geolocation.getCurrentPosition showPosition

	showPosition = (position) ->
		console.log position
		$scope.$apply ->
			$scope.position = position

	hover = () ->
		console.log 'hi!'

	init()
