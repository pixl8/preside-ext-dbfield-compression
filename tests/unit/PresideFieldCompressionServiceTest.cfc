component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "compressData()", function(){
			it( "should compress just compressable fields for the given object and input data struct", function(){
				var service = _getService();
				var object  = "test_object_" & CreateUUId();
				var compressedFields = [ "test", "passphrase" ];
				var data = {
					  test        = "me"
					, id          = CreateUUId()
					, passphrase  = "tested"
					, dateCreated = Now()
				};
				var compressed = {
					  test = CreateUUId()
					, passphrase = CreateUUId()
					, id = data.id
					, dateCreated = data.dateCreated
				};

				service.$( "$isFeatureEnabled" ).$args( "fieldCompression" ).$results( true );
				service.$( "listCompressedFields" ).$args( object ).$results( compressedFields );
				mockCompressionService.$( "compress" ).$args( data.test ).$results( compressed.test );
				mockCompressionService.$( "compress" ).$args( data.passphrase ).$results( compressed.passphrase );

				expect( service.compressData( object, data ) ).toBe( compressed );
			} );

			it( "should not compress data if the fieldCompression feature is not enabled", function(){
				var service = _getService();
				var object  = "test_object_" & CreateUUId();
				var compressedFields = [ "test", "passphrase" ];
				var data    = {
					  test        = "me"
					, id          = CreateUUId()
					, passphrase  = "tested"
					, dateCreated = Now()
				};

				service.$( "$isFeatureEnabled" ).$args( "fieldCompression" ).$results( false );
				service.$( "listCompressedFields" ).$args( object ).$results( compressedFields );
				mockCompressionService.$( "compress" ).$args( data.test ).$results( data.test );
				mockCompressionService.$( "compress" ).$args( data.passphrase ).$results( data.passphrase );

				expect( service.compressData( object, data ) ).toBe( data );
			} );
		} );

		describe( "decompressRecordset()", function(){
			it( "should decompress compressable fields from a selectData() call", function(){
				var service      = _getService();
				var selectFields = [ "blah", "test", "datecreated" ];
				var objectName   = "test_me";
				var recordset    = QueryNew( 'blah,test,pass,datecreated', 'varchar,varchar,varchar,date', [
					  [ "hello1", "world1", "test1", Now() ]
					, [ "hello2", "world2", "test2", Now() ]
					, [ "hello3", "world3", "test3", Now() ]
				] );
				var expected = QueryNew( 'blah,test,pass,datecreated', 'varchar,varchar,varchar,date', [
					  [ "decompressedblah1", "world1", "decompressedpass1", recordset.datecreated[1] ]
					, [ "decompressedblah2", "world2", "decompressedpass2", recordset.datecreated[2] ]
					, [ "decompressedblah3", "world3", "decompressedpass3", recordset.datecreated[3] ]
				] );

				service.$( "$isFeatureEnabled" ).$args( "fieldCompression" ).$results( true );
				service.$( "listDecompressableFieldsFromSelectFields" ).$args( objectName, selectFields ).$results( [ "blah", "pass" ] );
				for( var i=1; i<=recordset.recordCount; i++ ) {
					mockCompressionService.$( "decompress" ).$args( recordset.blah[ i ] ).$results( "decompressedblah#i#" );
					mockCompressionService.$( "decompress" ).$args( recordset.pass[ i ] ).$results( "decompressedpass#i#" );
				}

				var decompressed = service.decompressRecordset(
					  objectName   = objectName
					, selectFields = selectFields
					, recordset    = recordset
				);

				expect( decompressed ).toBe( expected );
			} );

			it( "should not decompress data from a selectData() call if fieldCompression feature is not enabled", function(){
				var service      = _getService();
				var selectFields = [ "blah", "test", "datecreated" ];
				var objectName   = "test_me";
				var recordset    = QueryNew( 'blah,test,pass,datecreated', 'varchar,varchar,varchar,date', [
					  [ "hello1", "world1", "test1", Now() ]
					, [ "hello2", "world2", "test2", Now() ]
					, [ "hello3", "world3", "test3", Now() ]
				] );

				service.$( "$isFeatureEnabled" ).$args( "fieldCompression" ).$results( false );
				service.$( "listDecompressableFieldsFromSelectFields" ).$args( objectName, selectFields ).$results( [ "blah", "pass" ] );
				for( var i=1; i<=recordset.recordCount; i++ ) {
					mockCompressionService.$( "decompress" ).$args( recordset.blah[ i ] ).$results( recordset.blah[ i ] );
					mockCompressionService.$( "decompress" ).$args( recordset.pass[ i ] ).$results( recordset.blah[ i ] );
				}

				var decompressed = service.decompressRecordset(
					  objectName   = objectName
					, selectFields = selectFields
					, recordset    = recordset
				);

				expect( decompressed ).toBe( recordset );
			} );
		} );

		describe( "objectUsesCompression", function(){
			it( "should return true when object present in list of compressable objects", function(){
				var service    = _getService();
				var objectName = "test_object_" & CreateUUId();
				var compressedObjects = [ "fubar", objectName, "test" ];

				service.$( "listCompressedObjects", compressedObjects )

				expect( service.objectUsesCompression( objectName ) ).toBe( true );
			} );
			it( "should return false when object not present in list of compressable objects", function(){
				var service    = _getService();
				var objectName = "test_object_" & CreateUUId();
				var compressedObjects = [ "fubar", "test" ];

				service.$( "listCompressedObjects", compressedObjects )

				expect( service.objectUsesCompression( objectName ) ).toBe( false );
			} );
		} );

		describe( "listCompressedObjects()", function(){
			it( "should return array of object names for objects that use compression", function(){
				var service = _getService();
				var objects = [ "object_a", "object_b", "object_c", "object_d" ];

				mockPresideObjectService.$( "listObjects", objects );
				service.$( "listCompressedFields" ).$args( "object_a" ).$results( [] );
				service.$( "listCompressedFields" ).$args( "object_b" ).$results( [ "password" ] );
				service.$( "listCompressedFields" ).$args( "object_c" ).$results( [] );
				service.$( "listCompressedFields" ).$args( "object_d" ).$results( [ "test", "password", "salt" ] );


				expect( service.listCompressedObjects() ).toBe( [ "object_b", "object_d" ] );
			} );
		} );

		describe( "listCompressedFields()", function(){
			it( "should return an array of field names for a given object that use compression", function(){
				var service    = _getService();
				var objectName = "test_object_" & CreateUUId();
				var props      = {
					  name        = { name="name", compress=true }
					, id          = { name="id" }
					, datecreated = { name="id", compress=false }
					, passphrase  = { name="passphrase", compress=true }
				};

				mockPresideObjectService.$( "objectExists"        ).$args( objectName ).$results( true  );
				mockPresideObjectService.$( "getObjectProperties" ).$args( objectName ).$results( props );

				expect( service.listCompressedFields( objectName ).sort( "textnocase") ).toBe( [ "name", "passphrase" ] );
			} );
		} );

		describe( "listDecompressableFieldsFromSelectFields()", function() {
			it( "should parse fields and relationships and return bare list of fields that should be decompressed", function(){
				var service = _getService();
				var objectName = "some_object_" & CreateUUId();
				var selectFields = [ "datecreated", "#objectName#.id", "test", "related_field$some_thing.some_property", "another.propertyhere" ];
				var relatedObjects = [ "object_a", "object_b" ];

				mockRelationshipGuidance.$( "resolveRelationshipPathToTargetObject" ).$args(
					  sourceObject     = objectName
					, relationshipPath = "related_field$some_thing"
				).$results( relatedObjects[ 1 ] );

				mockRelationshipGuidance.$( "resolveRelationshipPathToTargetObject" ).$args(
					  sourceObject     = objectName
					, relationshipPath = "another"
				).$results( relatedObjects[ 2 ] );

				service.$( "listCompressedFields" ).$args( objectName ).$results( [ "test", "another" ] );
				service.$( "listCompressedFields" ).$args( relatedObjects[ 1 ] ).$results( [ "some_property" ] );
				service.$( "listCompressedFields" ).$args( relatedObjects[ 2 ] ).$results( [] );

				expect( service.listDecompressableFieldsFromSelectFields( objectName, selectFields ).sort( "textnocase" ) ).toBe( [ "some_property", "test" ] );
			} );
		} );
	}

// private helpers
	private any function _getService(){
		mockCompressionService   = CreateEmptyMock( "compression.services.PresideCompressionService" );
		mockRelationshipGuidance = CreateStub();

		var service = CreateMock( object=new compression.services.PresideFieldCompressionService(
			  compressionService   = mockCompressionService
			, relationshipGuidance = mockRelationshipGuidance
		) );

		mockPresideObjectService = CreateStub();
		service.$( "$getPresideObjectService", mockPresideObjectService );

		return service;
	}

}