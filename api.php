<?php
/**
 * XSLT Pipeline API
 * 
 * RESTful API for applying sequential XSLT 3.0 transformations
 */

header('Content-Type: application/xml; charset=utf-8');

require_once __DIR__ . '/src/transformer.php';

// Get request method
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Extract path components
$pathParts = array_filter(explode('/', $path));

// Simple router
if (end($pathParts) === 'transform') {
    switch ($method) {
        case 'GET':
            handleGetTransform();
            break;
        case 'POST':
            handlePostTransform();
            break;
        default:
            sendError(405, 'Method not allowed');
    }
} else {
    sendError(404, 'Endpoint not found');
}

/**
 * Handle GET /transform?lemma-id=...&target=...
 */
function handleGetTransform() {
    $lemmaId = isset($_GET['lemma-id']) ? trim($_GET['lemma-id']) : null;
    $target = isset($_GET['target']) ? trim($_GET['target']) : null;
    
    if (!$lemmaId || !$target) {
        sendError(400, 'Missing required parameters: lemma-id, target');
        return;
    }
    
    performTransform($lemmaId, $target);
}

/**
 * Handle POST /transform with JSON body
 */
function handlePostTransform() {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        sendError(400, 'Invalid JSON in request body');
        return;
    }
    
    $lemmaId = isset($input['lemma-id']) ? trim($input['lemma-id']) : null;
    $target = isset($input['target']) ? trim($input['target']) : null;
    
    if (!$lemmaId || !$target) {
        sendError(400, 'Missing required fields in JSON: lemma-id, target');
        return;
    }
    
    performTransform($lemmaId, $target);
}

/**
 * Perform the actual transformation
 */
function performTransform($lemmaId, $target) {
    try {
        $baseDir = dirname(__FILE__);
        
        // Validate inputs - prevent directory traversal
        if (preg_match('/[\/\\.]/', $lemmaId) || preg_match('/[\/\\.]/', $target)) {
            sendError(400, 'Invalid lemma-id or target format');
            return;
        }
        
        $inputFile = $baseDir . DIRECTORY_SEPARATOR . 'input' . DIRECTORY_SEPARATOR . $lemmaId . '.xml';
        $transformDir = $baseDir . DIRECTORY_SEPARATOR . 'transforms' . DIRECTORY_SEPARATOR . $target;
        
        // Check if files exist
        if (!file_exists($inputFile)) {
            sendError(404, "Input file not found: input/$lemmaId.xml");
            return;
        }
        
        if (!is_dir($transformDir)) {
            sendError(404, "Transform directory not found: transforms/$target");
            return;
        }
        
        // Create transformer and perform transformation
        $transformer = new Transformer();
        $result = $transformer->transform($inputFile, $transformDir, true);

        $contentType = getContentTypeForTarget($target);
        if (!headers_sent() && PHP_SAPI !== 'cli') {
           header('Content-Type: ' . $contentType);
        }
        
        // Return XML result
        echo $result;
        
    } catch (Exception $e) {
        sendError(500, 'Transformation error: ' . $e->getMessage());
    }
}

/**
 * Send error response
 */
function sendError($statusCode, $message) {
    http_response_code($statusCode);
    echo sprintf('<?xml version="1.0" encoding="UTF-8"?><error><code>%d</code><message>%s</message></error>', 
        $statusCode, 
        htmlspecialchars($message)
    );
}


  function getContentTypeForTarget($target) {
        $extension = substr($target, strrpos($target, '-') + 1);
        return getContentTypeForExtension($extension);
    }
    /**
     * Get content type based on file extension
     * 
     * @param string $extension
     * @return string
     */
  function getContentTypeForExtension($extension) {
        switch (strtolower($extension)) {
            case 'xml':
                return 'application/xml';
            case 'csv':
                return 'text/csv';
            case 'tsv':
                return 'text/tab-separated-values';
            default:
                return 'application/octet-stream';
        }
    }
