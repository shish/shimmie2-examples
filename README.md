# shimmie2-examples

A collection of example config files for running shimmie in an optimised way with
various different web servers.

The shimmie2-examples repo needs to be checked out adjacent to a shimmie2 checkout,
ie each of these example web servers are configured to load the app from `../shimmie2/`

With the two repos checked out, `docker compose up` will run some configurations:

* http://localhost:4010 - nginx + remote php-fpm
* http://localhost:4011/gallery - nginx with subdir
* http://localhost:4020 - lighttpd + local php-fpm
* http://localhost:4021/gallery - lighttpd with subdir
* http://localhost:4030 - varnish (caching proxy in front of nginx)
* http://localhost:4040 - apache + mod\_php
* http://localhost:4041/gallery - apache + mod\_php with subdir
* http://localhost:4050 - nginx + oauth2-proxy + Keycloak
* Also a Tor hidden service - you'll need to look at `./tor/hostname` to figure out the hostname because it is uniquely generated each time. The Tor Proxy will be listening on port 4031

## OAuth2 Reverse Proxy

The `oauth2-nginx` example runs Shimmie behind `oauth2-proxy`, with Keycloak
as a local OpenID Connect provider:

```bash
docker compose up keycloak oauth2-proxy oauth2-nginx php-fpm
```

Before testing, enable Shimmie's `oauth2_login` extension and set these board
config values:

* Trust reverse proxy headers: enabled
* Proxy username header: `X-Forwarded-User`
* Proxy email header: `X-Forwarded-Email`
* Auto-create OAuth2 users: enabled

Then visit http://localhost:4050 and sign in through Keycloak with:

* username: `shimmie-admin`
* password: `password`

This setup is only for local development. Replace all secrets, enable HTTPS,
and ensure PHP-FPM is reachable only through the trusted reverse proxy before
using the same pattern in production.

## Testing

`./test.sh` will test, for each configuration:

* niceurls work (`/nicetest` returns "ok")
* uglyurls work (`/index.php?q=nicetest` returns "ok")
* cache headers work (static files should be cached for one day)
* encoded slashes work in niceurls (`/nicedebug/foo%2Fbar/1`)
* encoded slashes work in uglyurls (`/index.php?nicedebug/foo%2Fbar/1`)
* urlencoded urls get decoded (`post%2Flist`)

## Other Examples
* Apache - https://github.com/intergalacticmonkey/shimmie2-apache-docker/

