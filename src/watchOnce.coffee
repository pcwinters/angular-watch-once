wrap = (listener, toDo, deferUntilDefined, isDefined) ->
	return _.wrap toDo, (originalFn, value, args...)->
		valueIsDefined = isDefined(value)
		# allow for the watch callback to defer until the value is defined
		if deferUntilDefined and not valueIsDefined then return
		originalFn.call(this, value, args...)
		if valueIsDefined then listener.cleanup() # clear the watch

angular.module('ngWatchOnce', [])

.constant 'ngWatchOnceConfig',
	decorator: true

.config ($provide)->
	$provide.decorator '$rootScope', ($delegate, ngWatchOnceConfig, $watchOnce, $watchCollectionOnce)->
		if ngWatchOnceConfig.decorator
			$delegate.$watchOnce = (args...)-> return $watchOnce(@, args...)
			$delegate.$watchCollectionOnce = (args...)-> return $watchCollectionOnce(@, args...)
		return $delegate

.value '$watchCollectionOnce', ($scope, toWatch, toDo, deepWatch, deferUntilDefined, allowEmpty)->
	listener = {}
	return listener.cleanup = $scope.$watchCollection(
		toWatch
		wrap(listener, toDo, deferUntilDefined, (value)-> return value? and (allowEmpty or value?.length > 0))		
		deepWatch
	)

.value '$watchOnce', ($scope, toWatch, toDo, deepWatch, deferUntilDefined)->
	listener = {}
	return listener.cleanup = $scope.$watch(
		toWatch
		wrap(listener, toDo, deferUntilDefined, (value)-> return value?)		
		deepWatch
	)


