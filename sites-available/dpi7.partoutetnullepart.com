# -*- mode: nginx; mode: flyspell-prog;  ispell-current-dictionary: american -*-
### Configuration for example.com.

## Return (no rewrite) server block.
server {
    ## This is to avoid the spurious if for sub-domain name
    ## "rewriting".
    listen 80; # IPv4
    ## Replace the IPv6 address by your own address. The address below
    ## was stolen from the wikipedia page on IPv6.
    #listen [fe80::202:b3ff:fe1e:8329]:80 ipv6only=on;
    server_name www.partoutetnullepart.com;
    return 301 $scheme://partoutetnullepart.com$request_uri;

} # server domain return.

## HTTP server.
server {
    listen 80; # IPv4
    ## Replace the IPv6 address by your own address. The address below
    ## was stolen from the wikipedia page on IPv6.
    #listen [fe80::202:b3ff:fe1e:8330]:80 ipv6only=on;

    server_name dpi7.partoutetnullepart.com;
    limit_conn arbeit 32;

    ## Access and error logs.
    access_log /var/log/nginx/dpi7.partoutetnullepart.com_access.log;
    error_log /var/log/nginx/dpi7.partoutetnullepart.com_error.log;

    ## See the blacklist.conf file at the parent dir: /etc/nginx.
    ## Deny access based on the User-Agent header.
    if ($bad_bot) {
        return 444;
    }
    ## Deny access based on the Referer header.
    if ($bad_referer) {
        return 444;
    }

    ## Protection against illegal HTTP methods. Out of the box only HEAD,
    ## GET and POST are allowed.
    if ($not_allowed_method) {
        return 405;
    }

    ## Filesystem root of the site and index.
    root /var/www/dpi7.partoutetnullepart.com;
    index index.php;

    ## If you're using a Nginx version greater or equal to 1.1.4 then
    ## you can use keep alive connections to the upstream be it
    ## FastCGI or Apache. If that's not the case comment out the line below.
    fastcgi_keep_conn on; # keep alive to the FCGI upstream

    ## Uncomment if you're proxying to Apache for handling PHP.
    #proxy_http_version 1.1; # keep alive to the Apache upstream

    ################################################################
    ### Generic configuration: for most Drupal 7 sites.
    ################################################################
    include apps/drupal/drupal.conf;

    ################################################################
    ### Configuration for Drupal 7 sites to serve URIs that need
    ### to be **escaped**
    ################################################################
    #include apps/drupal/drupal_escaped.conf;

    #################################################################
    ### Configuration for Drupal 7 sites that use boost.
    #################################################################
    #include apps/drupal/drupal_boost.conf;

    #################################################################
    ### Configuration for Drupal 7 sites that use boost if having
    ### to serve URIs that need to be **escaped**
    #################################################################
    #include apps/drupal/drupal_boost_escaped.conf;

    #################################################################
    ### Configuration for updating the site via update.php and running
    ### cron externally. If you don't use drush for running cron use
    ### the configuration below.
    #################################################################
    #include apps/drupal/drupal_cron_update.conf;

    ################################################################
    ### Installation handling. This should be commented out after
    ### installation if on an already installed site there's no need
    ### to touch it. If on a yet to be installed site. Uncomment the
    ### line below and comment out after installation. Note that
    ### there's a basic auth in front as secondary ligne of defense.
    ################################################################
    #include apps/drupal/drupal_install.conf;

    #################################################################
    ### Support for upload progress bar. Configurations differ for
    ### Drupal 6 and Drupal 7.
    #################################################################
    include apps/drupal/drupal_upload_progress.conf;

    ## Including the php-fpm status and ping pages config.
    ## Uncomment to enable if you're running php-fpm.
    #include php_fpm_status_vhost.conf;

    ## Including the Nginx stub status page for having stats about
    ## Nginx activity: http://wiki.nginx.org/HttpStubStatusModule.
    include nginx_status_vhost.conf;

} # HTTP server

## Return (no rewrite) server block.
server {
    ## This is to avoid the spurious if for sub-domain name
    ## "rewriting".
    ## Comment the line below if you're using SPDY.
    listen 443 ssl;
    ## Uncomment the line below if you're using SPDY.
    #listen 443 ssl spdy; # IPv4

    ## Replace the IPv6 address by your own address. The address below
    ## was stolen from the wikipedia page on IPv6.

    ## Comment the line below if you're using SPDY.
    #listen [fe80::202:b3ff:fe1e:8329]:443 ssl ipv6only=on;
    ## Uncomment the line below if you're using SPDY.
    #listen [fe80::202:b3ff:fe1e:8329]:443 ssl spdy ipv6only=on;

    server_name dpi7.partoutetnullepart.com;

    ## Keep alive timeout set to a greater value for SSL/TLS.
    keepalive_timeout 75 75;

    ## See the keepalive_timeout directive in nginx.conf.
    ## Server certificate and key.
    ssl_certificate /etc/ssl/certs/monsite.com.crt;
    ssl_certificate_key /etc/ssl/private/monsite.com.key;

    return 301 $scheme://dpi7.partoutetnullepart.com$request_uri;

} # server domain return.

## HTTPS server.
server {
    ## Comment the line below if you're using SPDY.
    listen 443 ssl;
    ## Uncomment the line below if you're using SPDY.
    #listen 443 ssl spdy;
    ## Replace the IPv6 address by your own address. The address below
    ## was stolen from the wikipedia page on IPv6.

    ## Comment the line below if you're using SPDY.
    #listen [fe80::202:b3ff:fe1e:8330]:443 ssl ipv6only=on;
    ## Uncomment the line below if you're using SPDY.
    #listen [fe80::202:b3ff:fe1e:8330]:443 ssl spdy ipv6only=on;

    server_name dpi7.partoutetnullepart.com;

    limit_conn arbeit 32;

    ## Access and error logs.
    access_log /var/log/nginx/dpi7.partoutetnullepart.com_access.log;
    error_log /var/log/nginx/dpi7.partoutetnullepart.com_error.log;

    ## Keep alive timeout set to a greater value for SSL/TLS.
    keepalive_timeout 75 75;

    ## See the keepalive_timeout directive in nginx.conf.
    ## Server certificate and key.
    ssl_certificate /etc/ssl/certs/monsite.com.crt;
    ssl_certificate_key /etc/ssl/private/monsite.com.key;

    ## Strict Transport Security header for enhanced security. See
    ## http://www.chromium.org/sts. I've set it to 2 hours; set it to
    ## whichever age you want.
    add_header Strict-Transport-Security "max-age=7200";

    root /var/www/dpi7.partoutetnullepart.com;
    index index.php;

    ## If you're using a Nginx version greater or equal to 1.1.4 then
    ## you can use keep alive connections to the upstream be it
    ## FastCGI or Apache. If that's not the case comment out the line below.
    fastcgi_keep_conn on; # keep alive to the FCGI upstream

    ## Uncomment if you're proxying to Apache for handling PHP.
    #proxy_http_version 1.1; # keep alive to the Apache upstream

    ## See the blacklist.conf file at the parent dir: /etc/nginx.
    ## Deny access based on the User-Agent header.
    if ($bad_bot) {
        return 444;
    }
    ## Deny access based on the Referer header.
    if ($bad_referer) {
        return 444;
    }

    ## Protection against illegal HTTP methods. Out of the box only HEAD,
    ## GET and POST are allowed.
    if ($not_allowed_method) {
        return 405;
    }

    ################################################################
    ### Generic configuration: for most Drupal 7 sites.
    ################################################################
    include apps/drupal/drupal.conf;

    ################################################################
    ### Configuration for Drupal 7 sites to serve URIs that need
    ### to be **escaped**
    ################################################################
    #include apps/drupal/drupal_escaped.conf;

    #################################################################
    ### Configuration for Drupal 7 sites that use boost.
    #################################################################
    #include apps/drupal/drupal_boost.conf;

    #################################################################
    ### Configuration for Drupal 7 sites that use boost if having
    ### to serve URIs that need to be **escaped**
    #################################################################
    #include apps/drupal/drupal_boost_escaped.conf;

    #################################################################
    ### Configuration for updating the site via update.php and running
    ### cron externally. If you don't use drush for running cron use
    ### the configuration below.
    #################################################################
    #include apps/drupal/drupal_cron_update.conf;

    ################################################################
    ### Installation handling. This should be commented out after
    ### installation if on an already installed site there's no need
    ### to touch it. If on a yet to be installed site. Uncomment the
    ### line below and comment out after installation. Note that
    ### there's a basic auth in front as secondary ligne of defense.
    ################################################################
    #include apps/drupal/drupal_install.conf;

    #################################################################
    ### Support for upload progress bar. Configurations differ for
    ### Drupal 6 and Drupal 7.
    #################################################################
    include apps/drupal/drupal_upload_progress.conf;

    ## Including the php-fpm status and ping pages config.
    ## Uncomment to enable if you're running php-fpm.
    #include php_fpm_status_vhost.conf;

    ## Including the Nginx stub status page for having stats about
    ## Nginx activity: http://wiki.nginx.org/HttpStubStatusModule.
    include nginx_status_vhost.conf;

} # HTTPS server
