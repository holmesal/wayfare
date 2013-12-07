'use strict'

angular.module('tilemapApp')
  .controller 'GenerateCtrl', ($scope, $resource, angularFire) ->

	$scope.position = null
	$scope.nodes = {}
	$scope.roads = []
	$scope.toDraw = {}

	$scope.world = {}

	# Convert current position to a geohash with the right precision
	# Get the height and width of the geohash in degrees
	# Convert the height and width into meters, to find the number of 1-m tiles in the box
	# Make a bounding box and search OSM
	# Do the rest of the drawing etc as is

	$scope.hash = 
		n: 7 #height is about 26 meters in Boston
		dims: {}


	showPosition = (position) ->
		# TODO - take this shit out
		console.log position
		$scope.$apply ->
			$scope.position = position
		getGeoHash()
		initFirebase ->
			getHashDims()
			makeBbox()
			getData $scope.bbox
		

	getGeoHash = ->
		$scope.hash.original = GeoHasher.encode $scope.position.coords.latitude, $scope.position.coords.longitude

		# Cut to 8 digits for 36x19m size (at equator, this changes)
		$scope.$apply ->
			$scope.hash.box = $scope.hash.original[0...$scope.hash.n]
			#["drt2ugzb", "drt2ugz9", "drt2ugzc", "drt2v5b1", "drt2v5b0", "drt2v58p", "drt2ugxz", "drt2ugxx", "drt2ugz8"]
			# $scope.hash.box = 'drt2ugz8'
			console.log $scope.hash

	initFirebase = (resolver) ->
		# ref = new Firebase "https://wander.firebaseio.com/world/#{$scope.hash.box}"
		# p = angularFire ref, $scope, 'world'
		# p.then resolver
		resolver()

	getHashDims = ->
		parity = if $scope.hash.n%2 is 0 then 0 else 1
		console.log parity
		exp = (5 * $scope.hash.n - parity) / 2
		height = 180 / Math.pow(2, exp)
		exp = (5 * $scope.hash.n - parity - 1) / 2
		width = 180 / Math.pow(2, exp)

		$scope.hash.dims.degrees = 
			x: width
			y: height

		# How many meters in a degree of lat/lon at this latitude?
		rlat = $scope.position.coords.latitude * Math.PI / 180
		mLat = 111132.92 - 559.82 * Math.cos(2*rlat) + 1.175*Math.cos(4*rlat)
		mLon = 111412.84 * Math.cos(rlat) - 93.5 * Math.cos(3*rlat)

		# Convert dims
		# Do I want to round this here or later on?
		$scope.hash.dims.meters = 
			x: Math.round $scope.hash.dims.degrees.x * mLon
			y: Math.round $scope.hash.dims.degrees.y * mLat

		console.log $scope.hash.dims.meters

	makeBbox = () ->
		clat = $scope.position.coords.latitude
		clon = $scope.position.coords.longitude

		$scope.world.center = 
			lat: clat
			lon: clon

		# Get the BBOX center
		decoded = GeoHasher.decode $scope.hash.box
		# console.log ctr
		# width = 0.000575
		bbox = 
			clat: decoded.latitude[1]
			clon: decoded.longitude[1]
			minlat: Math.min.apply Math, decoded.latitude
			maxlat: Math.max.apply Math, decoded.latitude
			minlon: Math.min.apply Math, decoded.longitude
			maxlon: Math.max.apply Math, decoded.longitude
		$scope.bbox = bbox

		console.log bbox

	
	init = ->
		# Get the current location
		navigator.geolocation.getCurrentPosition showPosition

	getData = (bbox) ->
		url = 'http://overpass-api.de/api/interpreter'
		# url = 'http://overpass.osm.rambler.ru/cgi'
		# q = '[out:json];<osm-script><query into="_" type="node"><has-kv k="amenity" modv="" v="drinking_water"/><bbox-query e="12.503793239593506" into="_" n="41.8941474761023" s="41.881735516015105" w="12.486820220947266"/></query><print from="_" limit="" mode="body" order="id"/></osm-script>'
		# q = 'http://overpass-api.de/api/interpreter?data=%28node%5B%22amenity%22%3D%22drinking%5Fwater%22%5D%2841%2E88116038605262%2C12%2E486820220947266%2C41%2E894722489158454%2C12%2E503793239593506%29%3B%29%3Bout%20body%3B%0A'
		# This query is for drinking water, I think
		# q = '(node["amenity"="drinking_water"](41.88116038605262,12.486820220947266,41.894722489158454,12.503793239593506););out body;'
		# Get all ways within a box
		# Order is [lowerlat,lowerlon,upperlat,upperlon]
		bboxString = "#{bbox.minlat},#{bbox.minlon},#{bbox.maxlat},#{bbox.maxlon}"
		# q = 'way(50.746,7.154,50.748,7.157);out body;'
		# q = "(node(42.33935324923419,-71.14869475364685,42.340949225891876,-71.14657312631607);rel(bn)->.x;way(42.33935324923419,-71.14869475364685,42.340949225891876,-71.14657312631607);node(w)->.x;rel(bw););out body;"
		q = "(node(#{bboxString});rel(bn)->.x;way(#{bboxString});node(w)->.x;rel(bw););out body;"
		console.log q
		GeoData = $resource url
		data = GeoData.get
			data: "[out:json];#{q}"
		, parseData

	parseData = (data) ->
		# Grab roads, and ignore everything else
		console.log data
		console.groupCollapsed 'Ignoring elements'
		for thing in data.elements
			if thing.type is 'node'
				$scope.nodes[thing.id] = thing
				console.log thing
			else if thing.type is 'way'
				if thing.tags?.highway
					$scope.roads.push thing
				else
					
					console.log "ignoring #{JSON.stringify(thing.tags)}"
		console.groupEnd()

		# Set normalized coordinates
		for id, node of $scope.nodes
			node = normalize node

		# Set, so the directive picks it up
		$scope.toDraw =
			dims: $scope.hash.dims.meters
			nodes: $scope.nodes
			roads: $scope.roads

	normalize = (item) ->
		item.y = ($scope.bbox.maxlat - item.lat) / $scope.hash.dims.degrees.y
		item.x = (item.lon - $scope.bbox.minlon) / $scope.hash.dims.degrees.x
		# console.log "#{item.x}, #{item.y}"

	$scope.updateworld = (tiles) ->
		console.log 'got update request'
		console.log tiles

		# Send to firebase
		$scope.world.meta = 
			dims: $scope.hash.dims.meters
			bbox: $scope.bbox
		$scope.world.tiles = tiles



	init()