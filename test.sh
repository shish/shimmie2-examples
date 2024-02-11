#!/bin/bash
set -eu

function t {
	echo -n "$1 (niceurl)... "
	if [ "$(curl --silent "$2/nicetest")" == "ok" ] ; then
		echo ok
	else
		echo "fail ($2)"
	fi

	echo -n "$1 (uglyurl)... "
	if [ "$(curl --silent "$2/index.php?q=nicetest")" == "ok" ] ; then
		echo ok
	else
		echo "fail ($2)"
	fi

	echo -n "$1 (static files)... "
	if curl --silent -I "$2/themes/default/style.css" | grep -q "max-age=86400" ; then
		echo ok
	else
		echo "fail ($2)"
	fi

	echo -n "$1 (niceslash)... "
	if [ "$(curl --silent "$2/nicedebug/foo%2Fbar/1")" == '{"args":["nicedebug","foo%2Fbar","1"]}' ] ; then
		echo ok
	else
		echo "fail ($2)"
	fi

	echo -n "$1 (uglyslash)... "
	if [ "$(curl --silent "$2/index.php?q=nicedebug/foo%2Fbar/1")" == '{"args":["nicedebug","foo%2Fbar","1"]}' ] ; then
		echo ok
	else
		echo "fail ($2)"
	fi

}
t "nginx root" http://localhost:4010
t "nginx subdir" http://localhost:4011/gallery
t "lighttpd root" http://localhost:4020
t "lighttpd subdir" http://localhost:4021/gallery
t "varnish -> nginx root" http://localhost:4030
t "apache root" http://localhost:4040
t "apache subdir" http://localhost:4041/gallery
