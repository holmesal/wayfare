{parseString} = require 'xml2js'
debug = require 'debug'

# Get data from osm
# Normalize to grid coordinates - 0 to 100
# Convert to json
# Send to client

# CLIENT
# Get osm dictionary from server
# Draw onto canvas, bottom to top, using integers from dictionary
# Loop through canvas pixels and get integer values
# AT FIRST
# Apply textures from wander dictionary
# So much wow
# LATER
# Loop through canvas pixels, push onto array
# Send back to server for storage

class Tile
	constructor: (xml) ->
		@log = debug 'tile'

		@log 'new tile constructed!'
		parseString xml, (err, res) =>
			@osm = res.osm
			@log 'parsed to xml'
			@json = JSON.stringify @osm
			@log 'converted to json'
			@parse()

	parse: ->
		for k, v of @osm
			console.log k


module.exports = 
	Tile: Tile