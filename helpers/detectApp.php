<?php

if (isset($_SERVER["argv"]) && isset ($_SERVER["argv"][1])){
	
   $installation = $_SERVER["argv"][1];
   if ($installation == ""){
      exit (1);   
   }
}
       
if (!is_dir($installation)){
   exit (1);   
}

## Detect typo3_6 
if (file_exists($installation."/typo3conf/LocalConfiguration.php")){
   echo "typo3_6";
   exit (0);
}

## Detec typo3
if (file_exists($installation."/typo3conf/localconf.php")){
   echo "typo3";
   exit (0);
}

echo "Unknown";
exit (1);
    
    
?>