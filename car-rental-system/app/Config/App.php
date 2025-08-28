<?php

namespace Config;

use CodeIgniter\Config\BaseConfig;

/**
 * Class App
 *
 * Configuration for the basic app settings.
 */
class App extends BaseConfig
{
    /**
     * --------------------------------------------------------------------------
     * Default Timezone
     * --------------------------------------------------------------------------
     *
     * This determines the default timezone that will be used in your application.
     * Please select the timezone that is appropriate for your location.
     *
     * @see https://www.php.net/manual/en/timezones.php
     */
    public $appTimezone = 'Asia/Jakarta';

    /**
     * --------------------------------------------------------------------------
     * Default Locale
     * --------------------------------------------------------------------------
     *
     * This determines the default locale that will be used by the
     * framework for language strings.
     *
     * @see https://github.com/bcit-ci/CodeIgniter4/blob/develop/readme.rst#localization
     */
    public $defaultLocale = 'id';

    /**
     * --------------------------------------------------------------------------
     * App Name
     * --------------------------------------------------------------------------
     *
     * This is the name of your application. It is used when the
     * framework needs to place the application's name in a
     * notification or other UI elements such as the title bar.
     */
    public $appName = 'Car Rental System';

    /**
     * --------------------------------------------------------------------------
     * Index File
     * --------------------------------------------------------------------------
     *
     * Typically this will be your index.php file, unless you've renamed it to
     * something else. If you are using mod_rewrite to remove the page set this
     * variable so that it is blank.
     */
    public $indexPage = '';

    /**
     * --------------------------------------------------------------------------
     * URI PROTOCOL
     * --------------------------------------------------------------------------
     *
     * This item determines which server global should be used to retrieve the
     * URI string. The default setting of 'REQUEST_URI' works for most servers.
     * If your links do not seem to work, try one of the other available
     * protocols.
     *
     * Valid values are:
     *   'REQUEST_URI'    Uses $_SERVER['REQUEST_URI']
     *   'QUERY_STRING'   Uses $_SERVER['QUERY_STRING']
     *   'PATH_INFO'      Uses $_SERVER['PATH_INFO']
     *
     * WARNING: If you set this to 'PATH_INFO', make sure that the following
     *          rules are added to your .htaccess file:
     *
     *          RewriteEngine On
     *          RewriteCond %{REQUEST_FILENAME} !-f
     *          RewriteCond %{REQUEST_FILENAME} !-d
     *          RewriteRule ^(.*)$ index.php/$1 [L]
     *
     *          Additionally, you must set the $indexPage variable to an
     *          empty string.
     *
     * IMPORTANT: If you set this to 'PATH_INFO', you MUST also set
     *            $indexPage to an empty string.
     */
    public $uriProtocol = 'REQUEST_URI';

    /**
     * --------------------------------------------------------------------------
     * Allowed Hostnames
     * --------------------------------------------------------------------------
     *
     * When logging in to the system, this is the list of hostnames that
     * are allowed to be used. This is a security measure to prevent
     * session hijacking.
     *
     * @var string[]
     */
    public $allowedHostnames = [];

    /**
     * --------------------------------------------------------------------------
     * Force Global Secure Requests
     * --------------------------------------------------------------------------
     *
     * If true, this will force every request made to this application to be
     * made via a secure connection (HTTPS). If the incoming request is not
     * secure, the user will be redirected to a secure version of the page
     * and the HTTP Strict Transport Security header will be set.
     */
    public $forceGlobalSecureRequests = false;

    /**
     * --------------------------------------------------------------------------
     * Session Driver
     * --------------------------------------------------------------------------
     *
     * The session storage driver to use:
     * - `CodeIgniter\Session\Handlers\FileHandler`
     * - `CodeIgniter\Session\Handlers\DatabaseHandler`
     * - `CodeIgniter\Session\Handlers\MemcachedHandler`
     * - `CodeIgniter\Session\Handlers\RedisHandler`
     *
     * @deprecated use Config\Session::$driver instead.
     */
    public $sessionDriver = 'CodeIgniter\Session\Handlers\FileHandler';

    /**
     * --------------------------------------------------------------------------
     * Session Cookie Name
     * --------------------------------------------------------------------------
     *
     * The session cookie name, must contain only [0-9a-z_-] characters.
     *
     * @deprecated use Config\Session::$cookieName instead.
     */
    public $sessionCookieName = 'ci_session';

    /**
     * --------------------------------------------------------------------------
     * Session Expiration
     * --------------------------------------------------------------------------
     *
     * The number of seconds you would like the session to last.
     * Setting to 0 (zero) means expire when the browser is closed.
     *
     * @deprecated use Config\Session::$expiration instead.
     */
    public $sessionExpiration = 7200;

    /**
     * --------------------------------------------------------------------------
     * Session Save Path
     * --------------------------------------------------------------------------
     *
     * The location to save sessions to and is driver dependent.
     *
     * For the 'files' driver, it's a path to a writable directory.
     * WARNING: Only absolute paths are supported!
     *
     * For the 'database' driver, it's a table name.
     * Please read up the manual for the format with other session drivers.
     *
     * IMPORTANT: You are REQUIRED to set a valid save path!
     *
     * @deprecated use Config\Session::$savePath instead.
     */
    public $sessionSavePath = null;

    /**
     * --------------------------------------------------------------------------
     * Session Match IP
     * --------------------------------------------------------------------------
     *
     * Whether to match the user's IP address when reading the session data.
     *
     * WARNING: If you're using the database driver, don't forget to update
     *          your session table's PRIMARY KEY when changing this setting.
     *
     * @deprecated use Config\Session::$matchIP instead.
     */
    public $sessionMatchIP = false;

    /**
     * --------------------------------------------------------------------------
     * Session Time to Update
     * --------------------------------------------------------------------------
     *
     * How many seconds between CI regenerating the session ID.
     *
     * @deprecated use Config\Session::$timeToUpdate instead.
     */
    public $sessionTimeToUpdate = 300;

    /**
     * --------------------------------------------------------------------------
     * Session Regenerate Destroy
     * --------------------------------------------------------------------------
     *
     * Whether to destroy session data associated with the old session ID
     * when auto-regenerating the session ID. When set to FALSE, the data
     * will be later deleted by the garbage collector.
     *
     * @deprecated use Config\Session::$regenerateDestroy instead.
     */
    public $sessionRegenerateDestroy = false;

    /**
     * --------------------------------------------------------------------------
     * Cookie Prefix
     * --------------------------------------------------------------------------
     *
     * Set a cookie name prefix if you need to avoid collisions.
     *
     * @deprecated use Config\Cookie::$prefix instead.
     */
    public $cookiePrefix = '';

    /**
     * --------------------------------------------------------------------------
     * Cookie Domain
     * --------------------------------------------------------------------------
     *
     * Set to `.your-domain.com` for site-wide cookies.
     *
     * @deprecated use Config\Cookie::$domain instead.
     */
    public $cookieDomain = '';

    /**
     * --------------------------------------------------------------------------
     * Cookie Path
     * --------------------------------------------------------------------------
     *
     * Typically will be a forward slash.
     *
     * @deprecated use Config\Cookie::$path instead.
     */
    public $cookiePath = '/';

    /**
     * --------------------------------------------------------------------------
     * Cookie Secure
     * --------------------------------------------------------------------------
     *
     * Cookie will only be set if a secure HTTPS connection exists.
     *
     * @deprecated use Config\Cookie::$secure instead.
     */
    public $cookieSecure = false;

    /**
     * --------------------------------------------------------------------------
     * Cookie HTTP Only
     * --------------------------------------------------------------------------
     *
     * Cookie will only be accessible via HTTP(S) (no JavaScript).
     *
     * @deprecated use Config\Cookie::$httponly instead.
     */
    public $cookieHTTPOnly = false;

    /**
     * --------------------------------------------------------------------------
     * Cookie SameSite
     * --------------------------------------------------------------------------
     *
     * Configure cookie SameSite setting. Allowed values are:
     * - None
     * - Lax
     * - Strict
     *
     * @deprecated use Config\Cookie::$sameSite instead.
     */
    public $cookieSameSite = 'Lax';

    /**
     * --------------------------------------------------------------------------
     * Reverse Proxy IPs
     * --------------------------------------------------------------------------
     *
     * If your server is behind a reverse proxy, you must whitelist the proxy
     * IP addresses from which CodeIgniter should trust headers such as
     * HTTP_X_FORWARDED_FOR and HTTP_CLIENT_IP in order to properly identify
     * the visitor's IP address.
     *
     * You can use both an array with a subnet, or use the same subnet with
     * a netmask (i.e. 192.168.100.0/24).
     */
    public $proxyIPs = [];

    /**
     * --------------------------------------------------------------------------
     * CSRF Token Name
     * --------------------------------------------------------------------------
     *
     * Token name for Cross Site Request Forgery protection.
     *
     * @deprecated use Config\Security::$tokenName instead.
     */
    public $CSRFTokenName = 'csrf_test_name';

    /**
     * --------------------------------------------------------------------------
     * CSRF Header Name
     * --------------------------------------------------------------------------
     *
     * Header name for Cross Site Request Forgery protection.
     *
     * @deprecated use Config\Security::$headerName instead.
     */
    public $CSRFHeaderName = 'X-CSRF-TOKEN';

    /**
     * --------------------------------------------------------------------------
     * CSRF Cookie Name
     * --------------------------------------------------------------------------
     *
     * Cookie name for Cross Site Request Forgery protection.
     *
     * @deprecated use Config\Security::$cookieName instead.
     */
    public $CSRFCookieName = 'csrf_cookie_name';

    /**
     * --------------------------------------------------------------------------
     * CSRF Expire
     * --------------------------------------------------------------------------
     *
     * Expiration time for Cross Site Request Forgery protection cookie.
     *
     * Defaults to 2 hours (in seconds).
     *
     * @deprecated use Config\Security::$expire instead.
     */
    public $CSRFExpire = 7200;

    /**
     * --------------------------------------------------------------------------
     * CSRF Regenerate
     * --------------------------------------------------------------------------
     *
     * Regenerate CSRF token on every submission.
     *
     * @deprecated use Config\Security::$regenerate instead.
     */
    public $CSRFRegenerate = true;

    /**
     * --------------------------------------------------------------------------
     * CSRF Redirect
     * --------------------------------------------------------------------------
     *
     * Redirect to previous page with error on failure.
     *
     * @deprecated use Config\Security::$redirect instead.
     */
    public $CSRFRedirect = true;

    /**
     * --------------------------------------------------------------------------
     * CSRF SameSite
     * --------------------------------------------------------------------------
     *
     * Setting for CSRF SameSite cookie token. Allowed values are:
     * - None
     * - Lax
     * - Strict
     *
     * Defaults to `Lax` as recommended in this link:
     *
     * @see https://portswigger.net/web-security/csrf/samesite-cookies
     *
     * @deprecated use Config\Security::$sameSite instead.
     */
    public $CSRFSameSite = 'Lax';

    /**
     * --------------------------------------------------------------------------
     * Content Security Policy
     * --------------------------------------------------------------------------
     *
     * Enables the Response's Content Secure Policy to restrict the sources that
     * can be used for images, scripts, CSS files, audio, and more. If enabled,
     * the Response object will populate the appropriate headers and, optionally,
     * send the CSP in a meta tag. See the following documentation for content
     * security policies.
     *
     * @see https://content-security-policy.com/
     */
    public $CSPEnabled = false;
}