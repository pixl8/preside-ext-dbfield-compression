/**
 * @presideService true
 * @singleton      true
 */
component {

	variables._localCache = {};

// CONSTRUCTOR
	/**
	 * @compressionService.inject    presideCompressionService
	 * @relationshipGuidance.inject relationshipGuidance
	 *
	 */
	public any function init(
		  required any compressionService
		, required any relationshipGuidance
	) {
		_setCompressionService( arguments.compressionService );
		_setRelationshipGuidance( arguments.relationshipGuidance );

		return this;
	}

// PUBLIC API METHODS
	/**
	 * Compresses data before insert/update into the database
	 *
	 */
	public struct function compressData( required string objectName, required struct data ) {
		if ( !$isFeatureEnabled( "fieldCompression" ) ) {
			return arguments.data;
		}

		var compressedFields   = listCompressedFields( arguments.objectName );
		var compressionService = _getCompressionService();

		for( var field in compressedFields ) {
			if ( arguments.data.keyExists( field ) ) {
				arguments.data[ field ] = compressionService.compress( arguments.data[ field ] );
			}
		}

		return arguments.data;
	}

	/**
	 * Decompresses a recordset selected with SelectData()
	 *
	 */
	public query function decompressRecordset(
		  required string objectName
		, required array  selectFields
		, required query  recordSet
	) {
		if ( !$isFeatureEnabled( "fieldCompression" ) ) {
			return arguments.recordSet;
		}

		var compressedFields = listDecompressableFieldsFromSelectFields( arguments.objectName, arguments.selectFields );

		if ( compressedFields.len() ) {
			var compressionService = _getCompressionService();

			for( var field in compressedFields ) {
				for( var i=1; i<=arguments.recordSet.recordCount; i++ ) {
					arguments.recordSet[ field ][ i ] = compressionService.decompress( arguments.recordSet[ field ][ i ] );
				}
			}
		}

		return arguments.recordSet;
	}

	/**
	 * Returns an array of objects that have compressed fields
	 *
	 */
	public array function listCompressedObjects() {
		return _simpleLocalCache( "listCompressedObjects", function(){
			var allObjects = $getPresideObjectService().listObjects();
			var compressed = [];

			for( var objectName in allObjects ) {
				if ( listCompressedFields( objectName ).len() ) {
					compressed.append( objectname );
				}
			}

			return compressed;
		} );
	}

	/**
	 * Returns whether or not the given object has compressed
	 * fields
	 */
	public boolean function objectUsesCompression( required string objectName ) {
		var args = arguments;

		return _simpleLocalCache( "objectUsesCompression#arguments.objectName#", function(){
			return listCompressedObjects().findNoCase( args.objectName ) > 0;
		} );
	}


	/**
	 * Returns an array of fields for an object that are compressed
	 *
	 */
	public array function listCompressedFields( required string objectName ) {
		var args = arguments;

		if ( !$getPresideObjectService().objectExists( args.objectName ) ) {
			return [];
		}

		return _simpleLocalCache( "listCompressedFields#arguments.objectName#", function(){
			var allProps  = $getPresideObjectService().getObjectProperties( args.objectName );
			var compressed = [];

			for( var propName in allProps ) {
				var prop = allProps[ propName ];
				if ( IsBoolean( prop.compress ?: "" ) && prop.compress ) {
					compressed.append( propName );
				}
			}

			return compressed;
		} );
	}

	/**
	 * Returns an array of field names that are decompressable
	 * from a given selectFields array / objectname
	 */
	public array function listDecompressableFieldsFromSelectFields(
		  required string objectName
		, required array  selectFields
	) {
		var args = arguments;
		var cacheKey = "listDecompressableFieldsFromSelectFields" & arguments.objectName & SerializeJson( arguments.selectFields );

		return _simpleLocalCache( cacheKey, function(){
			var mappings    = {};
			var guidance    = _getRelationshipGuidance();
			var decompressable = [];

			for( var field in args.selectFields ) {
				var minusEscapeChars = field.reReplace( "[\`\[\]]", "", "all" );
				var fieldName    = ListLast( ListLast( minusEscapeChars, "." ), " " );
				var withoutAlias = ListFirst( minusEscapeChars, " " );
				var propName     = ListLast( withoutAlias, "." );

				if ( withoutAlias == propName || ListFirst( withoutAlias, "." ) == args.objectName ) {
					mappings[ args.objectName ] = mappings[ args.objectName ] ?: {};
					mappings[ args.objectName ][ propName ] = fieldname;
				} else {
					var relatedObject = guidance.resolveRelationshipPathToTargetObject(
						  sourceObject     = args.objectName
						, relationshipPath = ListFirst( withoutAlias, "." )
					);

					if ( relatedObject.len() ) {
						mappings[ relatedObject ] = mappings[ relatedObject ] ?: {};
						mappings[ relatedObject ][ propName ] = fieldname;
					}
				}
			}

			for( var objName in mappings ) {
				var compressedFields = listCompressedFields( objName );

				for( var propName in mappings[ objName ] ) {
					if ( compressedFields.findNoCase( propName ) ) {
						decompressable.append( mappings[ objName ][ propName ]);
					}
				}
			}

			return decompressable;
		} );
	}


// PRIVATE HELPERS
	private any function _simpleLocalCache( required string cacheKey, required any processor ) {
		if ( !_localCache.keyExists( arguments.cacheKey ) ) {
			_localCache[ arguments.cacheKey ] = arguments.processor();
		}

		return _localCache[ arguments.cacheKey ];
	}


// GETTERS AND SETTERS
	private any function _getCompressionService() {
		return _compressionService;
	}
	private void function _setCompressionService( required any compressionService ) {
		_compressionService = arguments.compressionService;
	}

	private any function _getRelationshipGuidance() {
		return _relationshipGuidance;
	}
	private void function _setRelationshipGuidance( required any relationshipGuidance ) {
		_relationshipGuidance = arguments.relationshipGuidance;
	}
}