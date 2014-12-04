angular.module('AgileProxy').directive('appResponseEditor', function () {
    return {
        restrict: 'EA',
        replace: true,
        templateUrl: '/ui/app/view/responses/editForm.html',
        scope: {
            response: '=ngModel'
        }, controller: function ($scope) {
            var aceInstance, beautifiers;
            beautifiers = {
                'json': function () {
                    $scope.response.content = JSON.stringify(JSON.parse($scope.response.content), null, 4);
                }
            };
            angular.extend($scope, {
                hasBeautifier: hasBeautifier(),
                aceMode: contentTypeToAceMode($scope.response.contentType),
                onAceLoaded: function (instance) {
                    aceInstance = instance;
                },
                reformat: function () {
                    var type;
                    type = contentTypeToAceMode($scope.response.contentType);
                    if (beautifiers.hasOwnProperty(type)) {
                        beautifiers[type].apply($scope, []);
                    }
                },
                onContentTypeChange: function (contentType) {

                    var type = contentTypeToAceMode(contentType);
                    aceInstance.getSession().setMode('ace/mode/' + type);
                    $scope.hasBeautifier = (beautifiers.hasOwnProperty(type));
                }
            });
            function contentTypeToAceMode(contentType) {
                switch (contentType) {
                    case "application/json":
                        return 'json';
                    case "application/javascript":
                        return 'javascript';
                    case "text/html":
                        return 'html';
                    case "text/plain":
                        return "plain_text";
                    default:
                        return "plain_text";
                }
            }
            function hasBeautifier() {
                return beautifiers.hasOwnProperty(contentTypeToAceMode($scope.response.contentType));
            }
        }
    };
});