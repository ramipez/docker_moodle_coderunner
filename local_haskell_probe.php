<?php
define('CLI_SCRIPT', true);
require_once('/var/www/html/config.php');
require_once($CFG->dirroot . '/question/type/coderunner/questiontype.php');
require_once($CFG->dirroot . '/question/type/coderunner/classes/jobesandbox.php');

$sandbox = new qtype_coderunner_jobesandbox();
$source = "main :: IO ()\nmain = putStrLn \"Hello from Moodle via Jobe\"\n";
$params = ['sourcefilename' => 'Main.hs'];
$result = $sandbox->execute($source, 'haskell', '', null, $params);

echo json_encode([
    'error' => $result->error,
    'result' => $result->result,
    'output' => $result->output,
    'stderr' => $result->stderr,
    'cmpinfo' => $result->cmpinfo,
], JSON_PRETTY_PRINT) . PHP_EOL;
