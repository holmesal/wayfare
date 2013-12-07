'use strict'

describe 'Controller: GenerateCtrl', () ->

  # load the controller's module
  beforeEach module 'tilemapApp'

  GenerateCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    GenerateCtrl = $controller 'GenerateCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3;
