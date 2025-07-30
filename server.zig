const std = @import("std");
const http = std.http;
const net = std.net;
const fs = std.fs;
const print = std.debug.print;

const MIME_TYPES = std.ComptimeStringMap([]const u8, .{
    .{ ".html", "text/html" },
    .{ ".css", "text/css" },
    .{ ".js", "text/javascript" },
    .{ ".json", "application/json" },
    .{ ".png", "image/png" },
    .{ ".jpg", "image/jpeg" },
    .{ ".jpeg", "image/jpeg" },
    .{ ".gif", "image/gif" },
    .{ ".svg", "image/svg+xml" },
    .{ ".ico", "image/x-icon" },
});

fn getMimeType(path: []const u8) []const u8 {
    const ext = std.fs.path.extension(path);
    return MIME_TYPES.get(ext) orelse "text/plain";
}

fn serveFile(allocator: std.mem.Allocator, response: *http.Server.Response, file_path: []const u8) !void {
    const file = fs.cwd().openFile(file_path, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            try response.writeAll("HTTP/1.1 404 Not Found\r\nContent-Length: 13\r\n\r\n404 Not Found");
            return;
        },
        else => return err,
    };
    defer file.close();

    const file_size = try file.getEndPos();
    const content = try allocator.alloc(u8, file_size);
    defer allocator.free(content);
    
    _ = try file.readAll(content);
    
    const mime_type = getMimeType(file_path);
    
    try response.headers.append("content-type", mime_type);
    try response.headers.append("content-length", try std.fmt.allocPrint(allocator, "{d}", .{content.len}));
    try response.do();
    try response.writeAll(content);
}

fn handleRequest(allocator: std.mem.Allocator, response: *http.Server.Response, request: http.Server.Request) !void {
    const uri = request.head.target;
    
    print("Request: {s}\n", .{uri});
    
    var file_path: []const u8 = undefined;
    
    if (std.mem.eql(u8, uri, "/")) {
        file_path = "src/index.html";
    } else {
        file_path = try std.fmt.allocPrint(allocator, "src{s}", .{uri});
        defer allocator.free(file_path);
        return serveFile(allocator, response, file_path);
    }
    
    try serveFile(allocator, response, file_path);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const port = 8000;
    const address = try net.Address.parseIp("127.0.0.1", port);
    
    var server = http.Server.init(allocator, .{ .reuse_address = true });
    defer server.deinit();
    
    try server.listen(address);
    print("Server running on http://localhost:{d}/\n", .{port});
    print("Press Ctrl+C to stop\n");
    
    while (true) {
        var response = try server.accept(.{ .allocator = allocator });
        defer response.deinit();
        
        while (response.reset() != .closing) {
            response.wait() catch |err| switch (err) {
                error.HttpHeadersInvalid => continue,
                error.EndOfStream => continue,
                else => return err,
            };
            
            handleRequest(allocator, &response, response.request) catch |err| {
                print("Error handling request: {}\n", .{err});
                continue;
            };
        }
    }
}