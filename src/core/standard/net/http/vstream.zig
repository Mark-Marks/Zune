const std = @import("std");

const Self = @This();

stream: std.net.Stream,
tls: ?std.crypto.tls.Client,

pub const ReadError = anyerror;
pub const WriteError = anyerror;

pub const Reader = std.io.Reader(*Self, ReadError, read);
pub const Writer = std.io.Writer(*Self, WriteError, write);

pub fn reader(self: *Self) Reader {
    return .{ .context = self };
}

pub fn writer(self: *Self) Writer {
    return .{ .context = self };
}

pub fn init(stream: std.net.Stream, tls: ?std.crypto.tls.Client) Self {
    return .{
        .stream = stream,
        .tls = tls,
    };
}

pub fn close(self: *Self) void {
    if (self.tls) |*tls|
        _ = tls.writeAllEnd(self.stream, "", true) catch {};
    self.stream.close();
}

pub fn write(self: *Self, buffer: []const u8) !usize {
    if (self.tls) |*tls|
        return tls.write(self.stream, buffer);
    return self.stream.write(buffer);
}

pub fn read(self: *Self, buffer: []u8) !usize {
    if (self.tls) |*tls|
        return tls.read(self.stream, buffer);
    return self.stream.read(buffer);
}

pub fn readAll(self: *Self, buffer: []u8) !usize {
    if (self.tls) |*tls|
        return tls.readAll(self.stream, buffer);
    return self.stream.readAll(buffer);
}

pub fn writeAll(self: *Self, data: []const u8) !void {
    if (self.tls) |*tls|
        return tls.writeAll(self.stream, data);
    return self.stream.writeAll(data);
}
