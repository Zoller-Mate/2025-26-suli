<?php
// MazeGenerator.php
class MazeGenerator
{
  private $rows; // valódi mátrix sor (N)
  private $cols; // valódi mátrix oszlop (M)
  private $grid; // 2D tömb, 0 = fal, 1 = járat
  private $rand;

  public function __construct($n, $m, $seed = null)
  {
    // kötelező páratlan méretek
    if ($n % 2 == 0 || $m % 2 == 0) {
      throw new InvalidArgumentException("N és M értéke páratlan kell, hogy legyen.");
    }
    $this->rows = $n;
    $this->cols = $m;
    $this->grid = array_fill(0, $this->rows, array_fill(0, $this->cols, 0));
    if ($seed !== null) {
      mt_srand((int) $seed);
      $this->rand = function ($a, $b) {
        return mt_rand($a, $b); };
    } else {
      $this->rand = function ($a, $b) {
        return random_int($a, $b); };
    }
  }

  public function generate()
  {
    // Initialize all cells as walls (0). We'll carve passages (1).
    // Choose a random starting cell on odd coordinates.
    $startR = $this->randOdd(1, $this->rows - 2);
    $startC = $this->randOdd(1, $this->cols - 2);
    // Use iterative DFS (stack) for safety
    $stack = [];
    $this->grid[$startR][$startC] = 1;
    $stack[] = [$startR, $startC];

    while (!empty($stack)) {
      $current = $stack[count($stack) - 1];
      list($r, $c) = $current;
      // collect unvisited neighbours two steps away (N,S,E,W)
      $neighbors = [];
      $dirs = [
        [-2, 0, -1, 0],
        [2, 0, 1, 0],
        [0, -2, 0, -1],
        [0, 2, 0, 1],
      ];
      foreach ($dirs as $d) {
        $nr = $r + $d[0];
        $nc = $c + $d[1];
        if ($this->inBounds($nr, $nc) && $this->grid[$nr][$nc] == 0) {
          $neighbors[] = $d;
        }
      }
      if (!empty($neighbors)) {
        // choose random neighbor
        $i = call_user_func($this->rand, 0, count($neighbors) - 1);
        $d = $neighbors[$i];
        $nr = $r + $d[0];
        $nc = $c + $d[1];
        $betweenR = $r + $d[2];
        $betweenC = $c + $d[3];
        // carve passage through between cell and neighbor
        $this->grid[$betweenR][$betweenC] = 1;
        $this->grid[$nr][$nc] = 1;
        // push neighbor
        $stack[] = [$nr, $nc];
      } else {
        // backtrack
        array_pop($stack);
      }
    }

    return $this->grid;
  }

  private function inBounds($r, $c)
  {
    return $r > 0 && $r < $this->rows - 1 && $c > 0 && $c < $this->cols - 1;
  }

  private function randOdd($min, $max)
  {
    // min,max páratlanok legyenek - ha nem, igazítjuk
    if ($min % 2 == 0)
      $min++;
    if ($max % 2 == 0)
      $max--;
    if ($min > $max)
      $min = $max; // egzotikus eset
    $count = intval(($max - $min) / 2) + 1;
    $i = call_user_func($this->rand, 0, $count - 1);
    return $min + $i * 2;
  }
}
