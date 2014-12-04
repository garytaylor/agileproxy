angular.module('AgileProxy').factory('DialogService', function ($modal, $q, $rootScope) {
    return {
        yesNo: function (message) {
            var modalInstance, localScope, deferred;
            localScope = $rootScope.$new(true);
            deferred = $q.defer();
            angular.extend(localScope, {
                message: message,
                yes: function () {
                    modalInstance.close();
                    deferred.resolve();

                },
                no: function () {
                    modalInstance.close();
                    deferred.reject('User Cancelled');
                }
            });
            modalInstance = $modal.open({
                templateUrl: '/ui/app/view/dialog/yesNo.html',
                size: 'lg',
                scope: localScope
            });
            return deferred.promise;


        },
        error: function (title, message) {
            var modalInstance, localScope, deferred;
            localScope = $rootScope.$new(true);
            deferred = $q.defer();
            angular.extend(localScope, {
                title: title,
                message: message,
                close: function () {
                    modalInstance.close();
                    deferred.resolve({});
                }
            });
            modalInstance = $modal.open({
                templateUrl: '/ui/app/view/dialog/error.html',
                size: 'lg',
                scope: localScope
            });
            return deferred.promise;

        }
    };
});