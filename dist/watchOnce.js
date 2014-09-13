(function() {
  var wrap,
    __slice = [].slice;

  wrap = function(listener, toDo, deferUntilDefined, isDefined) {
    return _.wrap(toDo, function() {
      var args, originalFn, value, valueIsDefined;
      originalFn = arguments[0], value = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      valueIsDefined = isDefined(value);
      if (deferUntilDefined && !valueIsDefined) {
        return;
      }
      originalFn.call.apply(originalFn, [this, value].concat(__slice.call(args)));
      if (valueIsDefined) {
        return listener.cleanup();
      }
    });
  };

  angular.module('ngWatchOnce', []).constant('ngWatchOnceConfig', {
    decorator: true
  }).config(function($provide) {
    return $provide.decorator('$rootScope', function($delegate, ngWatchOnceConfig, $watchOnce, $watchCollectionOnce) {
      if (ngWatchOnceConfig.decorator) {
        $delegate.$watchOnce = function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return $watchOnce.apply(null, [this].concat(__slice.call(args)));
        };
        $delegate.$watchCollectionOnce = function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return $watchCollectionOnce.apply(null, [this].concat(__slice.call(args)));
        };
      }
      return $delegate;
    });
  }).value('$watchCollectionOnce', function($scope, toWatch, toDo, deepWatch, deferUntilDefined, allowEmpty) {
    var listener;
    listener = {};
    return listener.cleanup = $scope.$watchCollection(toWatch, wrap(listener, toDo, deferUntilDefined, function(value) {
      return (value != null) && (allowEmpty || (value != null ? value.length : void 0) > 0);
    }), deepWatch);
  }).value('$watchOnce', function($scope, toWatch, toDo, deepWatch, deferUntilDefined) {
    var listener;
    listener = {};
    return listener.cleanup = $scope.$watch(toWatch, wrap(listener, toDo, deferUntilDefined, function(value) {
      return value != null;
    }), deepWatch);
  });

}).call(this);
