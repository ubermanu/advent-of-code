<?php

function get_suffix(string $str): int
{
    $i = 0;
    while (true) {
        $hash = md5($str . strval($i));
        if (substr($hash, 0, 5) === '00000') {
            return $i;
        }
        $i++;
    }
}

print get_suffix("abcdef") . PHP_EOL;
print get_suffix("pqrstuv") . PHP_EOL;
print get_suffix("bgvyzdsv") . PHP_EOL;
