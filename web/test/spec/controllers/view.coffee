'use strict'

describe 'Controller: ViewCtrl', () ->

  # load the controller's module
  beforeEach module 'tilemapApp'

  ViewCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    ViewCtrl = $controller 'ViewCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3;
