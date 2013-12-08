'use strict'

angular.module('tilemapApp', [
	'ngCookies',
	'ngResource',
	'ngSanitize',
	'ngRoute',
	'firebase'
])
	.config ($routeProvider) ->
		$routeProvider
			.when '/',
				templateUrl: 'views/main.html'
				controller: 'MainCtrl'
			# .when '/generate',
			# 	templateUrl: 'views/generate.html'
			# 	controller: 'GenerateCtrl'
			# .when '/view',
			#   templateUrl: 'views/view.html',
			#   controller: 'ViewCtrl'
			.when '/walk/:hash?',
			  templateUrl: 'views/walk.html',
			  controller: 'WalkCtrl'
			.otherwise
				redirectTo: '/'
