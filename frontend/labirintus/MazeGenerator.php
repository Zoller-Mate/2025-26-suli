<?php
// labirintus generátor
class MazeGenerator
{
  private $rows;
  private $cols;
  private $grid;
  private $rand;

  public function __construct($n, $m, $seed = null)
  {
    // páratlan érték kell, igen
    if ($n % 2 == 0 || $m % 2 == 0) {
      throw new InvalidArgumentException("N és M értéke páratlan kell, hogy legyen.");
    }
    $this->rows = $n;
    $this->cols = $m;
    $this->grid = array_fill(0, $this->rows, array_fill(0, $this->cols, 0));
    if ($seed !== null) {
      mt_srand((int) $seed);
      $this->rand = function ($a, $b) {
        return mt_rand($a, $b);
      };
    } else {
      $this->rand = function ($a, $b) {
        return random_int($a, $b);
      };
    }
  }

  public function generate()
  {
    // minden fal, aztán nyitunk utat
    $startR = $this->randOdd(1, $this->rows - 2);
    $startC = $this->randOdd(1, $this->cols - 2);
    // stack-es dfs
    $stack = [];
    $this->grid[$startR][$startC] = 1;
    $stack[] = [$startR, $startC];

    while (!empty($stack)) {
      $current = $stack[count($stack) - 1];
      list($r, $c) = $current;
      // négy irány, két lépés
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
        //véletlen szomszéd
        $i = call_user_func($this->rand, 0, count($neighbors) - 1);
        $d = $neighbors[$i];
        $nr = $r + $d[0];
        $nc = $c + $d[1];
        $betweenR = $r + $d[2];
        $betweenC = $c + $d[3];
        // átvágjuk a közt
        $this->grid[$betweenR][$betweenC] = 1;
        $this->grid[$nr][$nc] = 1;
        // be a stackbe
        $stack[] = [$nr, $nc];
      } else {
        // visszalép
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
    // páratlanra igazít
    if ($min % 2 == 0)
      $min++;
    if ($max % 2 == 0)
      $max--;
    if ($min > $max)
      $min = $max;
    $count = intval(($max - $min) / 2) + 1;
    $i = call_user_func($this->rand, 0, $count - 1);
    return $min + $i * 2;
  }
}
