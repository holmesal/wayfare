'use strict'

describe 'Controller: WalkCtrl', () ->

  # load the controller's module
  beforeEach module 'tilemapApp'

  WalkCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    WalkCtrl = $controller 'WalkCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3;
