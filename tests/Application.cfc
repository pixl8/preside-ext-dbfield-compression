component {
	this.name = "Compression Test Suite";

	this.mappings[ '/tests'       ] = ExpandPath( "/" );
	this.mappings[ '/testbox'     ] = ExpandPath( "/testbox" );
	this.mappings[ '/fixtures'    ] = ExpandPath( "/fixtures" );
	this.mappings[ '/compression' ] = ExpandPath( "../" );

	setting requesttimeout=60000;
}
