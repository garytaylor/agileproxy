angular.module('AgileProxy').factory('DomIdService', function () {
    var nextIdNumber;
    return {
        nextId: function () {
            nextIdNumber = nextIdNumber || 0;
            nextIdNumber = nextIdNumber + 1;
            return 'element-' + nextIdNumber;
        }
    };
});