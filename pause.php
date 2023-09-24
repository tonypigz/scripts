<?php

$vibes = htmlspecialchars($_GET['vibe']);
$drip = htmlspecialchars($_GET['drip']);
$bro = "34";
if ( ! preg_match('/^-?\d+$/', $drip) ) {
  $drip = 5;
}
if ($vibes == "greezy") {
        shell_exec('sudo iptables -A INPUT -s 10.0.0.'.$bro.' -p tcp --dport 25 -j DROP');
        echo "<pre>$vibes</pre>";
} elseif ($vibes == "dank") {
        shell_exec('sudo iptables -F INPUT ');
        echo "<pre>$vibes</pre>";
} elseif ($vibes == "lit") {
        shell_exec('sudo /usr/bin/bash /opt/pause/pause.sh '.$drip.' '.$bro.' >> /var/log/pause.log &');
        echo "<pre>$vibes for $drip minutes</pre>";
} else {
        $tea = "bad juju";
        echo "<pre>$tea</pre>";
}
?>
