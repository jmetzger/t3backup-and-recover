<?php

$config = array();

/**
 * Hardcoded for troll at present 
 * TODO: Extract from configuration
 **/
if (!isset($_SERVER['argv'])){
   die ('No Dest-Dir passed');   
}

if (!isset($_SERVER['argv'][1])){
   die ('No Dest-Dir passed');       
}

$dest_dir = $_SERVER['argv'][1];

if (!is_dir($dest_dir)){
  echo "Project $dest_dir not found";    
}

###
# Detect version 
##
if (is_dir($dest_dir."/typo3conf")){
  $software = "typo3";
}

switch ($software){
    
 case 'typo3':

    $config=extractTypo3Db($dest_dir);
    break;
    
 default:
    die ('no software detected, nothing to do here');
    break;
}

function extractTypo3Db($dest_dir){
  
  if (is_file($dest_dir."/typo3conf/LocalConfiguration.php")){  
    return;
    // not implemented yet  
      
  }
    
  if (is_file($dest_dir."/typo3conf/localconf.php")){
    
     include_once($dest_dir."/typo3conf/localconf.php"); 
     $arr = array('db'   => $typo_db,
		  'user' => $typo_db_username,
		  'pass' => $typo_db_password,
		  'host' => $typo_db_host);
      
     return $arr;
      

  }
    
}

if (sizeof($config) == 0){
   die ('no config for db found');   
}

$user=$config['user'];
$pass=$config['pass'];
$host=$config['host'];
$db=$config['db'];
$mysql_root_pw = getenv('MYSQL_ROOT_PW');
$debug = false;

if ($user == ""){
   die ("No user detected. Giving up");   
}

if ($pass == ""){
   die ("No password detected. Giving up");   
}

if ($host == ""){
   die ("No host detected. Giving up");   
}

if ($db == ""){
   die ("No db detected. Giving up");   
}



function logit($str){
    global $debug;
    if ($debug === TRUE){
      echo $str;
    }
}

if ($mysql_root_pw == ""){
   echo "No Mysql Root Password given. Giving up.";
   exit (1);   
}
  
$sql = "grant usage on *.* to {$user}@{$host} identified by '{$pass}'";
$cmd = "echo \"$sql\" | mysql -uroot -p$mysql_root_pw;";
logit ($sql);
shell_exec ($cmd);

/**
 * Allow access to specific db on server
 **/
$sql = "grant all privileges on {$db}.* to {$user}@{$host}";
$cmd = "echo \"$sql\" | mysql -uroot -p$mysql_root_pw;";
logit ($sql);
shell_exec ($cmd);

exit (0);

?>
