<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mysqli';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'localhost';
$CFG->dbname    = 'moodle';
$CFG->dbuser    = '{{ mysql_user }}';
$CFG->dbpass    = '{{ mysql_pass }}';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
    'dbsocket' => 0,
    );

$CFG->wwwroot   = 'https://{{ moodle_wwwroot }}';
$CFG->dataroot  = '/var/lib/moodle';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;

$CFG->passwordsaltmain = 'R4T_tO.:)XGT20.Mk0(Lq3MZIi';

require_once(dirname(__FILE__) . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
