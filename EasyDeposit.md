# Introduction #

EasyDeposit is an application for making custom SWORD interfaces. It is designed to be used with a variety of repository systems.

# Details #

  * got package from http://easydeposit.swordapp.org/

  * unzipped package to /var/www/easydeposit
  * modified easydeposit/application/config/config.php
    * $config[‘base\_url’] = “http://andsdb-dc19-dev.etc/easydeposit”;

> Ran into some issues with the `RewriteRule` in .htaccess - it never fired. Added $config[‘index\_page’] = 'index.php'; which uglifies the url, but resolves the issue.

Note that default Username/Password are easydepositadmin/easydepositadmin