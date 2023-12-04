<?php

function get_suffix(string $str, int $n = 5): int
{
    $i = 0;
    $zeros = str_pad("", $n, "0");
    
    while (true) {
        $hash = md5($str . strval($i));
        if (substr($hash, 0, $n) === $zeros) {
            return $i;
        }
        $i++;
    }
}

print get_suffix("abcdef") . PHP_EOL;
print get_suffix("pqrstuv") . PHP_EOL;
print get_suffix("bgvyzdsv") . PHP_EOL;
print get_suffix("bgvyzdsv", 6) . PHP_EOL;
