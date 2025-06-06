--!strict
local serde = zune.serde;
local testing = zune.testing;

local expect = testing.expect;

expect(serde.json).toBe(expect.similar({
    encode = expect.type("function"),
    decode = expect.type("function"),
    Indents = expect.similar({
        None = expect.type("number"),
        TwoSpaces = expect.type("number"),
        FourSpaces = expect.type("number"),
        Tabs = expect.type("number"),
    }),
    Values = expect.similar({
        Null = expect.type("table"),
    }),
}));
expect(serde.json5).toBe(expect.similar({
    encode = expect.type("function"),
    decode = expect.type("function"),
    Indents = expect.similar({
        None = expect.type("number"),
        TwoSpaces = expect.type("number"),
        FourSpaces = expect.type("number"),
        Tabs = expect.type("number"),
    }),
    Values = expect.similar({
        Null = expect.type("table"),
    }),
}));
expect(serde.json5.Values).toBe(serde.json.Values);
expect(serde.json5.Indents).toBe(serde.json.Indents);
expect(serde.toml).toBe(expect.similar({
    encode = expect.type("function"),
    decode = expect.type("function"),
}));
expect(serde.yaml).toBe(expect.similar({
    encode = expect.type("function"),
    decode = expect.type("function"),
}));
expect(serde.gzip).toBe(expect.similar({
    compress = expect.type("function"),
    decompress = expect.type("function"),
}));
expect(serde.zlib).toBe(expect.similar({
    compress = expect.type("function"),
    decompress = expect.type("function"),
}));
expect(serde.lz4).toBe(expect.similar({
    compress = expect.type("function"),
    compressFrame = expect.type("function"),
    decompress = expect.type("function"),
    decompressFrame = expect.type("function"),
}));
expect(serde.zstd).toBe(expect.similar({
    compress = expect.type("function"),
    decompress = expect.type("function"),
}));

require("@self/json.test");
require("@self/json5.test");
require("@self/toml.test");
require("@self/yaml.test");
require("@self/gzip.test");
require("@self/zlib.test");
require("@self/lz4.test");
require("@self/zstd.test");
