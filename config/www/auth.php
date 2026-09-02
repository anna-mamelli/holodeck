<?php
function refuse() {
    header('WWW-Authenticate: Basic realm="Starfleet - identifiez-vous"');
    http_response_code(401);
    exit;
}
$user = $_SERVER['PHP_AUTH_USER'] ?? '';
$pass = $_SERVER['PHP_AUTH_PW'] ?? '';
if ($user === '' || $pass === '' || !preg_match('/^[a-z0-9._-]+$/i', $user)) refuse();

$ldap = ldap_connect('ldap://127.0.0.1');
ldap_set_option($ldap, LDAP_OPT_PROTOCOL_VERSION, 3);
if (@ldap_bind($ldap, "uid=$user,ou=users,dc=starfleet,dc=lan", $pass)) {
    http_response_code(204);
    exit;
}
refuse();
