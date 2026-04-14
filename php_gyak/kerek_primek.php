<?php

$start_time = microtime(true);

$limit = 1000000;

// az Eraszthotenész szitája algoritmust hasznátam.
$is_prime = array_fill(0, $limit, true);

$is_prime[0] = false;
$is_prime[1] = false;

$sqrt_limit = ceil(sqrt($limit));

for ($p = 2; $p <= $sqrt_limit; $p++) {
  if ($is_prime[$p]) {
    for ($i = $p * $p; $i < $limit; $i += $p) {
      $is_prime[$i] = false;
    }
  }
}

$prime_count = 0;
$circular_prime_count = 0;

for ($i = 2; $i < $limit; $i++) {

  if ($is_prime[$i]) {
    $prime_count++;

    $str = (string) $i;
    $len = strlen($str);
    $is_circular = true;

    if ($len > 1 && preg_match('/[024568]/', $str)) {
      $is_circular = false;
    } else {

      $rotated_str = $str;
      for ($j = 0; $j < $len - 1; $j++) {

        $rotated_str = substr($rotated_str, 1) . $rotated_str[0];

        $rotated_num = (int) $rotated_str;

        if (!isset($is_prime[$rotated_num]) || !$is_prime[$rotated_num]) {
          $is_circular = false;
          break;
        }
      }
    }

    if ($is_circular) {
      $circular_prime_count++;
    }
  }
}

$end_time = microtime(true);
$execution_time = $end_time - $start_time;

echo "<pre>" . "\n";
echo "1 millio alatti primek szama: " . $prime_count . "\n";
echo "1 millio alatti kerek primek szama: " . $circular_prime_count . "\n\n";

echo "Futas ido: " . number_format($execution_time, 4) . " masodperc\n";
echo "</pre>";
?>