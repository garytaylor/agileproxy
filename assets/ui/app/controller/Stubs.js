angular.module('AgileProxy').controller('StubsCtrl', function ($resource, $scope, DialogService, StubService, RequestSpecModel, ErrorService) {
    var selection;
    $scope.selection = {};
    $scope.selectionCount = 0;
    angular.extend($scope, {
        editStub: function (stub) {
            StubService.editStub(stub, $scope).then(function (obj) {
                obj.stub.$save().$then(function (stub) {
                    obj.close();
                },
                    function (response) {
                        ErrorService.serverError(response);
                    }
                )
            });
        },
        deleteStub: function (stub) {
            DialogService.yesNo('Delete this stub ?').then(function (response) {
                stub.$destroy({id: stub.id});
            });
        },
        addStub: function () {
            StubService.addStub($scope).then(function(obj) {
                obj.stub.$save().$then(function (stub) {
                    obj.close();
                },
                    function (response) {
                        ErrorService.serverError(response);
                    }
                );
            });
        },
        updateSelection: function (stub) {
            if (stub.$isSelected) {
                $scope.addToSelection(stub);
            } else {
                $scope.removeFromSelection(stub);
            }
        },
        addToSelection: function (stub) {
            $scope.selection[stub.id] = true;
            $scope.onSelectionChange();
        },
        removeFromSelection: function (stub) {
            delete $scope.selection[stub.id];
            $scope.onSelectionChange();
        },
        deleteSelection: function () {
            var s;
            s = $scope.selection;
            debugger;

        },
        onSelectionChange: function () {
            $scope.selectionCount = Object.keys($scope.selection).length;
        },
        emptySelection: function () {

        }
    });
    $scope.requestSpecs = RequestSpecModel.$collection({});
    $scope.requestSpecs.$refresh()

});