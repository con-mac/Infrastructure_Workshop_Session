<?php
/**
 * Health Check Endpoint
 * IT Infrastructure Workshop - University Apprenticeship Programme
 * 
 * This endpoint provides detailed health information about the application
 * and infrastructure components.
 */

header('Content-Type: application/json');
header('Cache-Control: no-cache, must-revalidate');

// Get server information
$server_info = [
    'timestamp' => date('c'),
    'server' => gethostname(),
    'php_version' => phpversion(),
    'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
    'document_root' => $_SERVER['DOCUMENT_ROOT'] ?? 'Unknown',
    'request_uri' => $_SERVER['REQUEST_URI'] ?? 'Unknown',
    'remote_addr' => $_SERVER['REMOTE_ADDR'] ?? 'Unknown',
    'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown'
];

// Check system resources
$system_checks = [
    'disk_space' => [
        'free_bytes' => disk_free_space('/'),
        'total_bytes' => disk_total_space('/'),
        'free_percent' => round((disk_free_space('/') / disk_total_space('/')) * 100, 2),
        'status' => disk_free_space('/') > 1000000000 ? 'ok' : 'low'
    ],
    'memory' => [
        'used_bytes' => memory_get_usage(true),
        'peak_bytes' => memory_get_peak_usage(true),
        'limit_bytes' => ini_get('memory_limit'),
        'status' => memory_get_usage(true) < 100000000 ? 'ok' : 'high'
    ],
    'load_average' => [
        '1min' => sys_getloadavg()[0] ?? 'unknown',
        '5min' => sys_getloadavg()[1] ?? 'unknown',
        '15min' => sys_getloadavg()[2] ?? 'unknown',
        'status' => (sys_getloadavg()[0] ?? 0) < 2.0 ? 'ok' : 'high'
    ]
];

// Check application components
$application_checks = [
    'apache' => [
        'status' => 'running',
        'version' => apache_get_version() ?: 'Unknown',
        'modules' => [
            'mod_rewrite' => in_array('mod_rewrite', apache_get_modules() ?: []),
            'mod_ssl' => in_array('mod_ssl', apache_get_modules() ?: []),
            'mod_headers' => in_array('mod_headers', apache_get_modules() ?: [])
        ]
    ],
    'php' => [
        'status' => 'working',
        'version' => phpversion(),
        'extensions' => [
            'mysql' => extension_loaded('mysql') || extension_loaded('mysqli'),
            'curl' => extension_loaded('curl'),
            'json' => extension_loaded('json'),
            'openssl' => extension_loaded('openssl')
        ]
    ],
    'database' => [
        'status' => 'unknown',
        'connection' => 'not_configured',
        'error' => 'Database connection not configured in this demo'
    ]
];

// Check file system
$filesystem_checks = [
    'web_root' => [
        'path' => $_SERVER['DOCUMENT_ROOT'] ?? '/var/www/html',
        'writable' => is_writable($_SERVER['DOCUMENT_ROOT'] ?? '/var/www/html'),
        'status' => is_writable($_SERVER['DOCUMENT_ROOT'] ?? '/var/www/html') ? 'ok' : 'readonly'
    ],
    'log_directory' => [
        'path' => '/var/log',
        'writable' => is_writable('/var/log'),
        'status' => is_writable('/var/log') ? 'ok' : 'readonly'
    ]
];

// Overall health status
$overall_status = 'healthy';
$issues = [];

// Check for issues
if ($system_checks['disk_space']['status'] !== 'ok') {
    $overall_status = 'degraded';
    $issues[] = 'Low disk space';
}

if ($system_checks['memory']['status'] !== 'ok') {
    $overall_status = 'degraded';
    $issues[] = 'High memory usage';
}

if ($system_checks['load_average']['status'] !== 'ok') {
    $overall_status = 'degraded';
    $issues[] = 'High system load';
}

if (!$filesystem_checks['web_root']['writable']) {
    $overall_status = 'degraded';
    $issues[] = 'Web root not writable';
}

// Build response
$health_response = [
    'status' => $overall_status,
    'timestamp' => date('c'),
    'uptime' => [
        'server' => gethostname(),
        'started' => date('c', $_SERVER['REQUEST_TIME'] ?? time())
    ],
    'server_info' => $server_info,
    'system_checks' => $system_checks,
    'application_checks' => $application_checks,
    'filesystem_checks' => $filesystem_checks,
    'issues' => $issues,
    'workshop_info' => [
        'name' => 'IT Infrastructure Workshop',
        'date' => '2024-10-03',
        'student' => $_SERVER['HTTP_X_STUDENT_NAME'] ?? 'Not Set',
        'environment' => $_SERVER['HTTP_X_ENVIRONMENT'] ?? 'Not Set'
    ]
];

// Set HTTP status code based on health
if ($overall_status === 'healthy') {
    http_response_code(200);
} else {
    http_response_code(503);
}

// Output JSON response
echo json_encode($health_response, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);

// Log health check
$log_entry = [
    'timestamp' => date('c'),
    'status' => $overall_status,
    'server' => gethostname(),
    'issues' => $issues
];

error_log('Health Check: ' . json_encode($log_entry));
?>
