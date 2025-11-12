<?php
// maze.php
require_once 'MazeGenerator.php';

header('Content-Type: application/json; charset=utf-8');

try {
  // alapértelmezett méretek (példa: 21x31)
  $n = isset($_GET['n']) ? (int) $_GET['n'] : 21;
  $m = isset($_GET['m']) ? (int) $_GET['m'] : 31;
  $seed = isset($_GET['seed']) ? (int) $_GET['seed'] : null;

  if ($n < 3 || $m < 3) {
    throw new Exception("N és M legalább 3 kell legyen.");
  }
  if ($n % 2 == 0 || $m % 2 == 0) {
    throw new Exception("N és M értéke páratlan kell, hogy legyen.");
  }

  $gen = new MazeGenerator($n, $m, $seed);
  $grid = $gen->generate();

  echo json_encode([
    'n' => $n,
    'm' => $m,
    'grid' => $grid
  ], JSON_UNESCAPED_UNICODE);
} catch (Exception $ex) {
  http_response_code(400);
  echo json_encode(['error' => $ex->getMessage()]);
}
