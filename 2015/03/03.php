<?php

$file = trim(file_get_contents("input"));

function get_pos(string $char): array
{
    return match ($char) {
        '^' => [0, -1],
        '>' => [1, 0],
        'v' => [0, 1],
        '<' => [-1, 0],
    };
}

function deliver(array &$grid, array $pos): void
{
    $k = json_encode($pos);
    if (!empty($grid[$k])) {
        $grid[$k] += 1;
    } else {
        $grid[$k] = 1;
    }
}

function count_deliveries(string $text): int
{
    $grid = [];
    $cur = [0, 0];
    $robo = [0, 0];
    $santa = true;

    deliver($grid, $cur);
    deliver($grid, $robo);
   
    foreach (str_split($text) as $char) {
        [$x, $y] = get_pos($char);
        if ($santa) {
            $cur[0] += $x;
            $cur[1] += $y;
            deliver($grid, $cur);
        } else {
            $robo[0] += $x;
            $robo[1] += $y;
            deliver($grid, $robo);
        }
        $santa = !$santa;
    }

    return count($grid);
}

print count_deliveries(">") . PHP_EOL;
print count_deliveries("^>") . PHP_EOL;
print count_deliveries("^>v<") . PHP_EOL;
print count_deliveries("^v^v^v^v^v"). PHP_EOL;
print count_deliveries($file) . PHP_EOL;
