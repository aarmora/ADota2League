var blogApp = angular.module('blogApp', [])

blogApp.controller('blogController', ['$scope, $http'], function($scope, $http){
	$scope.pizza = "sword";
});