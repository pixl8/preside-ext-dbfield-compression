component {

	public void function configure( required struct config ) {
		var conf     = arguments.config;
		var settings = conf.settings ?: {};

		_configureFeatures( settings );
		_configureInterceptors( conf );
	}

// PRIVATE HELPERS
	private void function _configureFeatures( settings ) {
		settings.features.fieldCompression.enabled = true;
	}

	private void function _configureInterceptors( conf ) {
		conf.interceptors.append( { class="app.extensions.preside-ext-dbfield-compression.interceptors.DbFieldCompressionInterceptor", properties={} } );
	}
}
