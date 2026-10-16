<?php
/**
 * XSLT Pipeline Transformer
 * 
 * Applies multiple XSLT 3.0 transformations in sequence using Saxon-HE 12.9
 */

class Transformer {
    
    private $saxonJarPath = null;
    private ?string $saxonBashPath = null;
    private ?string $commandSuffix = null;
    private $tempDir;
    
    /**
     * Constructor
     * @param string|null $saxonJarPath Path to Saxon-HE JAR file (optional)
     * @param string|null $saxonBashPath Path to Saxon-HE bash script (optional, for custom installations, has priority over jar path)
     * @param string|null $commandSuffix Suffix for the Saxon command (optional)
     */
    public function __construct($saxonJarPath = null, $saxonBashPath = null, $commandSuffix = null) {
        if ($saxonJarPath === null) {
            $saxonJarPath = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'lib' . DIRECTORY_SEPARATOR . 'saxon-he-12.9.jar';
        }
        $this->saxonJarPath = $saxonJarPath;
        $this->saxonBashPath = $saxonBashPath;
        $this->commandSuffix = $commandSuffix;
        $this->tempDir = sys_get_temp_dir();
    }
    
    /**
     * Transform XML using a sequence of XSLT files
     * 
     * @param string $inputXmlPath Path to input XML file
     * @param string $transformDir Directory containing XSLT files (001-*.xsl, 002-*.xsl, etc.)
     * @param bool $saveOutput Whether to save output to output directory
     * @return string|null The transformed XML content, or null on error
     */
    public function transform($inputXmlPath, $transformDir, $saveOutput = false) {
        if (!file_exists($inputXmlPath)) {
            throw new Exception("Input XML file not found: $inputXmlPath");
        }
        
        if (!is_dir($transformDir)) {
            throw new Exception("Transform directory not found: $transformDir");
        }
        
        // Collect and sort XSLT files
        $xsltFiles = $this->getOrderedXsltFiles($transformDir);
        if (empty($xsltFiles)) {
            throw new Exception("No XSLT files found in: $transformDir");
        }
        
        // Apply transformations in sequence
        $currentInput = $inputXmlPath;
        $output = null;
        
        foreach ($xsltFiles as $xsltFile) {
            $tempOutput = $this->getTempFile();
            
            try {
                $this->applyXslt($currentInput, $xsltFile, $tempOutput);
                
                // If this isn't the first transformation, delete the previous temp file
                if ($currentInput !== $inputXmlPath && file_exists($currentInput)) {
                    unlink($currentInput);
                }
                
                $currentInput = $tempOutput;
            } catch (Exception $e) {
                if (file_exists($tempOutput)) {
                    unlink($tempOutput);
                }
                throw new Exception("XSLT transformation failed at $xsltFile: " . $e->getMessage());
            }
        }
        
        // Read final output
        if (file_exists($currentInput)) {
            $output = file_get_contents($currentInput);
            
            // Cleanup temp file if it's not the original input
            if ($currentInput !== $inputXmlPath) {
                unlink($currentInput);
            }
            
            return $output;
        }
        
        throw new Exception("Transformation produced no output");
    }
    
    /**
     * Get XSLT files sorted by sequence prefix (001, 002, etc.)
     * 
     * @param string $directory
     * @return array Array of full paths to XSLT files sorted by sequence number
     */
    private function getOrderedXsltFiles($directory) {
        $files = [];
        
        if ($handle = opendir($directory)) {
            while (false !== ($file = readdir($handle))) {
                if (preg_match('/^\d{3}-.*\.xsl$/i', $file)) {
                    $files[$file] = $directory . DIRECTORY_SEPARATOR . $file;
                }
            }
            closedir($handle);
        }
        
        // Sort by filename (which includes the sequence number)
        ksort($files);
        
        return array_values($files);
    }
    
    /**
     * Apply single XSLT transformation
     * 
     * @param string $inputPath
     * @param string $xsltPath
     * @param string $outputPath
     * @throws Exception
     */
    private function applyXslt($inputPath, $xsltPath, $outputPath, $showDetailErrMsg = false) {
        // Build Saxon command
        // Saxon-HE requires Java to be installed
        
        if ($this->saxonBashPath !== null) {
            $command = sprintf(
                '%s -s:%s -xsl:%s -o:%s',
                escapeshellarg($this->saxonBashPath),
                escapeshellarg($inputPath),
                escapeshellarg($xsltPath),
                escapeshellarg($outputPath)
            );
        } else {
            $javaCmd = $this->getJavaCommand();
            $command = sprintf(
                '%s -jar %s -s:%s -xsl:%s -o:%s',
                $javaCmd,
                escapeshellarg($this->saxonJarPath),
                escapeshellarg($inputPath),
                escapeshellarg($xsltPath),
                escapeshellarg($outputPath)
            );
        }
        
        if ($this->commandSuffix !== null) {
            $command .= " " . $this->commandSuffix;
        }

        
        $output = [];
        $returnCode = 0;
        
        exec($command, $output, $returnCode);
        
        if ($returnCode !== 0) {
            $errorMsg = implode("\n", $output);
            if ($showDetailErrMsg) {
                throw new Exception("Saxon-HE execution failed: $errorMsg (return code: $returnCode)\nCommand: $command");
            } else {
                throw new Exception("Saxon-HE execution failed: $errorMsg");
            }
        }
        
        if (!file_exists($outputPath)) {
            throw new Exception("Output file was not created by Saxon-HE");
        }
    }
    
    /**
     * Get Java command (java or java.exe depending on platform)
     * 
     * @return string
     */
    private function getJavaCommand() {
        // On Windows, try java.exe; on Unix, try java
        $javaCmd = (PHP_OS_FAMILY === 'Windows') ? 'java.exe' : 'java';
        
        return $javaCmd;
    }
    
    /**
     * Generate a temporary file path
     * 
     * @return string
     */
    private function getTempFile() {
        return $this->tempDir . DIRECTORY_SEPARATOR . 'xslt_' . uniqid() . '.xml';
    }
}
