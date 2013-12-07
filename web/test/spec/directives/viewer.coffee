'use strict'

describe 'Directive: viewer', () ->
  beforeEach module 'tilemapApp'

  element = {}

  it 'should make hidden element visible', inject ($rootScope, $compile) ->
    element = angular.element '<viewer></viewer>'
    element = $compile(element) $rootScope
    expect(element.text()).toBe 'this is the viewer directive'
