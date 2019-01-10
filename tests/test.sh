#!/bin/bash

cd `dirname $0`

exitcode=0

if [[ ! -d ./testbox ]] ; then
	box install
fi
box stop name="compressiontests"
box start serverConfigFile="./server-compression-tests.json"
box testbox run verbose=true || exitcode=1
box stop name="compressiontests"

exit $exitcode
