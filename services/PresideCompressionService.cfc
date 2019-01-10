/**
 * @singleton true
 *
 */
component {

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	/**
	 * Compresses an input string
	 *
	 * @input String to compress
	 */
	public any function compress( required string input ) {
		if ( !Len( Trim( arguments.input ) ) ) {
			return "";
		}

		var baOs = CreateObject( "java", "java.io.ByteArrayOutputStream" );
		var gzOs = CreateObject( "java", "java.util.zip.GZIPOutputStream" ).init( baOs );

		gzOs.write( arguments.input.getBytes( "UTF-8" ) );
		gzOs.flush();
		gzOs.close();

		var compressed = "__pc__:" & ToBase64( baOs.toByteArray() );

		if ( Len( compressed ) < Len( arguments.input ) ) {
			return compressed;
		}

		return arguments.input;
	}

	/**
	 * Decompresses an input string
	 *
	 * @input string to decompress
	 */
	public string function decompress( required any input ) {
		if ( !input.startsWith( "__pc__:" ) ) {
			return arguments.input;
		}

		var compressed = ToBinary( input.reReplace( "^__pc__\:", "" ) );
		var baIs       = CreateObject( "java", "java.io.ByteArrayInputStream" ).init( compressed );
		var gzIs       = CreateObject( "java", "java.util.zip.GZIPInputStream" ).init( baIs );

		return CreateObject( "java", "org.apache.commons.io.IOUtils" ).toString( gzIs );
	}
}