vcl 4.1;

import dynamic;  # dynamic backend DNS lookup

backend default {
	.host = "nginx";
	.port = "80";
}

acl purgers {
	"127.0.0.1";
	"172.16.0.0/16";
}

sub vcl_recv {
	if (req.method == "PURGE") {
		if (!client.ip ~ purgers) {
			return (synth(405, "Method not allowed for " + client.ip));
		}
		return (purge);
	}

	if (req.url ~ "\.(jpg|jpeg|png|gif|webp|css|js)$") {
		unset req.http.Cookie;
	}

	# images and thumbs never change; in both cases these should be
	# cachable, but on the core server memory is tight so don't
	# cache full size images
	if (req.url ~ "/_images/.*") {
		return (pass);
	}
	if (req.url ~ "/_thumbs/.*") {
		return (hash);
	}
}

sub vcl_hash {
	if (req.url ~ "^/(_images|_thumbs)/") {
		hash_data(regsub(req.url, "^/(_images|_thumbs)/([0-9a-f]{32})/.*", "\1/\2"));
		return (lookup);
	}
}

sub vcl_backend_response {
	# No caching for errors
	if (beresp.status >= 400) {
		set beresp.uncacheable = true;
		set beresp.http.X-Cacheable = "NO: HTTP Error";
		set beresp.http.X-Cacheable-status = beresp.status;
		set beresp.ttl = 0s;
		return (deliver);
	}

	if (bereq.url ~ ".*\.(mp4|webm)") {
		set beresp.uncacheable = true;
		set beresp.http.X-Cacheable = "NO: Video File";
		set beresp.http.X-Cacheable-status = beresp.status;
		set beresp.ttl = 0s;
		return (deliver);
	}

	# Short caching for redirects
	if (beresp.status >= 300 && beresp.status < 400) {
		set beresp.ttl = 30s;
	}

	if (bereq.http.Cookie ~ "shm_") {
		set beresp.uncacheable = true;
		set beresp.http.X-Cacheable = "NO: Got Shimmie Cookie";
		set beresp.ttl = 0s;
		return (deliver);
	}

	if (beresp.http.Set-Cookie) {
		set beresp.uncacheable = true;
		set beresp.http.X-Cacheable = "NO: Sets cookie";
		set beresp.ttl = 0s;
		set beresp.http.Set-Cookie = regsuball(beresp.http.Set-Cookie, "Path=/[a-zA-Z/]+", "Path=/");
		return (deliver);
	}

	if (beresp.http.Vary == "*") {
		set beresp.uncacheable = true;
		set beresp.http.X-Cacheable = "NO: Variable content";
		set beresp.ttl = 0s;
		return (deliver);
	}

	# If the above rules deem something cacheable, and it doesn't have a TTL
	# set in the HTTP headers, it will have a default ttl of 120s; here we
	# override that
	if (beresp.ttl == 120s) {
		set beresp.grace = 1h;

		# These pages are manually PURGEd when tags are updated
		# or a comment is added
		if(bereq.url ~ "^/post/view/\d+") {
			set beresp.ttl = 1d;
		}

		# front page is most popular for anons, update it often
		elseif(bereq.url ~ "^/post/list$") {
			set beresp.ttl = 3m;
		}
		elseif(bereq.url ~ "^/comment/list$") {
			set beresp.ttl = 3m;
		}
		# first few pages are slightly less popular
		elseif(bereq.url ~ "^/post/list/[1-5]$") {
			set beresp.ttl = 5m;
		}
		# historical lists change rarely
		elseif(bereq.url ~ "^/post/list/\d+") {
			set beresp.ttl = 30m;
		}
		# search results change very rarely
		elseif(bereq.url ~ "^/post/list/.*/\d+") {
			set beresp.ttl = 3h;
		}

		# everything else, default to 1h
		else {
			set beresp.ttl = 1h;
		}
	}

	if (beresp.ttl == 120s && bereq.url ~ "/_thumbs/.*") {
		set beresp.ttl = 10y;
	}
	if (beresp.ttl == 120s && bereq.url ~ "/_images/.*") {
		set beresp.ttl = 10y;
	}

	set beresp.http.X-Cache-TTL = beresp.ttl;

	if (beresp.ttl == 0s) {
		set beresp.http.X-Cacheable = "NO: yes, but TTL = 0s";
	}
	else {
		set beresp.http.X-Cacheable = "YES: all good";
	}

	return (deliver);
}

sub vcl_deliver {
	if (obj.hits > 0) {
		set resp.http.X-Cache = "HIT";
		set resp.http.X-Cache-Hits = obj.hits;
	}
	else {
		set resp.http.X-Cache = "MISS";
	}
	if (req.url ~ ".*\.gif") {
		set resp.http.Content-Type = "image/gif";
	}
	if (req.url ~ ".*\.png") {
		set resp.http.Content-Type = "image/png";
	}
	if (req.url ~ ".*\.jpg") {
		set resp.http.Content-Type = "image/jpeg";
	}
	if (req.url ~ ".*\.webp") {
		set resp.http.Content-Type = "image/webp";
		set resp.http.Access-Control-Allow-Origin = "*";
	}
	if (req.url ~ ".*\.mp4") {
		set resp.http.Content-Type = "video/mp4";
	}
	if (req.url ~ ".*\.webm") {
		set resp.http.Content-Type = "video/webm";
	}
	unset req.http.Orig-Url;
}

sub vcl_backend_error {
	return (retry);
}

sub vcl_synth {
	if (resp.status == 751) {
		set resp.http.Location = resp.reason;
		set resp.status = 301;
		return(deliver);
	}
}
