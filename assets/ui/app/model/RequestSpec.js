angular.module('AgileProxy').config(function(restmodProvider) {
    restmodProvider.rebase('DefaultPacker');
});
angular.module('AgileProxy').factory('RequestSpecModel', function ($resource, restmod) {
    return restmod.model('/api/v1/users/1/applications/1/request_specs', 'AgileProxyApi');
});