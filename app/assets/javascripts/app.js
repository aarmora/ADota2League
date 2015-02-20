var blogApp = angular.module('blogApp', ['ngSanitize']);

var soloApp = angular.module('soloApp', [])

soloApp.controller('soloController', ['$scope', '$http', function ($scope, $http){
	$scope.chosenPlayers = [];
	$scope.selectSeason = function(){
		$http({
			url: '/solo_leagues_json/get_players',
			method: 'GET',
			params: {season_id: $scope.new.season, round:$scope.new.round}
		}).success(function(data){
			console.log(data);
			$scope.players = data;
			$scope.playersToPick = angular.copy(data);
		});
	};

	$scope.pickPlayer = function(player, position){
		player = JSON.parse(player);
		playerToAdd = {};
		playerToAdd.position = position;
		playerToAdd.name = player.name;
		playerToAdd.id = player.id

		$scope.chosenPlayers.push(playerToAdd);
	};

	$scope.submitMatch = function(){
		var toSend = []
		angular.forEach($scope.chosenPlayers, function(e){
			toSend.push(e.id);
		});	
		$http({
			url: '/solo_leagues_json/create_match',
			method: 'GET',
			params: {players: [toSend], round:$scope.new.round, season_id:$scope.new.season}
		}).success(function(data){
			$('form')[0].reset();
		});
	}
}]);

blogApp
.controller('blogController', ['$scope', '$http', function ($scope, $http){
	$http.get('http://pipes.yahoo.com/pipes/pipe.run?_id=0fb06177cb147ba19962305ab987cf3e&_render=json').success(function(posts){
		$scope.posts = posts.value.items
	});
}]);