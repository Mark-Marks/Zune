--!strict
local testing = zune.testing;

local describe = testing.describe;

local _, version, _ = string.match(_VERSION, "(Zune) (%d+%.%d+%.%d+.*)+(%d+%.%d+)");
assert(version and #version > 0, "No version");

describe("Server", function()
    require("@self/http/server.test");
end)

describe("Requests", function()
    require("@self/http/request.test");
end)

describe("WebSockets", function()
    require("@self/http/websocket.test");
end)
