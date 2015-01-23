
angular.module('doks', ['mgcrea.ngStrap', 'ui.router', 'ui.select', 'ncy-angular-breadcrumb', 'ngSanitize'])

    .config(['$stateProvider', '$locationProvider', '$urlRouterProvider', function($stateProvider, $locationProvider, $urlRouterProvider) {
        $locationProvider.hashPrefix('!');

        $urlRouterProvider.otherwise('/');

        $stateProvider
            .state('root', {
                url: '/',
                controller: 'Content',
                templateUrl: 'views/main-content.html',
                ncyBreadcrumb: {
                    label: 'Home'
                }
            })
            .state('hasCategory', {
                url: '/:category',
                controller: 'Content',
                templateUrl: 'views/main-content.html',
                ncyBreadcrumb: {
                    parent: 'root',
                    label: '{{urlParams.category}}'
                }
            })
            .state('hasMainType', {
                url: '/:category/:mainType',
                controller: 'Content',
                templateUrl: 'views/main-content.html',
                ncyBreadcrumb: {
                    parent: 'hasCategory',
                    label: '{{urlParams.mainType}}'
                }
            })
            .state('hasSubType', {
                url: '/:category/:mainType/:subType',
                controller: 'Content',
                templateUrl: 'views/main-content.html',
                ncyBreadcrumb: {
                    parent: 'hasMainType',
                    label: '{{urlParams.subType}}'
                }
            })
    }])

    .controller('Page', ['$scope', '$http', function($scope, $http) {
        $scope._ = window._;

        //no need to display these, they are templated elsewhere
        $scope.ignoredProperties = ['lineNumber', 'endLineNumber', 'filePath', 'fileName', 'desc', '$$hashKey'];

        $scope.propsAsArray = function(obj) {
            return _(obj)
                .omit($scope.ignoredProperties)
                .keys()
                .sortBy()
                .map(function(key) {
                    var ret = [];
                    if(_.isArray(obj[key])) {
                        _.each(obj[key], function(item) {
                            ret.push({name: key, value: item});
                        })
                    } else {
                        ret.push({name: key, value: obj[key]});
                    }
                    return ret;
                })
                .flatten()
                .value()
        };

        $scope.isCategory = function(dok) {
            return !dok[$scope.config.keys.subType];
        };

        $scope.getLinkFromData = function(dok) {
            if(!dok) return "";
            return $scope.config.options.content.sourceLink
                .split('%lineNumber').join(dok.lineNumber)
                .split('%endLineNumber').join(dok.endLineNumber)
                .split('%filePath').join(dok.filePath);
        };

        var filterArray = function(dataSet) {
            return _.pluck(dataSet, '_name');
        };

        $http.get('config.json')
            .success(function(data) {
                $scope.config = data;

                $http.get('output.json')
                    .success(function(data) {
                        $scope.data = data;
                        $scope.flatData = _.flatten(_.flatten($scope.data.parsed, '_children'), '_children');
                        _.each($scope.flatData, function(data) {
                            data._props = $scope.propsAsArray(data);
                        });
                        $scope.categories = filterArray($scope.data.parsed);
                    });
            });
    }])

    .controller('Content', ['$scope', '$stateParams', '$state', '$location', function($scope, $stateParams, $state, $location) {
        $scope.urlParams = $stateParams;
        $scope.pageParams = $location.search();
        $scope._ = window._;

        $scope.contentFilter = {};

        if($scope.urlParams.category) $scope.contentFilter[$scope.$parent.config.keys.category] = $scope.urlParams.category;
        if($scope.urlParams.mainType) $scope.contentFilter[$scope.$parent.config.keys.mainType] = $scope.urlParams.mainType;
        if($scope.urlParams.subType)  $scope.contentFilter[$scope.$parent.config.keys.subType]  = $scope.urlParams.subType;

        $scope.checkItemVisibility = function(category, mainType, item) {
            var filter = $scope.pageParams.filter;
            if(!filter) {
                return true;
            }
            filter = filter.toLowerCase();
            return category._name.toLowerCase().indexOf(filter) !== -1 || mainType._name.toLowerCase().indexOf(filter) !== -1 || item[$scope.config.keys.subType].basicInfo.toLowerCase().indexOf(filter) !== -1;
        };

        $scope.doFilter = function($item) {
            var category = $item[$scope.config.keys.category];
            var mainType = $item[$scope.config.keys.mainType];
            var subType  = $item[$scope.config.keys.subType];
            if(subType) {
                $state.go('hasSubType', {subType: subType.basicInfo, mainType: mainType.basicInfo, category: category.basicInfo});
            } else if(mainType) {
                $state.go('hasMainType', {mainType: mainType.basicInfo, category: category.basicInfo});
            } else {
                $state.go('hasCategory', {category: category.basicInfo});
            }
        };

        $scope.getLowestSort = function() {
            return function(object) {
                var value = object[$scope.$parent.config.keys.subType];
                return value ? value.basicInfo : null;
            };
        };

        $scope.getParentSort = function() {
            return function(object) {
                var value = object[$scope.$parent.config.keys.mainType];
                return value ? value.basicInfo : null;
            };
        };
    }]);
