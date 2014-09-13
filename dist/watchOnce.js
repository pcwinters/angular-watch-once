(function() {
  var wrap,
    __slice = [].slice;

  wrap = function(listener, toDo, invokeAlways, isDefined) {
    return _.wrap(toDo, function() {
      var args, originalFn, value, valueIsDefined;
      originalFn = arguments[0], value = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      valueIsDefined = isDefined(value);
      if (!invokeAlways && !valueIsDefined) {
        return;
      }
      originalFn.call.apply(originalFn, [this, value].concat(__slice.call(args)));
      if (valueIsDefined) {
        return listener.cleanup();
      }
    });
  };

  angular.module('ngWatchOnce.decorator', ['ngWatchOnce']).config(function($provide) {
    return $provide.decorator('$rootScope', function($delegate, $watchOnce, $watchCollectionOnce) {
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
      return $delegate;
    });
  });

  angular.module('ngWatchOnce', []).value('$watchCollectionOnce', function($scope, toWatch, toDo, deepWatch, invokeAlways, allowEmpty) {
    var listener;
    listener = {};
    return listener.cleanup = $scope.$watchCollection(toWatch, wrap(listener, toDo, invokeAlways, function(value) {
      return (value != null) && (allowEmpty || (value != null ? value.length : void 0) > 0);
    }), deepWatch);
  }).value('$watchOnce', function($scope, toWatch, toDo, deepWatch, invokeAlways) {
    var listener;
    listener = {};
    return listener.cleanup = $scope.$watch(toWatch, wrap(listener, toDo, invokeAlways, function(value) {
      return value != null;
    }), deepWatch);
  });

}).call(this);
