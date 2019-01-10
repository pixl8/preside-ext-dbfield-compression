component extends="coldbox.system.Interceptor" {

	property name="presideFieldCompressionService" inject="delayedInjector:presideFieldCompressionService";

// PUBLIC
	public void function configure() {}

	public void function preUpdateObjectData( event, interceptData ) {
		if ( !isFeatureEnabled( "fieldCompression" ) ) {
			return;
		}

		var objectName = interceptData.objectName ?: "";
		interceptData.data = presideFieldCompressionService.compressData(
			  objectName = objectName
			, data       = interceptData.data ?: {}
		);
	}

	public void function preInsertObjectData( event, interceptData ) {
		if ( !isFeatureEnabled( "fieldCompression" ) ) {
			return;
		}

		var objectName = interceptData.objectName ?: "";
		interceptData.data = presideFieldCompressionService.compressData(
			  objectName = objectName
			, data       = interceptData.data ?: {}
		);
	}

	public void function postSelectObjectData( event, interceptData ) {
		if ( !isFeatureEnabled( "fieldCompression" ) ) {
			return;
		}

		if ( IsQuery( interceptData.result ?: "" ) && interceptData.result.recordCount ) {
			interceptData.result = presideFieldCompressionService.decompressRecordset(
				  objectName   = interceptData.objectName   ?: ""
				, selectFields = interceptData.selectFields ?: []
				, recordSet    = interceptData.result
			);
		}
	}
}
