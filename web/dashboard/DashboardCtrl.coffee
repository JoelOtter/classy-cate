classy = angular.module 'classy'

classy.factory 'Dashboard', (CateResource, $rootScope) ->
  class Dashboard extends CateResource('/api/dashboard')
    @get: ->
      promise = super
      promise.then (res) ->
        $rootScope.available_years = res.available_years
      return promise



classy.controller 'DashboardCtrl', ($scope, Dashboard) ->
  Dashboard.get().then (dash) ->
    $scope.dashboard = dash
