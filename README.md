angular-watch-once
=============
'Watch once' feature for AngularJS scopes and controllers.

### Usage

```bower install angular-watch-once```

Add ```'ngWatchOnce'``` or ```'ngWatchOnce.decorator'```(to decorate scopes w/ $watchOnce) as a dependency to your module or application.

#### Example
##### In a Controller
```
angular.module('myApp', ['ngWatchOnce']).controller('MyCtrl', function($scope, $watchOnce, $log){
	$watchOnce($scope, 'myData', function(myData){
		$log.info("I will only be called once when 'myData' is defined and non-null");		
	});
})
```

##### Using the Scope Decorator
```
angular.module('myApp', ['ngWatchOnce.decorator']).controller('MyCtrl', function($scope, $log){
	$scope.$watchOnce('myData', function(myData){
		$log.info("I will only be called once when 'myData' is defined and non-null");	
	});
})
```

### Overview
```ngWatchOnce``` provides two functions which can be optionally decorated on all $scopes. When scopes are decorated, all functions drop the first argument and infer the scope when invoked (ie ```$watchOnce(scope, args...)``` vs ```$scope.$watchOnce(args...)```). Once the value of their watched expressions evaluates as defined and non-null, the ```$watch``` is removed from the scope.

```$watchOnce(scope, expression, listener, [objectEquality], [alwaysInvoke] )```
  * Adds the optional ```alwaysInvoke``` boolean option (defaults to false). If true, the listener will be invoked even if the value of the expression is undefined. The $watch listener will still be removed once the value is defined.

```$watchCollectionOnce(scope, expression, listener, [objectEquality], [alwaysInvoke], [allowEmpty] )```
  * Adds the optional ```allowEmpty``` boolean option (defaults to false). If true, the listener will consider the expression defined even if the array evaluated by the expression is empty.
