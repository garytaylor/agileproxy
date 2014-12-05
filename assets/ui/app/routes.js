angular.module('AgileProxy').config(function ($routeProvider) {
    $routeProvider.when('/status', {
        templateUrl: '/ui/app/view/status.html'
    }).when('/stubs', {
        templateUrl: '/ui/app/view/stubs.html',
        controller: 'StubsCtrl'
    }).otherwise({
        templateUrl: '/ui/app/view/stubs.html',
        controller: 'StubsCtrl'
    })
});