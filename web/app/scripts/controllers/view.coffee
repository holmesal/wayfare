'use strict'

angular.module('tilemapApp')
  .controller 'ViewCtrl', ($scope, angularFire) ->

	$scope.precision = 8

	init = ->
		# Get the current location
		navigator.geolocation.getCurrentPosition showPosition

	showPosition = (position) ->
		console.log position
		$scope.$apply ->
			$scope.position = position
		getGeoHash()
		# setupFirebase $scope.hash

	getGeoHash = ->
		hash = GeoHasher.encode $scope.position.coords.latitude, $scope.position.coords.longitude


		# Cut to 8 digits for 36x19m size (at equator, this changes)
		$scope.$apply ->
			$scope.hash = hash[0...$scope.precision]
		console.log hash

	init()
