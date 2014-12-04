angular.module('AgileProxy').directive('appFor', function (DomIdService) {
    return {
        restrict: 'A',
        link: function (scope, element, attrs) {
            var inputElement;
            inputElement = element.parent().find('[name="' + attrs.appFor + '"]').first();
            if (!inputElement) {
                return;
            }
            if (!inputElement.attr('id')) {
                inputElement.attr('id', DomIdService.nextId());
            }
            element.attr('for', inputElement.attr('id'));
        }
    };
});