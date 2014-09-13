describe 'ngWatchOnce', ->

	describe 'ngWatchOnceConfig', ->

		it 'should default to decorating the $rootScope', ->
			module 'ngWatchOnce'
			inject (@ngWatchOnceConfig)->
			expect(@ngWatchOnceConfig.decorator).toBeTruthy()

	describe '$rootScope decorator', ->
		beforeEach ->
			angular.module('test.ngWatchOnce.decorator.true', []).config (ngWatchOnceConfig)->
				ngWatchOnceConfig.decorator = true
			angular.module('test.ngWatchOnce.decorator.false', []).config (ngWatchOnceConfig)->
				ngWatchOnceConfig.decorator = false
				
		it 'should not decorate the $rootScope when configured', ->
			module 'ngWatchOnce'
			module 'test.ngWatchOnce.decorator.false'
			inject (@$rootScope)->
			expect(@$rootScope.$watchOnce).not.toBeDefined()
			expect(@$rootScope.$watchCollectionOnce).not.toBeDefined()

		it 'should decorate the $rootScope when configured', ->
			module 'ngWatchOnce'
			module 'test.ngWatchOnce.decorator.true'
			inject (@$rootScope)->
			expect(@$rootScope.$watchOnce).toBeDefined()
			expect(@$rootScope.$watchCollectionOnce).toBeDefined()

		it 'should inherit $watchOnce through child scopes', ()->
			module 'ngWatchOnce'
			module 'test.ngWatchOnce.decorator.true'
			inject (@$rootScope)->
			scope = @$rootScope.$new()
			expect(scope.$watchOnce).toBeDefined()
			expect(scope.$watchCollectionOnce).toBeDefined()

		it 'should invoke $watchOnce', ->
			$watchOnce = jasmine.createSpy('$watchOnce')
			module 'ngWatchOnce'
			module 'test.ngWatchOnce.decorator.true'
			module {
				'$watchOnce': $watchOnce
			}
			inject (@$rootScope)->
			scope = @$rootScope.$new()
			scope.$watchOnce('expression', 'toDo', 'deepWatch', 'defer')
			expect($watchOnce).toHaveBeenCalledWith(scope, 'expression', 'toDo', 'deepWatch', 'defer')

		it 'should invoke $watchCollectionOnce', ->
			$watchCollectionOnce = jasmine.createSpy('$watchCollectionOnce')
			module 'ngWatchOnce'
			module 'test.ngWatchOnce.decorator.true'
			module {
				'$watchCollectionOnce': $watchCollectionOnce
			}
			inject (@$rootScope)->
			scope = @$rootScope.$new()
			scope.$watchCollectionOnce('expression', 'toDo', 'deepWatch', 'defer')
			expect($watchCollectionOnce).toHaveBeenCalledWith(scope, 'expression', 'toDo', 'deepWatch', 'defer')

	describe '$watchCollectionOnce', ->

		beforeEach ->
			module 'ngWatchOnce'
			inject (@$watchCollectionOnce, $rootScope)-> @$scope = $rootScope.$new()
			@callback = jasmine.createSpy('change callback')

		it 'should defer invoking the callback if specified', ->
			defer = true
			@$scope.property = null
			@$watchCollectionOnce @$scope, 'property', @callback, false, defer
			@$scope.$digest()
			expect(@callback).not.toHaveBeenCalled()
			@$scope.property = ['foo']
			@$scope.$digest()
			expect(@callback).toHaveBeenCalledWith(['foo'], undefined, @$scope)

		it 'should defer invoking the callback if specified and the collection is not allowed to be empty', ->
			defer = true
			allowEmpty = false
			@$scope.property = []
			@$watchCollectionOnce @$scope, 'property', @callback, false, defer, allowEmpty
			@$scope.$digest()
			expect(@callback).not.toHaveBeenCalled()
			@$scope.property = ['foo']
			@$scope.$digest()
			expect(@callback).toHaveBeenCalledWith(['foo'], undefined, @$scope)

		it 'should invoke the callback on property changes', ->
			defer = false
			@$scope.property = ['foo']
			@$watchCollectionOnce @$scope, 'property', @callback, false, defer
			@$scope.$digest()
			expect(@callback).toHaveBeenCalledWith(['foo'], ['foo'], @$scope)

		it 'should invoke the callback if the collection is allowed to be empty', ->
			defer = false
			allowEmpty = true
			@$scope.property = []
			@$watchCollectionOnce @$scope, 'property', @callback, false, defer, allowEmpty
			@$scope.$digest()
			expect(@callback).toHaveBeenCalledWith([], [], @$scope)

		it 'should pass through to $scope.$watchCollection', ->
			@scope = jasmine.createSpyObj('$scope', ['$watchCollection'])
			@scope.$watchCollection.andCallFake (exp, @toDo)=>
				return @listener
			@$watchCollectionOnce @scope, 'expression', 'todo', 'deep'
			expect(@scope.$watchCollection).toHaveBeenCalledWith('expression', jasmine.any(Function), 'deep')

		describe 'when cleaning up the listener', ->
			
			beforeEach ->
				@listener = jasmine.createSpy('$watchCollection listener')
				@scope = jasmine.createSpyObj('$scope', ['$watchCollection'])
				@scope.$watchCollection.andCallFake (exp, @toDo)=>
					return @listener

			it 'should not clean up the listener when the collection is undefined', ->				
				@$watchCollectionOnce @scope, null, @callback
				@toDo()
				expect(@listener).not.toHaveBeenCalled()

			it 'should not clean up the listener when the collection is null', ->
				@$watchCollectionOnce @scope, null, @callback
				@toDo(null)
				expect(@listener).not.toHaveBeenCalled()

			it 'should clean up the listener when the collection is defined', ->
				@$watchCollectionOnce @scope, null, @callback
				@toDo('foo')
				expect(@listener).toHaveBeenCalled()

			it 'should clean up the listener if the collection is allowed to be empty', ->
				allowEmpty = true
				defer = false
				@$watchCollectionOnce @scope, null, @callback, false, defer, allowEmpty
				@toDo([])
				expect(@listener).toHaveBeenCalled()


	describe '$watchOnce', ->

		beforeEach ->
			module 'ngWatchOnce'
			inject (@$watchOnce, $rootScope)-> @$scope = $rootScope.$new()
			@callback = jasmine.createSpy('change callback')

		it 'should defer invoking the callback if specified', ->
			defer = true
			@$scope.property = null
			@$watchOnce @$scope, 'property', @callback, false, defer
			@$scope.$digest()
			expect(@callback).not.toHaveBeenCalled()
			@$scope.property = 'foo'
			@$scope.$digest()
			expect(@callback).toHaveBeenCalledWith('foo', null, @$scope)

		it 'should invoke the callback on property changes', ->
			defer = false
			@$scope.property = 'foo'
			@$watchOnce @$scope, 'property', @callback, false, defer
			@$scope.$digest()
			expect(@callback).toHaveBeenCalledWith('foo', 'foo', @$scope)

		it 'should pass through to $scope.$watch', ->
			@scope = jasmine.createSpyObj('$scope', ['$watch'])
			@scope.$watch.andCallFake (exp, @toDo)=>
				return @listener
			@$watchOnce @scope, 'expression', 'todo', 'deep'
			expect(@scope.$watch).toHaveBeenCalledWith('expression', jasmine.any(Function), 'deep')

		describe 'when cleaning up the listener', ->
			
			beforeEach ->
				@listener = jasmine.createSpy('$watch listener')
				@scope = jasmine.createSpyObj('$scope', ['$watch'])
				@scope.$watch.andCallFake (exp, @toDo)=>
					return @listener

			it 'should not clean up the listener when the value is undefined', ->				
				@$watchOnce @scope, null, @callback
				@toDo()
				expect(@listener).not.toHaveBeenCalled()

			it 'should not clean up the listener when the value is null', ->
				@$watchOnce @scope, null, @callback
				@toDo(null)
				expect(@listener).not.toHaveBeenCalled()

			it 'should clean up the listener when the value is defined', ->
				@$watchOnce @scope, null, @callback
				@toDo('foo')
				expect(@listener)	.toHaveBeenCalled()
