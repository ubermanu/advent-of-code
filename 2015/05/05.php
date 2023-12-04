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

var_dump(is_nice('ugknbfddgicrmopn'));
var_dump(is_nice('aaa'));

var_dump(!is_nice('jchzalrnumimnmhp'));
var_dump(!is_nice('haegwjzuvuyypxyu'));
var_dump(!is_nice('dvszwmarrgswjxmb'));

$file = trim(file_get_contents("input"));

$total = 0;

foreach (explode("\n", $file) as $line) {
    if (is_nice($line)) {
        $total++;
    }
}

print "There are $total nice strings" . PHP_EOL;


function has_letter_pair_twice(string $str): bool {
    $pairs = [];
    $chars = str_split($str);
    for ($i = 0, $l = count($chars) - 1; $i < $l; $i++) {
        $pairs[$i] = $chars[$i] . $chars[$i+1];
    }

    $count = [];
    
    foreach ($pairs as $index => $pair) {
        if (isset($count[$pair])) {
            $count[$pair][] = $index;
        } else {
            $count[$pair] = [$index];
        }
    }

    foreach ($count as $pair => $indexes) {
        if (count($indexes) === 1) {
            continue;
        }
        foreach ($indexes as $i => $a) {
            foreach ($indexes as $j => $b) {
                if ($i === $j) {
                    continue;
                }
                if ($a + 1 < $b || $b + 1 < $a) {
                    return true;
                }
            }
        }
    }

    return false;
}

function has_letter_inbetween(string $str): bool {
    if (strlen($str) < 3) {
        return false;
    }

    $chars = str_split($str);

    for ($i = 0, $l = count($chars) - 2; $i < $l; $i++) {
        if ($chars[$i] === $chars[$i+2]) {
            return true;
        }
    }

    return false;
}

function is_nice2(string $str): bool {
    return has_letter_pair_twice($str) && has_letter_inbetween($str);
}

var_dump(is_nice2("qjhvhtzxzqqjkmpb"));
var_dump(is_nice2("xxyxx"));
var_dump(!is_nice2("uurcxstgmygtbstg"));
var_dump(!is_nice2("ieodomkazucvgmuy"));


$total = 0;

foreach (explode("\n", $file) as $line) {
    if (is_nice2($line)) {
        print $line . PHP_EOL;
        $total++;
    }
}

print "There are $total nicer strings" . PHP_EOL;
