describe 'ngWatchOnce.decorator', ->
	describe '$rootScope decorator', ->
		beforeEach ->
			module 'ngWatchOnce.decorator'

		it 'should decorate the $rootScope when configured', ->
			inject (@$rootScope)->
			expect(@$rootScope.$watchOnce).toBeDefined()
			expect(@$rootScope.$watchCollectionOnce).toBeDefined()

		it 'should inherit $watchOnce through child scopes', ()->
			inject (@$rootScope)->
			scope = @$rootScope.$new()
			expect(scope.$watchOnce).toBeDefined()
			expect(scope.$watchCollectionOnce).toBeDefined()

		it 'should invoke $watchOnce', ->
			$watchOnce = jasmine.createSpy('$watchOnce')
			module {
				'$watchOnce': $watchOnce
			}
			inject (@$rootScope)->
			scope = @$rootScope.$new()
			scope.$watchOnce('expression', 'toDo', 'deepWatch', 'always')
			expect($watchOnce).toHaveBeenCalledWith(scope, 'expression', 'toDo', 'deepWatch', 'always')

		it 'should invoke $watchCollectionOnce', ->
			$watchCollectionOnce = jasmine.createSpy('$watchCollectionOnce')
			module {
				'$watchCollectionOnce': $watchCollectionOnce
			}
			inject (@$rootScope)->
			scope = @$rootScope.$new()
			scope.$watchCollectionOnce('expression', 'toDo', 'deepWatch', 'always')
			expect($watchCollectionOnce).toHaveBeenCalledWith(scope, 'expression', 'toDo', 'deepWatch', 'always')

describe 'ngWatchOnce', ->

	describe '$watchCollectionOnce', ->

		beforeEach ->
			module 'ngWatchOnce'
			inject (@$watchCollectionOnce, $rootScope)-> @$scope = $rootScope.$new()
			@callback = jasmine.createSpy('change callback')

		it 'should defer invoking the callback if specified', ->
			always = false
			@$scope.property = null
			@$watchCollectionOnce @$scope, 'property', @callback, false, always
			@$scope.$digest()
			expect(@callback).not.toHaveBeenCalled()
			@$scope.property = ['foo']
			@$scope.$digest()
			expect(@callback).toHaveBeenCalledWith(['foo'], undefined, @$scope)

		it 'should defer invoking the callback if specified and the collection is not allowed to be empty', ->
			always = false
			allowEmpty = false
			@$scope.property = []
			@$watchCollectionOnce @$scope, 'property', @callback, false, always, allowEmpty
			@$scope.$digest()
			expect(@callback).not.toHaveBeenCalled()
			@$scope.property = ['foo']
			@$scope.$digest()
			expect(@callback).toHaveBeenCalledWith(['foo'], undefined, @$scope)

		it 'should invoke the callback on property changes', ->
			always = true
			@$scope.property = ['foo']
			@$watchCollectionOnce @$scope, 'property', @callback, false, always
			@$scope.$digest()
			expect(@callback).toHaveBeenCalledWith(['foo'], ['foo'], @$scope)

		it 'should invoke the callback if the collection is allowed to be empty', ->
			always = true
			allowEmpty = true
			@$scope.property = []
			@$watchCollectionOnce @$scope, 'property', @callback, false, always, allowEmpty
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
			always = false
			@$scope.property = null
			@$watchOnce @$scope, 'property', @callback, false, always
			@$scope.$digest()
			expect(@callback).not.toHaveBeenCalled()
			@$scope.property = 'foo'
			@$scope.$digest()
			expect(@callback).toHaveBeenCalledWith('foo', null, @$scope)

		it 'should invoke the callback on property changes', ->
			always = true
			@$scope.property = 'foo'
			@$watchOnce @$scope, 'property', @callback, false, always
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
