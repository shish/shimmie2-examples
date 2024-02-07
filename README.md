# shimmie2-examples

the shimmie2-examples repo needs to be checked out adjacent to a shimmie2 checkout

`docker compose up` will then run some configurations:

* http://localhost:4080 - nginx + remote php-fpm
* http://localhost:4081 - lighttpd + local php-fpm
* http://localhost:4082 - varnish (caching proxy in front of nginx)

## Other Examples
* Apache - https://github.com/intergalacticmonkey/shimmie2-apache-docker/

