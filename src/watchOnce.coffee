wrap = (listener, toDo, invokeAlways, isDefined) ->
	return _.wrap toDo, (originalFn, value, args...)->
		valueIsDefined = isDefined(value)
		# allow for the watch callback to defer until the value is defined
		if not invokeAlways and not valueIsDefined then return
		originalFn.call(this, value, args...)
		if valueIsDefined then listener.cleanup() # clear the watch

angular.module('ngWatchOnce.decorator', ['ngWatchOnce'])
.config ($provide)->
	$provide.decorator '$rootScope', ($delegate, $watchOnce, $watchCollectionOnce)->
		$delegate.$watchOnce = (args...)-> return $watchOnce(@, args...)
		$delegate.$watchCollectionOnce = (args...)-> return $watchCollectionOnce(@, args...)
		return $delegate

angular.module('ngWatchOnce', [])
.value '$watchCollectionOnce', ($scope, toWatch, toDo, deepWatch, invokeAlways, allowEmpty)->
	listener = {}
	return listener.cleanup = $scope.$watchCollection(
		toWatch
		wrap(listener, toDo, invokeAlways, (value)-> return value? and (allowEmpty or value?.length > 0))		
		deepWatch
	)

.value '$watchOnce', ($scope, toWatch, toDo, deepWatch, invokeAlways)->
	listener = {}
	return listener.cleanup = $scope.$watch(
		toWatch
		wrap(listener, toDo, invokeAlways, (value)-> return value?)		
		deepWatch
	)


