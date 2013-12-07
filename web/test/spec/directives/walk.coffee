'use strict'

describe 'Directive: walk', () ->
  beforeEach module 'tilemapApp'

  element = {}

  it 'should make hidden element visible', inject ($rootScope, $compile) ->
    element = angular.element '<walk></walk>'
    element = $compile(element) $rootScope
    expect(element.text()).toBe 'this is the walk directive'
