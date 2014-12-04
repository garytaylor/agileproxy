angular.module('AgileProxy').factory('ErrorService', function (DialogService) {
    return {
        serverError: function (response) {
            DialogService.error('Server Error', response.statusText);
        }
    };
});