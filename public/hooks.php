<?php
$shell = "cd /home/wwwroot/blog/public && git pull";
echo "<pre>";
exec($shell, $result, $status);
if ($status) {
    echo 'fail';
} else {
    echo 'succ';
}