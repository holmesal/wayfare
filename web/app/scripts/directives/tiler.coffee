'use strict'

angular.module('tilemapApp')
  .directive('tiler', ($timeout) ->
    template: '<canvas id="myCanvas" style="width:{{canvas.width}}px;height:{{canvas.height}}px;"></canvas>'
      # '<canvas id="myCanvas"></canvas><div class="viewer"><div class="tile" ng-repeat="tile in tiles" style="background-color:rgb({{tile.value}},0,0); background-image:url({{tile.image}}); width:{{dims.tile}}px; height:{{dims.tile}}px;">&nbsp</div></div>'
    restrict: 'E'
    scope:
      draw: '='
      updateworld: '='
    link: (scope, element, attrs) ->
      scope.size = 12

      # element.text 'this is the canvas directive'
      
      
      

      scope.$watch 'draw', ->
        console.log scope.draw
        if scope.draw.nodes # Make sure there's something there
          scope.size = scope.draw.dims.x
          canvas = element.find('canvas')[0]
          canvas.width = scope.draw.dims.x
          canvas.height = scope.draw.dims.y
          scope.ctx = canvas.getContext '2d'
          scope.ctx.strokeStyle="#FF0000"
          scope.ctx.lineWidth = 1;
          init()

      init = ->

        # scope.dims = 
        #   viewer: element.find('.viewer')[0].clientWidth
        # scope.dims.tile = scope.dims.viewer / scope.draw.dims.x

        # Draw the initial huge tileset
        tiles = []
        for idx in [0...scope.draw.dims.x*scope.draw.dims.y]
          tiles[idx] = 
            id: idx
            type: 0

        scope.tiles = tiles

        console.log scope.tiles.length

        

        # Make up some vectors
        # vectors = [
        #   [
        #     [0,0.1],
        #     [0.5,0.6],
        #     [0.9,0.9],
        #     [0.7,0.1],
        #     [0.1,0.9]
        #   ]
        # ]

        # Do the thing
        drawVectors()

        # Get the data
        parseCanvas()

        

        # $timeout ->

        #   vectors = [
        #     [
        #       [-1,0.5],
        #       [1,0.6]
        #     ]
        #   ]

        #   # Do the thing
        #   drawVectors vectors

        #   # Get the data
        #   parseCanvas()
        # , 10000

      # ctx.beginPath()
      # ctx.moveTo 3, -2
      # ctx.lineTo 9.5, 9.5
      # ctx.stroke()

      

      # console.dir element.find('.viewer')[0]

      

      # $timeout ->
      #   for tile in scope.tiles
      #     tile.value = 127 if tile.value is 255
      # , 10000


      


      drawVectors = (vectors) ->

        for road in scope.draw.roads
          scope.ctx.beginPath()
          # scope.ctx.moveTo vector[0][0]*scope.size, vector[0][1]*scope.size # First point in vector
          for node_id,idx in road.nodes
            node = scope.draw.nodes[node_id]
            if idx is 0 # Only move for first element
              scope.ctx.moveTo node.x*scope.draw.dims.x, node.y*scope.draw.dims.y
            else # skip first point
              scope.ctx.lineTo node.x*scope.draw.dims.x, node.y*scope.draw.dims.y
          scope.ctx.stroke()


      parseCanvas = ->
        data = scope.ctx.getImageData 0,0,scope.draw.dims.x,scope.draw.dims.y

        flat = (num for num in data.data by 4)

        tiles = []
        for num,idx in flat
          tile = 
            id: idx
          if num > 0
            # tile.image = "http://i.imgur.com/eqpOX.png"
            tile.type = 'road'
          else
            # tile.image = "http://minecraft-cube.comuv.com/textures/grass-top.png"
            tile.type = 'grass'
          tiles[idx] = tile

        console.log tiles

        scope.tiles = tiles

        scope.updateworld tiles


      # init()

      



      # for point, idx in data.data
      #   if point isnt 0
      #     data.data[idx] = 255

      # console.log data

      # ctx.putImageData data, 0, 0

  )
