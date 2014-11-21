
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

        var cleanList = function(list) {
            return _.uniq(_.compact(list));
        };

        var filterArray = function(dataSet, configKey) {
            return cleanList(_.map(dataSet, function(item) {
                var key = item[$scope.config.keys[configKey]];
                return key ? key.basicInfo : null;
            }));
        };

        var orderArray = function(mainKey, subKey, nameKey) {
            var keys = $scope.config.keys;
            var hasMainKey = function(value) { return value[keys[mainKey]]; };
            var hasSubKey = function(value) { return value[keys[subKey]]; };
            var data = _.filter($scope.data.parsed, hasMainKey);

            return _(data)
                .map(function(value) { return value[keys[mainKey]].basicInfo; })
                .uniq()
                .sortBy()
                .map(function(category) {
                    var matchesCategory = function(value) { return value[keys[mainKey]].basicInfo === category; };

                    return {
                        _name: category,
                        _children: _(data)
                            .filter(hasSubKey)
                            .filter(matchesCategory)
                            .map(function(value) { return value[keys[subKey]].basicInfo; })
                            .uniq()
                            .sortBy()
                            .map(function(objectKey) {
                                return _.assign({
                                    _name: objectKey,
                                    _children: _(data)
                                        .filter(hasSubKey)
                                        .filter(matchesCategory)
                                        .filter(function(value) { return value[keys[subKey]].basicInfo === objectKey; })
                                        .reject(function(value) { return value[keys[nameKey]] && value[keys[nameKey]].basicInfo === objectKey; })
                                        .each(function(value) { value._props = $scope.propsAsArray(value); })
                                        .value()
                                }, _.findWhere(data, function(item) {
                                    return item[keys[mainKey]].basicInfo === category &&
                                        item[keys[subKey]] &&
                                        item[keys[subKey]].basicInfo === objectKey &&
                                        item[keys[nameKey]] &&
                                        item[keys[nameKey]].basicInfo === objectKey;
                                }));
                            })
                            .value()
                    };
                })
                .value();
        };

        $http.get('config.json')
            .success(function(data) {
                $scope.config = data;

                $http.get('output.json')
                    .success(function(data) {
                        $scope.data = data;
                    });
            });

        $scope.$watch('data', function(newVal, oldVal) {
            if(newVal === oldVal) return;

            $scope.categories = filterArray($scope.data.parsed, 'category');
            $scope.orderedData = orderArray('category', 'mainType', 'subType');
        });
    }])

    .controller('Content', ['$scope', '$stateParams', '$state', function($scope, $stateParams, $state) {
        $scope.urlParams = $stateParams;
        $scope._ = window._;

        $scope.contentFilter = {};

        if($scope.urlParams.category) $scope.contentFilter[$scope.$parent.config.keys.category] = $scope.urlParams.category;
        if($scope.urlParams.mainType) $scope.contentFilter[$scope.$parent.config.keys.mainType] = $scope.urlParams.mainType;
        if($scope.urlParams.subType)  $scope.contentFilter[$scope.$parent.config.keys.subType]  = $scope.urlParams.subType;

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