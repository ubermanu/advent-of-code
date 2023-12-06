<?php

function get_literal_length(string $str): int {
	return strlen($str);
}

function get_value_length(string $str): int {
	return strlen(stripcslashes($str)) - 2; // 2 for the side quotes
}

$doc = [
	'""',
	'"abc"',
	'"aaa\"aaa',
	'"\x27"',
];


foreach ($doc as $str) {
	var_dump($str);
	var_dump(get_literal_length($str) - get_value_length($str));
}


$file = trim(file_get_contents("input"));
$total = 0;

foreach (explode("\n", $file) as $line) {
	$total += get_literal_length($line) - get_value_length($line);
}

print "Total of special characters: $total" . PHP_EOL;
