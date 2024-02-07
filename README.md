# shimmie2-examples

the shimmie2-examples repo needs to be checked out adjacent to a shimmie2 checkout,
ie each of these example web servers are configured to load the app from `../shimmie2/`

With the two repos checked out, `docker compose up` will run some configurations:

* http://localhost:4080 - nginx + remote php-fpm
* http://localhost:4081 - lighttpd + local php-fpm
* http://localhost:4082 - varnish (caching proxy in front of nginx)

## Other Examples
* Apache - https://github.com/intergalacticmonkey/shimmie2-apache-docker/

