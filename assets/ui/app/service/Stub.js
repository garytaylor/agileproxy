angular.module('AgileProxy').factory('StubService', function ($modal, $q, $rootScope, RequestSpecModel) {
    return {
        addStub: function (scope) {
            var stub;
            stub = scope.requestSpecs.$build({httpMethod: 'GET', urlType: "url", response: {contentType: 'text/html', statusCode: 200}});
            return this.openEditor(stub, scope);
        },
        editStub: function (stub, scope) {
            return this.openEditor(stub, scope);
        },
        openEditor: function (stub, scope) {
            var modalInstance, localScope, deferred;
            function closeEditor() {
                modalInstance.close();
            }
            localScope = scope ? scope.$new() : $rootScope.$new();
            deferred = $q.defer();
            angular.extend(localScope, {
                stub: stub,
                onOk: function (stub) {
                    deferred.resolve({stub: stub, close: closeEditor});
                },
                onCancel: function (stub) {
                    closeEditor();
                    deferred.reject('User Cancelled', stub);
                }
            });
            modalInstance = $modal.open({
                templateUrl: '/ui/app/view/stubs/edit.html',
                size: 'lg',
                scope: localScope
            });
            return deferred.promise;
        }
    };
});