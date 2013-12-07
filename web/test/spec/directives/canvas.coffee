'use strict'

describe 'Directive: canvas', () ->

  # load the directive's module
  beforeEach module 'tilemapApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<canvas></canvas>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the canvas directive'
