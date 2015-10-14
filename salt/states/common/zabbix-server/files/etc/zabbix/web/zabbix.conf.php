<?php
// Zabbix GUI configuration file
global $DB;

$DB['TYPE']     = 'POSTGRESQL';
$DB['SERVER']   = 'localhost';
$DB['PORT']     = '0';
$DB['DATABASE'] = 'zabbix';
$DB['USER']     = 'zabbix';
$DB['PASSWORD'] = '53o3v3vqlQSg7sGv';

// SCHEMA is relevant only for IBM_DB2 database
$DB['SCHEMA'] = '';

$ZBX_SERVER      = 'localhost';
$ZBX_SERVER_PORT = '10051';
$ZBX_SERVER_NAME = 'piqzabbix';

$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
?>
