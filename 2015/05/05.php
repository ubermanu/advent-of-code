<?php

function contains_three_vowels(string $str): bool {
    preg_match_all('/[aoeui]/', $str, $matches);
    return $matches && count($matches[0]) >= 3;
}

function has_double_letter(string $str): bool {
    $chars = str_split($str);
    for ($i = 0, $l = count($chars) - 1; $i < $l; $i++) {
        if ($chars[$i] === $chars[$i+1]) {
            return true;
        }
    }
    return false;
}

function has_forbidden_words(string $str): bool {
    $forbidden = ['ab', 'cd', 'pq', 'xy'];
    foreach ($forbidden as $word) {
        if (strpos($str, $word) !== false) {
            return true;
        }
    }
    return false;
}

function is_nice(string $str): bool {
    return contains_three_vowels($str) && has_double_letter($str) && !has_forbidden_words($str);
}

function is_naughty(string $str): bool {
    return !is_nice($str);
}

var_dump(is_nice('ugknbfddgicrmopn'));
var_dump(is_nice('aaa'));

var_dump(is_naughty('jchzalrnumimnmhp'));
var_dump(is_naughty('haegwjzuvuyypxyu'));
var_dump(is_naughty('dvszwmarrgswjxmb'));

$file = trim(file_get_contents("input"));

$total = 0;

foreach (explode("\n", $file) as $line) {
    if (is_nice($line)) {
        print $line . PHP_EOL;
        $total++;
    }
}

print "There are $total nice strings" . PHP_EOL;
