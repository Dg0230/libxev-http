//! libxev-http Server Example
//!
//! This example demonstrates how to create an HTTP server using libxev-http
//! with different configuration modes.
//!
//! Usage:
//!   zig build run-basic                    # Default mode (basic)
//!   zig build run-basic -- --mode=basic    # Basic mode (default)
//!   zig build run-basic -- --mode=secure   # Secure mode with strict limits
//!   zig build run-basic -- --mode=dev      # Development mode with relaxed limits

const std = @import("std");
const libxev_http = @import("libxev-http");

const ServerMode = enum {
    basic,
    secure,
    dev,

    fn fromString(str: []const u8) ?ServerMode {
        if (std.mem.eql(u8, str, "basic")) return .basic;
        if (std.mem.eql(u8, str, "secure")) return .secure;
        if (std.mem.eql(u8, str, "dev")) return .dev;
        return null;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Parse command line arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var mode: ServerMode = .basic;

    // Parse --mode argument
    for (args[1..]) |arg| {
        if (std.mem.startsWith(u8, arg, "--mode=")) {
            const mode_str = arg[7..];
            mode = ServerMode.fromString(mode_str) orelse {
                std.log.err("Invalid mode: {s}. Valid modes: basic, secure, dev", .{mode_str});
                return;
            };
        }
    }

    // Create server configuration based on mode
    const config = switch (mode) {
        .basic => libxev_http.HttpConfig{
            .port = 8080,
            .max_connections = 1000,
            .log_level = .info,
            // Thread pool configuration
            .enable_thread_pool = true,
            .thread_pool_size = 0,
        },
        .secure => libxev_http.HttpConfig{
            .port = 8082,
            .max_connections = 500,
            .log_level = .info,
            // Strict connection and timeout settings
            .connection_timeout_ms = 20000,
            .request_timeout_ms = 20000,
            .header_timeout_ms = 5000,
            .body_timeout_ms = 10000,
            .idle_timeout_ms = 3000,
            // Strict request size limits
            .max_request_size = 512 * 1024,
            .max_body_size = 5 * 1024 * 1024,
            .max_header_count = 50,
            .max_header_size = 4096,
            .max_uri_length = 1024,
            // Body processing settings
            .body_read_threshold_percent = 20,
            // Enable all protection features
            .enable_request_validation = true,
            .enable_timeout_protection = true,
            // Thread pool configuration
            .enable_thread_pool = true,
            .thread_pool_size = 4,
            .thread_pool_max_queue_size = 1000,
            // Performance settings
            .enable_keep_alive = false,
            .enable_compression = false,
            .enable_cors = false,
        },
        .dev => libxev_http.HttpConfig.development(),
    };

    std.log.info("🚀 Starting libxev-http server in {s} mode...", .{@tagName(mode)});
    std.log.info("Library version: {s}", .{libxev_http.version});

    // Create HTTP server with configuration
    var server = try libxev_http.createServerWithConfig(allocator, "127.0.0.1", config.port, config);
    defer server.deinit();

    // Add global middleware based on mode
    switch (mode) {
        .basic => {
            // Basic middleware for general use
            try server.use("logging", libxev_http.loggingMiddleware);
            try server.use("request-id", libxev_http.requestIdMiddleware);
        },
        .secure => {
            // Comprehensive middleware for secure mode
            try server.use("logging", libxev_http.loggingMiddleware);
            try server.use("request-id", libxev_http.requestIdMiddleware);
            try server.use("security-headers", libxev_http.securityHeadersMiddleware);
            try server.use("json-parser", libxev_http.jsonBodyParserMiddleware);
            try server.use("error-handler", libxev_http.errorHandlerMiddleware);
        },
        .dev => {
            // Development-friendly middleware
            try server.use("logging", libxev_http.loggingMiddleware);
            try server.use("request-id", libxev_http.requestIdMiddleware);
            try server.use("cors", libxev_http.corsMiddleware);
        },
    }

    // Set up common routes
    _ = try server.get("/", indexHandler);
    _ = try server.get("/api/status", statusHandler);
    _ = try server.post("/api/echo", echoHandler);
    _ = try server.get("/users/:id", userHandler);

    // Add additional routes for secure mode
    if (mode == .secure) {
        _ = try server.get("/health", healthHandler);
        _ = try server.get("/config", configHandler);

        // Protected upload endpoint with custom validation
        const upload_route = try server.post("/upload", uploadHandler);
        try upload_route.use("upload-validator", uploadValidationMiddleware);

        // Admin endpoint with basic auth
        const admin_route = try server.get("/admin", adminHandler);
        try admin_route.use("auth", libxev_http.basicAuthMiddleware);

        _ = try server.get("/stress-test", stressTestHandler);
    }

    // Start listening
    try server.listen();
}

fn indexHandler(ctx: *libxev_http.Context) !void {
    // Detect mode based on request host/port (simple heuristic)
    const host_header = ctx.getHeader("Host") orelse "localhost:8080";
    const is_secure_mode = std.mem.indexOf(u8, host_header, ":8082") != null;

    if (is_secure_mode) {
        try ctx.html(
            \\<!DOCTYPE html>
            \\<html lang="en">
            \\<head>
            \\    <meta charset="UTF-8">
            \\    <meta name="viewport" content="width=device-width, initial-scale=1.0">
            \\    <title>libxev-http Server - Secure Mode</title>
            \\    <style>
            \\        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
            \\        .header { text-align: center; color: #333; }
            \\        .security { background: #e8f5e8; padding: 15px; margin: 10px 0; border-radius: 5px; border-left: 4px solid #4caf50; }
            \\        .warning { background: #fff3cd; padding: 15px; margin: 10px 0; border-radius: 5px; border-left: 4px solid #ffc107; }
            \\        .endpoint { background: #f8f9fa; padding: 10px; margin: 5px 0; border-radius: 3px; }
            \\    </style>
            \\</head>
            \\<body>
            \\    <div class="header">
            \\        <h1>🔒 libxev-http Server - Secure Mode</h1>
            \\        <p>High-performance async HTTP framework with enhanced protection</p>
            \\    </div>
            \\
            \\    <div class="security">
            \\        <h3>🛡️ Protection Features Enabled</h3>
            \\        <ul>
            \\            <li>Connection timeout protection (20s total)</li>
            \\            <li>Request processing timeouts (headers: 5s, body: 10s)</li>
            \\            <li>Idle connection timeout (3s)</li>
            \\            <li>Request size limits (512KB total)</li>
            \\            <li>Body size limits (5MB)</li>
            \\            <li>Header count and size limits (50 headers, 4KB each)</li>
            \\            <li>URI length limits (1KB)</li>
            \\            <li>Connection pool management (500 max)</li>
            \\            <li>Thread pool enabled (4 worker threads)</li>
            \\        </ul>
            \\    </div>
            \\
            \\    <div class="warning">
            \\        <h3>⚠️ Timeout Configuration</h3>
            \\        <ul>
            \\            <li>Connection timeout: 20 seconds</li>
            \\            <li>Request timeout: 20 seconds</li>
            \\            <li>Header timeout: 5 seconds</li>
            \\            <li>Body timeout: 10 seconds</li>
            \\            <li>Idle timeout: 3 seconds</li>
            \\            <li>Keep-alive: Disabled</li>
            \\        </ul>
            \\    </div>
            \\
            \\    <div class="security">
            \\        <h3>🔧 Middleware Features</h3>
            \\        <ul>
            \\            <li>Request logging with timing</li>
            \\            <li>Unique request ID generation</li>
            \\            <li>Security headers (XSS, CSRF protection)</li>
            \\            <li>JSON body validation</li>
            \\            <li>Error handling and recovery</li>
            \\            <li>Route-specific authentication</li>
            \\            <li>Custom upload validation</li>
            \\        </ul>
            \\    </div>
            \\
            \\    <div class="endpoint">
            \\        <h3>📚 Available Endpoints</h3>
            \\        <ul>
            \\            <li><a href="/health">GET /health</a> - Health check</li>
            \\            <li><a href="/api/status">GET /api/status</a> - Server status with middleware info</li>
            \\            <li><a href="/config">GET /config</a> - Configuration details</li>
            \\            <li>POST /api/echo - Echo request body</li>
            \\            <li>POST /upload - File upload with validation middleware</li>
            \\            <li>GET /admin - Protected admin panel (requires Basic auth: user/pass)</li>
            \\            <li><a href="/stress-test">GET /stress-test</a> - Timeout test</li>
            \\            <li>GET /users/:id - User profile (try <a href="/users/123">/users/123</a>)</li>
            \\        </ul>
            \\    </div>
            \\</body>
            \\</html>
        );
    } else {
        try ctx.html(
            \\<!DOCTYPE html>
            \\<html lang="en">
            \\<head>
            \\    <meta charset="UTF-8">
            \\    <meta name="viewport" content="width=device-width, initial-scale=1.0">
            \\    <title>libxev-http Server</title>
            \\    <style>
            \\        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
            \\        .header { text-align: center; color: #333; }
            \\        .feature { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
            \\        .mode-info { background: #e3f2fd; padding: 15px; margin: 10px 0; border-radius: 5px; border-left: 4px solid #2196f3; }
            \\    </style>
            \\</head>
            \\<body>
            \\    <div class="header">
            \\        <h1>🚀 libxev-http Server</h1>
            \\        <p>High-performance async HTTP framework for Zig</p>
            \\    </div>
            \\
            \\    <div class="mode-info">
            \\        <h3>🎯 Server Modes</h3>
            \\        <p>This server supports multiple configuration modes:</p>
            \\        <ul>
            \\            <li><strong>Basic Mode</strong> (port 8080) - Default configuration</li>
            \\            <li><strong>Secure Mode</strong> (port 8082) - Strict timeouts and limits</li>
            \\            <li><strong>Dev Mode</strong> (port varies) - Relaxed settings for development</li>
            \\        </ul>
            \\        <p>Use <code>--mode=secure</code> to enable enhanced protection features.</p>
            \\    </div>
            \\
            \\    <div class="feature">
            \\        <h3>⚡ Async Event-Driven</h3>
            \\        <p>Built on libxev for maximum performance and scalability</p>
            \\    </div>
            \\
            \\    <div class="feature">
            \\        <h3>🛣️ Advanced Routing</h3>
            \\        <p>Parameter extraction, wildcards, and middleware support</p>
            \\    </div>
            \\
            \\    <div class="feature">
            \\        <h3>� Middleware System</h3>
            \\        <p>Global and route-specific middleware with built-in common functionality</p>
            \\        <ul>
            \\            <li>Request logging and timing</li>
            \\            <li>Request ID generation</li>
            \\            <li>CORS support (dev mode)</li>
            \\        </ul>
            \\    </div>
            \\
            \\    <div class="feature">
            \\        <h3>�🔒 Production Ready</h3>
            \\        <p>Memory safe, cross-platform, and battle-tested</p>
            \\    </div>
            \\
            \\    <div class="feature">
            \\        <h3>📚 API Endpoints</h3>
            \\        <ul>
            \\            <li><a href="/api/status">GET /api/status</a> - Server status with middleware info</li>
            \\            <li>POST /api/echo - Echo request body</li>
            \\            <li>GET /users/:id - User profile (try <a href="/users/123">/users/123</a>)</li>
            \\        </ul>
            \\    </div>
            \\</body>
            \\</html>
        );
    }
}

fn statusHandler(ctx: *libxev_http.Context) !void {
    const timestamp = std.time.timestamp();
    const request_id = ctx.getState("request_id") orelse "unknown";

    // Detect mode based on request host/port
    const host_header = ctx.getHeader("Host") orelse "localhost:8080";
    const mode_str = if (std.mem.indexOf(u8, host_header, ":8082") != null) "secure" else "basic";

    const security_headers = if (std.mem.eql(u8, mode_str, "secure")) "true" else "false";
    const cors_support = if (std.mem.eql(u8, mode_str, "dev")) "true" else "false";

    const status_json = try std.fmt.allocPrint(ctx.allocator,
        \\{{
        \\  "status": "ok",
        \\  "server": "libxev-http",
        \\  "version": "{s}",
        \\  "mode": "{s}",
        \\  "request_id": "{s}",
        \\  "timestamp": {d},
        \\  "middleware": {{
        \\    "global_enabled": true,
        \\    "request_logging": true,
        \\    "request_id_generation": true,
        \\    "security_headers": {s},
        \\    "cors_support": {s}
        \\  }}
        \\}}
    , .{ libxev_http.version, mode_str, request_id, timestamp, security_headers, cors_support });
    defer ctx.allocator.free(status_json);

    try ctx.json(status_json);
}

fn echoHandler(ctx: *libxev_http.Context) !void {
    const body = ctx.getBody() orelse "No body received";

    const echo_json = try std.fmt.allocPrint(ctx.allocator,
        \\{{"echo":"{s}","length":{d},"method":"{s}"}}
    , .{ body, body.len, ctx.getMethod() });
    defer ctx.allocator.free(echo_json);

    try ctx.json(echo_json);
}

fn userHandler(ctx: *libxev_http.Context) !void {
    const user_id = ctx.getParam("id") orelse "unknown";

    const user_json = try std.fmt.allocPrint(ctx.allocator,
        \\{{"user_id":"{s}","name":"User {s}","email":"user{s}@example.com"}}
    , .{ user_id, user_id, user_id });
    defer ctx.allocator.free(user_json);

    try ctx.json(user_json);
}

fn healthHandler(ctx: *libxev_http.Context) !void {
    const timestamp = std.time.timestamp();
    const health_json = try std.fmt.allocPrint(ctx.allocator,
        \\{{
        \\  "status": "healthy",
        \\  "mode": "secure",
        \\  "protection": {{
        \\    "timeout_protection": true,
        \\    "request_validation": true,
        \\    "size_limits": true
        \\  }},
        \\  "timestamp": {}
        \\}}
    , .{timestamp});
    defer ctx.allocator.free(health_json);

    try ctx.json(health_json);
}

fn configHandler(ctx: *libxev_http.Context) !void {
    try ctx.json(
        \\{
        \\  "server_config": {
        \\    "max_request_size": 524288,
        \\    "max_body_size": 5242880,
        \\    "max_header_count": 50,
        \\    "max_header_size": 4096,
        \\    "max_uri_length": 1024,
        \\    "connection_timeout_ms": 20000,
        \\    "request_timeout_ms": 20000,
        \\    "header_timeout_ms": 5000,
        \\    "body_timeout_ms": 10000,
        \\    "idle_timeout_ms": 3000,
        \\    "body_read_threshold_percent": 20,
        \\    "enable_request_validation": true,
        \\    "enable_timeout_protection": true
        \\  },
        \\  "limits": {
        \\    "request_size": "512KB",
        \\    "body_size": "5MB",
        \\    "headers": "50 max, 4KB each",
        \\    "uri_length": "1KB"
        \\  },
        \\  "timeouts": {
        \\    "connection": "20s",
        \\    "request": "20s",
        \\    "headers": "5s",
        \\    "body": "10s",
        \\    "idle": "3s"
        \\  },
        \\  "protection": {
        \\    "request_validation": "enabled",
        \\    "timeout_protection": "enabled",
        \\    "size_limits": "enabled"
        \\  }
        \\}
    );
}

fn uploadHandler(ctx: *libxev_http.Context) !void {
    const body = ctx.getBody() orelse "";
    const request_id = ctx.getState("request_id") orelse "unknown";
    const upload_validated = ctx.getState("upload_validated") orelse "false";

    if (body.len == 0) {
        ctx.status(.bad_request);
        try ctx.json(
            \\{
            \\  "error": "No data uploaded",
            \\  "message": "Please provide data in the request body"
            \\}
        );
        return;
    }

    const status_str = if (body.len <= 5242880) "accepted" else "rejected";
    const response = try std.fmt.allocPrint(ctx.allocator,
        \\{{
        \\  "message": "Upload received",
        \\  "request_id": "{s}",
        \\  "size": {},
        \\  "max_allowed": 5242880,
        \\  "status": "{s}",
        \\  "validation_passed": {s},
        \\  "middleware_applied": ["upload-validator"],
        \\  "security_check": "passed"
        \\}}
    , .{ request_id, body.len, status_str, upload_validated });
    defer ctx.allocator.free(response);

    if (body.len > 5242880) {
        ctx.status(.payload_too_large);
    }

    try ctx.json(response);
}

fn stressTestHandler(ctx: *libxev_http.Context) !void {
    // Simulate some processing time to test timeouts
    std.time.sleep(2 * std.time.ns_per_s); // 2 seconds

    try ctx.json(
        \\{
        \\  "message": "Stress test completed",
        \\  "processing_time": "2 seconds",
        \\  "note": "This endpoint tests timeout handling"
        \\}
    );
}

fn adminHandler(ctx: *libxev_http.Context) !void {
    const request_id = ctx.getState("request_id") orelse "unknown";

    const admin_json = try std.fmt.allocPrint(ctx.allocator,
        \\{{
        \\  "message": "Admin panel access granted",
        \\  "request_id": "{s}",
        \\  "middleware_applied": ["logging", "request-id", "security-headers", "json-parser", "error-handler", "auth"],
        \\  "timestamp": {d},
        \\  "note": "This endpoint requires HTTP Basic authentication"
        \\}}
    , .{ request_id, std.time.timestamp() });
    defer ctx.allocator.free(admin_json);

    try ctx.json(admin_json);
}

// Custom middleware for upload validation
fn uploadValidationMiddleware(ctx: *libxev_http.Context, next: libxev_http.NextFn) !void {
    std.log.info("🔍 Upload validation middleware executing", .{});

    const content_type = ctx.getHeader("Content-Type");
    const content_length = ctx.getHeader("Content-Length");

    // Validate Content-Type
    if (content_type == null) {
        ctx.status(.bad_request);
        try ctx.json(
            \\{
            \\  "error": "Content-Type header required",
            \\  "message": "Please specify the content type of your upload"
            \\}
        );
        return;
    }

    // Validate Content-Length
    if (content_length != null) {
        const length = std.fmt.parseInt(usize, content_length.?, 10) catch 0;
        if (length > 5242880) { // 5MB limit
            ctx.status(.payload_too_large);
            try ctx.json(
                \\{
                \\  "error": "File too large",
                \\  "message": "Maximum upload size is 5MB",
                \\  "max_size": 5242880
                \\}
            );
            return;
        }
    }

    // Set validation state
    try ctx.setState("upload_validated", "true");
    try ctx.setHeader("X-Upload-Validation", "passed");

    std.log.info("✅ Upload validation passed", .{});

    return next(ctx);
}
