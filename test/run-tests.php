<?php
/**
 * XSLT Pipeline Test Runner (PHP)
 * 
 * Iterates over input files and transform targets, runs transformations,
 * compares output with expected results, and generates a test report.
 */

require_once dirname(__DIR__) . '/src/transformer.php';

// Configuration
$baseDir = dirname(__DIR__);
$inputDir = $baseDir . DIRECTORY_SEPARATOR . 'input';
$transformDir = $baseDir . DIRECTORY_SEPARATOR . 'transforms';
$expectedDir = $baseDir . DIRECTORY_SEPARATOR . 'expected';
$outputDir = $baseDir . DIRECTORY_SEPARATOR . 'output';

// Test results
$testResults = [];
$passedTests = 0;
$failedTests = 0;

// Ensure output directory exists
if (!is_dir($outputDir)) {
    mkdir($outputDir, 0755, true);
}

echo "=== XSLT Pipeline Test Runner ===\n";
echo "Base directory: $baseDir\n";
echo "Input directory: $inputDir\n";
echo "Transform directory: $transformDir\n";
echo "Expected directory: $expectedDir\n";
echo "Output directory: $outputDir\n";
echo "\n";

// Collect available targets
$targets = [];
if (is_dir($transformDir)) {
    $items = scandir($transformDir);
    foreach ($items as $item) {
        if ($item !== '.' && $item !== '..' && str_contains($item, '-') && is_dir($transformDir . DIRECTORY_SEPARATOR . $item)) {
            $targets[] = $item;
        }
    }
}

if (empty($targets)) {
    echo "ERROR: No transform targets found in $transformDir\n";
    exit(1);
}

echo "Found " . count($targets) . " target(s): " . implode(', ', $targets) . "\n";
echo "\n";

// Collect input files
$inputFiles = [];
if (is_dir($inputDir)) {
    $items = scandir($inputDir);
    foreach ($items as $item) {
        if (preg_match('/\.xml$/i', $item)) {
            $lemmaId = preg_replace('/\.xml$/i', '', $item);
            $inputFiles[] = $lemmaId;
        }
    }
}

if (empty($inputFiles)) {
    echo "WARNING: No input XML files found in $inputDir\n";
    echo "\n";
} else {
    echo "Found " . count($inputFiles) . " input file(s): " . implode(', ', $inputFiles) . "\n";
    echo "\n";
}

// Run tests
echo "=== Running Tests ===\n";
echo "\n";

$transformer = new Transformer();

foreach ($targets as $target) {
    echo "Testing target: $target\n";
    echo str_repeat("-", 60) . "\n";
    
    foreach ($inputFiles as $lemmaId) {
        $inputFile = $inputDir . DIRECTORY_SEPARATOR . $lemmaId . '.xml';
        $transformPath = $transformDir . DIRECTORY_SEPARATOR . $target;
        
        // Create output subdirectory for target if it doesn't exist
        $outputTargetDir = $outputDir . DIRECTORY_SEPARATOR . $target;
        if (!is_dir($outputTargetDir)) {
            mkdir($outputTargetDir, 0755, true);
        }
        $extension = substr($target, strpos($target, "-") + 1);
        $outputFile = $outputTargetDir . DIRECTORY_SEPARATOR . $lemmaId . '.' . $extension;
        $expectedFile = $expectedDir . DIRECTORY_SEPARATOR . $target . DIRECTORY_SEPARATOR . $lemmaId . '.' . $extension;
        
        $testCase = [
            'target' => $target,
            'lemma-id' => $lemmaId,
            'input' => $inputFile,
            'output' => $outputFile,
            'expected' => $expectedFile,
            'status' => 'UNKNOWN',
            'error' => null,
            'diff' => false
        ];
        
        try {
            // Perform transformation
            $result = $transformer->transform($inputFile, $transformPath, false);
            
            // Save output
            file_put_contents($outputFile, $result);
            
            // Check if expected file exists
            if (!file_exists($expectedFile)) {
                $testCase['status'] = 'SKIPPED';
                $testCase['error'] = 'Expected file not found';
                echo "  ⊘ $lemmaId: SKIPPED (no expected result)\n";
            } else {
                // Compare output with expected
                $expectedContent = file_get_contents($expectedFile);
                
                if (trim($result) === trim($expectedContent)) {
                    $testCase['status'] = 'PASSED';
                    $testCase['diff'] = false;
                    $passedTests++;
                    echo "  ✓ $lemmaId: PASSED\n";
                } else {
                    $testCase['status'] = 'FAILED';
                    $testCase['diff'] = true;
                    $failedTests++;
                    echo "  ✗ $lemmaId: FAILED (output differs from expected)\n";
                }
            }
        } catch (Exception $e) {
            $testCase['status'] = 'ERROR';
            $testCase['error'] = $e->getMessage();
            $failedTests++;
            echo "  ✗ $lemmaId: ERROR - " . $e->getMessage() . "\n";
        }
        
        $testResults[] = $testCase;
    }
    
    echo "\n";
}

// Print summary
echo "=== Test Summary ===\n";
echo "Passed: $passedTests\n";
echo "Failed: $failedTests\n";
echo "Total: " . count($testResults) . "\n";
echo "\n";

// Print detailed results
echo "=== Detailed Results ===\n";
echo "\n";

$resultsTable = [];
$resultsTable[] = sprintf("%-20s | %-20s | %-10s | %-8s | %s", 
    'TARGET', 'LEMMA-ID', 'STATUS', 'DIFFERS', 'ERROR/INFO');
$resultsTable[] = str_repeat("-", 100);

foreach ($testResults as $result) {
    $differs = $result['diff'] ? 'YES' : 'NO';
    $info = $result['error'] ? $result['error'] : '';
    
    $resultsTable[] = sprintf("%-20s | %-20s | %-10s | %-8s | %s",
        $result['target'],
        $result['lemma-id'],
        $result['status'],
        $differs,
        substr($info, 0, 40)
    );
}

echo implode("\n", $resultsTable) . "\n";
echo "\n";

// Generate JSON report
$reportFile = $baseDir . DIRECTORY_SEPARATOR . 'test' . DIRECTORY_SEPARATOR . 'test-report.json';
$reportData = [
    'timestamp' => date('c'),
    'summary' => [
        'passed' => $passedTests,
        'failed' => $failedTests,
        'total' => count($testResults)
    ],
    'results' => $testResults
];

file_put_contents($reportFile, json_encode($reportData, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
echo "Test report saved to: $reportFile\n";

exit($failedTests > 0 ? 1 : 0);
