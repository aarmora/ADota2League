if (typeof(angular) != "undefined") {
  var blogApp = angular.module('blogApp', ['ngSanitize']);

  blogApp
  .controller('blogController', ['$scope', '$http', function ($scope, $http){
  	$http.get('http://pipes.yahoo.com/pipes/pipe.run?_id=0fb06177cb147ba19962305ab987cf3e&_render=json').success(function(posts){
  		$scope.posts = posts.value.items
  	});
  }]);
}