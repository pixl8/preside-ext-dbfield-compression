component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "compress()", function(){
			it( "should compress value using gzip", function(){
				var service    = _getService();
				var input      = FileRead( "/fixtures/largishInput.html" );
				var expected   = "__pc__:" & ToBase64( FileReadBinary( "/fixtures/largishInputCompressed.html.gz" ) );
				var compressed = service.compress( input );

				expect( compressed ).toBe( expected );
			} );

			it( "should return an empty string if the input is empty", function(){
				var service   = _getService();
				var input     = "";

				expect( service.compress( "" ) ).toBe( "" );
			} );

			it( "should return original string if compression turns out a larger string", function(){
				var service    = _getService();
				var input      = "abcdefg";
				var compressed = service.compress( input );

				expect( compressed ).toBe( input );
			} );
		} );

		describe( "decompress()", function(){
			it( "should do nothing when string is not in preside compressed format", function(){
				var service      = _getService();
				var input        = "abcdefg";
				var decompressed = service.decompress( input );

				expect( decompressed ).toBe( input );
			} );

			it( "should decompress input that has been compressed with the compress function", function(){
				var service    = _getService();
				var input      = FileRead( "/fixtures/largishInput.html" );
				var compressed = service.compress( input );

				expect( compressed != input ).toBeTrue();
				expect( Len( compressed ) < Len( input ) ).toBeTrue();

				expect( service.decompress( compressed ) ).toBe( input );
			} );
		} );
	}

// private helpers
	private any function _getService(){
		var service = CreateMock( object=new compression.services.PresideCompressionService() );

		return service;
	}

}