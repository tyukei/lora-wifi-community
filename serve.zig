const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const address = std.net.Address.parseIp("127.0.0.1", 8000) catch unreachable;
    var server = try std.net.Address.listen(address, .{ .reuse_address = true });
    defer server.deinit();

    std.debug.print("🚀 LoRa WiFi Community server running on http://localhost:8000\n", .{});
    std.debug.print("📁 Serving files from ./src/\n", .{});
    std.debug.print("⏹️  Press Ctrl+C to stop\n\n", .{});

    while (true) {
        const connection = server.accept() catch |err| {
            std.debug.print("Error accepting connection: {}\n", .{err});
            continue;
        };
        defer connection.stream.close();

        handleConnection(allocator, connection.stream) catch |err| {
            std.debug.print("Error handling connection: {}\n", .{err});
        };
    }
}

fn handleConnection(allocator: std.mem.Allocator, stream: std.net.Stream) !void {
    var buffer: [4096]u8 = undefined;
    const bytes_read = try stream.read(&buffer);
    
    if (bytes_read == 0) return;
    
    const request = buffer[0..bytes_read];
    
    // Parse HTTP request line
    var lines = std.mem.splitSequence(u8, request, "\r\n");
    const request_line = lines.next() orelse return;
    
    var parts = std.mem.splitSequence(u8, request_line, " ");
    _ = parts.next(); // method
    const path = parts.next() orelse return;
    
    std.debug.print("📄 {s}\n", .{path});
    
    // Determine file path
    var file_path: []const u8 = undefined;
    if (std.mem.eql(u8, path, "/")) {
        file_path = "src/index.html";
    } else {
        file_path = try std.fmt.allocPrint(allocator, "src{s}", .{path});
        defer allocator.free(file_path);
        return serveFile(stream, file_path);
    }
    
    try serveFile(stream, file_path);
}

fn serveFile(stream: std.net.Stream, file_path: []const u8) !void {
    const file = std.fs.cwd().openFile(file_path, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            const response = "HTTP/1.1 404 Not Found\r\nContent-Type: text/html\r\nContent-Length: 47\r\n\r\n<html><body><h1>404 - File Not Found</h1></body></html>";
            try stream.writeAll(response);
            return;
        },
        else => return err,
    };
    defer file.close();

    const content = try file.readToEndAlloc(std.heap.page_allocator, 10 * 1024 * 1024);
    defer std.heap.page_allocator.free(content);
    
    const content_type = getContentType(file_path);
    
    const header = try std.fmt.allocPrint(
        std.heap.page_allocator,
        "HTTP/1.1 200 OK\r\nContent-Type: {s}\r\nContent-Length: {d}\r\n\r\n",
        .{ content_type, content.len }
    );
    defer std.heap.page_allocator.free(header);
    
    try stream.writeAll(header);
    try stream.writeAll(content);
}

fn getContentType(file_path: []const u8) []const u8 {
    if (std.mem.endsWith(u8, file_path, ".html")) return "text/html";
    if (std.mem.endsWith(u8, file_path, ".css")) return "text/css";
    if (std.mem.endsWith(u8, file_path, ".js")) return "text/javascript";
    if (std.mem.endsWith(u8, file_path, ".json")) return "application/json";
    if (std.mem.endsWith(u8, file_path, ".png")) return "image/png";
    if (std.mem.endsWith(u8, file_path, ".jpg") or std.mem.endsWith(u8, file_path, ".jpeg")) return "image/jpeg";
    return "text/plain";
}