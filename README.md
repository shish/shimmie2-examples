# shimmie2-examples

A collection of example config files for running shimmie in an optimised way with
various different web servers.

The shimmie2-examples repo needs to be checked out adjacent to a shimmie2 checkout,
ie each of these example web servers are configured to load the app from `../shimmie2/`

With the two repos checked out, `docker compose up` will run some configurations:

* http://localhost:4080 - nginx + remote php-fpm
* http://localhost:4081 - lighttpd + local php-fpm
* http://localhost:4082 - varnish (caching proxy in front of nginx)
* http://localhost:4090/gallery - nginx with subdir
* http://localhost:4091/gallery - lighttpd with subdir

## Testing

`./test.sh` will test, for each configuration:

* niceurls work (`/nicetest` returns "ok")
* uglyurls work (`/index.php?q=/nicetest` returns "ok")
* cache headers work (static files should be cached for one day)

## Other Examples
* Apache - https://github.com/intergalacticmonkey/shimmie2-apache-docker/

