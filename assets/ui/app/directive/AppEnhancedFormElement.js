angular.module('AgileProxy').directive('appEnhancedFormElement', function ($rootScope, $compile, DomIdService) {
    return {
        restrict: 'A',
        scope: true,
        link: function (scope, element, attrs) {
            var label, localScope;
            if (element.attr('id') === undefined) {
                element.attr('id', DomIdService.nextId());
            }
            localScope = $rootScope.$new(true);
            angular.extend(localScope, {
                elementId: element.attr('id'),
                labelText: attrs.label
            });
            label = $compile('<label class="control-label" for="elementId">{{labelText}}</label>')(localScope);
            element.wrap('<div class="form-group">');
            element.parent().prepend(label);

        }
    };
});