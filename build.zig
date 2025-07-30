const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    print("Building LoRa WiFi Community website...\n", .{});

    // Ensure public directory exists
    try fs.cwd().makePath("public");

    // Copy static files
    try copyFile("src/index.html", "public/index.html");
    try copyFile("src/style.css", "public/style.css");
    try copyFile("src/script.js", "public/script.js");

    // Create CNAME file for custom domain (optional)
    const cname_file = try fs.cwd().createFile("public/CNAME", .{});
    defer cname_file.close();
    try cname_file.writeAll("lora-wifi.community");

    // Create .nojekyll file to bypass Jekyll processing
    const nojekyll = try fs.cwd().createFile("public/.nojekyll", .{});
    defer nojekyll.close();

    print("Build complete! Files generated in public/\n", .{});
}

fn copyFile(src: []const u8, dest: []const u8) !void {
    const src_file = try fs.cwd().openFile(src, .{});
    defer src_file.close();

    const dest_file = try fs.cwd().createFile(dest, .{});
    defer dest_file.close();

    try dest_file.writeFileAll(src_file, .{});
}