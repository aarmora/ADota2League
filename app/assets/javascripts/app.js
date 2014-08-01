var blogApp = angular.module('blogApp', []);

blogApp.controller('blogController', function ($scope, $http){
	$http.get('http://pipes.yahoo.com/pipes/pipe.run?_id=0fb06177cb147ba19962305ab987cf3e&_render=json').success(function(posts){
		$scope.posts = posts.value.items
		console.log(posts)
	});
});