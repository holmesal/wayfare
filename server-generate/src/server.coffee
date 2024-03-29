request = require 'request'
express = require 'express'
servlog = require('debug')('servlog')
{Populator} = require './populator'
{blocks} = require './blocks'


# {Tile} = require './tile'
# {parseString} = require 'xml2js'

app = express()

allowCrossDomain = (req, res, next) ->
	# Allow headers
	res.header 'Access-Control-Allow-Origin', '*'
	res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS'
	res.header 'Access-Control-Allow-Headers', 'Content-Type, Authorization, Content-Length, X-Requested-With'

	# Intercept options
	if req.method is 'OPTIONS'
		res.send 200
	else
		next()

app.configure ->
	app.use allowCrossDomain
	app.use express.bodyParser()

app.get '/', (req, res) ->
	res.end 'HELLO THERE.'

app.get '/blocks', (req, res) ->
	res.json blocks


app.get '/populate/:centerHash', (req, res) ->
	servlog "got population request for hash #{req.params.hash}"
	res.end 'ok'

	# Call the main population method
	new Populator req.params.centerHash

app.listen 80, ->
	servlog 'server started! woohoo!'
	# Fake a populator request
	# centerHash = 'drt2v5b0'
	# centerHash = 'drt2yyy0'
	centerHash = 'drt2yry5'
	new Populator centerHash
		