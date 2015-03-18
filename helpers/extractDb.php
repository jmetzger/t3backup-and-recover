<?php

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

    $version=extractTypo3Db($dest_dir);
    echo $version;
    break;
    
 default:
    die ('no software detected, nothing to do here');
    break;
}

function extractTypo3Db($dest_dir){
  
  if (is_file($dest_dir."/typo3conf/LocalConfiguration.php")){  
    return '';
    // not implemented yet  
      
  }
    
  if (is_file($dest_dir."/typo3conf/localconf.php")){
    
     include_once($dest_dir."/typo3conf/localconf.php"); 
     return $typo_db;
      
  }
    
}
    



?>