local task = zune.task;
local testing = zune.testing;

local describe = testing.describe;
local expect = testing.expect;
local test = testing.test;

describe("task", function()
    describe("function", function()
        describe("regular", function()
            test("Sleep", function()
                local delta = task.wait(0.051);
                expect(delta).toBeGreaterThanOrEqual(0.05);
                expect(delta).toBeLessThanOrEqual(0.1);
            end)
            test("Spawn", function()
                local success, err;
                local task_ret = {task.spawn(function(a, b, c)
                    success, err = pcall(function()
                        expect(a).toBe(1);
                        expect(b).toBe(4);
                        expect(c).toBe(8);
                    end)
                end, 1, 4, 8)};
                assert(success, err);
                expect(task_ret).toHaveLength(1);
                expect(task_ret[1]).toBe(expect.any("thread"));
                expect(coroutine.status(task_ret[1])).toBe("dead");
                expect(success).toBeTruthy();
                expect(err).toBeNil();
            end)
            test("Defer", function()
                local success, err;
                local task_ret = {task.defer(function(a, b, c)
                    success, err = pcall(function()
                        expect(a).toBe(1);
                        expect(b).toBe(4);
                        expect(c).toBe(8);
                    end)
                end, 1, 4, 8)};
                expect(task_ret).toHaveLength(1);
                expect(task_ret[1]).toBe(expect.any("thread"));
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                expect(task.count("d")).toBe(1);
                task.wait(0.5);
                expect(task.count("d")).toBe(0);
                expect(coroutine.status(task_ret[1])).toBe("dead");
                expect(success).toBeTruthy();
                expect(err).toBeNil();
            end)
            test("Delay", function()
                local success, err;
                local task_ret = {task.delay(0.1, function(a, b, c)
                    success, err = pcall(function()
                        expect(a).toBe(1);
                        expect(b).toBe(4);
                        expect(c).toBe(8);
                    end)
                end, 1, 4, 8)};
                expect(task_ret).toHaveLength(1);
                expect(task_ret[1]).toBe(expect.any("thread"));
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                expect(task.count("s")).toBe(1);
                task.wait(0.2);
                expect(task.count("s")).toBe(0);
                expect(coroutine.status(task_ret[1])).toBe("dead");
                expect(success).toBeTruthy();
                expect(err).toBeNil();
            end)
        end)
        describe("cancel", function()
            test("Spawn", function()
                local success;
                local task_ret = {task.spawn(function()
                    task.wait();
                    success = 0;
                    task.wait(0.25);
                    success = 1;
                end)};
                expect(task_ret).toHaveLength(1);
                expect(task_ret[1]).toBe(expect.any("thread"));
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                expect(task.count("s")).toBe(1);
                task.wait(0.05);
                expect(task.count("s")).toBe(1);
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                task.cancel(task_ret[1]);
                expect(coroutine.status(task_ret[1])).toBe("dead");
                task.wait(0.5);
                expect(task.count("s")).toBe(0);
                expect(success).toBe(0);
            end)
            test("Defer", function()
                local success;
                local task_ret = {task.defer(function()
                    success = 0;
                    task.wait(0.25);
                    success = 1;
                end)};
                expect(task_ret).toHaveLength(1);
                expect(task_ret[1]).toBe(expect.any("thread"));
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                expect(task.count("d")).toBe(1);
                expect(task.count("s")).toBe(0);
                task.wait(0.05);
                expect(task.count("d")).toBe(0);
                expect(task.count("s")).toBe(1);
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                task.cancel(task_ret[1]);
                expect(task.count("d")).toBe(0);
                expect(task.count("s")).toBe(0);
                expect(coroutine.status(task_ret[1])).toBe("dead");
                task.wait(0.5);
                expect(success).toBe(0);
            end)
            test("Delay", function()
                local success;
                local task_ret = {task.delay(0, function()
                    success = 0;
                    task.wait(0.25);
                    success = 1;
                end)};
                expect(task_ret).toHaveLength(1);
                expect(task_ret[1]).toBe(expect.any("thread"));
                expect(task.count("s")).toBe(1);
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                task.wait(0.05);
                expect(task.count("s")).toBe(1);
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                task.cancel(task_ret[1]);
                expect(task.count("s")).toBe(0);
                expect(coroutine.status(task_ret[1])).toBe("dead");
                task.wait(0.5);
                expect(success).toBe(0);
            end)
        end)
    end)

    describe("thread", function()
        describe("regular", function()
            test("Sleep", function()
                local success, err;
                local thread = coroutine.create(function()
                    success, err = pcall(function()
                        local delta = task.wait(0.25);
                        expect(delta).toBeGreaterThanOrEqual(0.249);
                        expect(delta).toBeLessThanOrEqual(0.5);
                    end)
                end)
                expect(coroutine.status(thread)).toBe("suspended");
                coroutine.resume(thread);
                expect(coroutine.status(thread)).toBe("suspended");
                task.wait(0.5);
                expect(coroutine.status(thread)).toBe("dead");
                expect(success).toBeTruthy();
                expect(err).toBeNil();
            end)
            test("Spawn", function()
                local success, err;
                local thread = coroutine.create(function(a, b, c)
                    success, err = pcall(function()
                        expect(a).toBe(1);
                        expect(b).toBe(4);
                        expect(c).toBe(8);
                    end)
                end)
                local task_ret = {task.spawn(thread, 1, 4, 8)};
                assert(success, err);
                expect(task_ret).toHaveLength(1);
                expect(task_ret[1]).toBe(expect.any("thread"));
                expect(task_ret[1]).toBe(thread);
                expect(coroutine.status(task_ret[1])).toBe("dead");
                expect(success).toBeTruthy();
                expect(err).toBeNil();
            end)
            test("Defer", function()
                local success, err;
                local thread = coroutine.create(function(a, b, c)
                    success, err = pcall(function()
                        expect(a).toBe(1);
                        expect(b).toBe(4);
                        expect(c).toBe(8);
                    end)
                end)
                local task_ret = {task.defer(thread, 1, 4, 8)};
                expect(task_ret).toHaveLength(1);
                expect(task_ret[1]).toBe(expect.any("thread"));
                expect(task_ret[1]).toBe(thread);
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                task.wait(0.5);
                expect(coroutine.status(task_ret[1])).toBe("dead");
                expect(success).toBeTruthy();
                expect(err).toBeNil();
            end)
            test("Delay", function()
                local success, err;
                local startTime = os.clock();
                local thread = coroutine.create(function(a, b, c)
                    local endTime = os.clock() - startTime;
                    success, err = pcall(function()
                        expect(endTime).toBeGreaterThanOrEqual(0.249);
                        expect(endTime).toBeLessThanOrEqual(0.5);
                        expect(a).toBe(1);
                        expect(b).toBe(4);
                        expect(c).toBe(8);
                    end)
                end)
                local task_ret = {task.delay(0.25, thread, 1, 4, 8)};
                expect(task_ret).toHaveLength(1);
                expect(task_ret[1]).toBe(expect.any("thread"));
                expect(task_ret[1]).toBe(thread);
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                task.wait(0.5);
                expect(coroutine.status(task_ret[1])).toBe("dead");
                expect(success).toBeTruthy();
                expect(err).toBeNil();
            end)
        end)
        describe("cancel", function()
            test("Spawn", function()
                local success;
                local thread = coroutine.create(function()
                    task.wait();
                    success = 0;
                    task.wait(0.25);
                    success = 1;
                end)
                local task_ret = {task.spawn(thread)};
                expect(task_ret).toHaveLength(1);
                expect(task_ret[1]).toBe(expect.any("thread"));
                expect(task_ret[1]).toBe(thread);
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                task.wait(0.05);
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                task.cancel(task_ret[1]);
                expect(coroutine.status(task_ret[1])).toBe("dead");
                task.wait(0.5);
                expect(success).toBe(0);
            end)
            test("Defer", function()
                local success;
                local thread = coroutine.create(function()
                    success = 0;
                    task.wait(0.25);
                    success = 1;
                end)
                local task_ret = {task.defer(thread)};
                expect(task_ret).toHaveLength(1);
                expect(task_ret[1]).toBe(expect.any("thread"));
                expect(task_ret[1]).toBe(thread);
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                task.wait(0.05);
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                task.cancel(task_ret[1]);
                expect(coroutine.status(task_ret[1])).toBe("dead");
                task.wait(0.5);
                expect(success).toBe(0);
            end)
            test("Delay", function()
                local success;
                local thread = coroutine.create(function()
                    success = 0;
                    task.wait(0.25);
                    success = 1;
                end)
                local task_ret = {task.delay(0, thread)};
                expect(task_ret).toHaveLength(1);
                expect(task_ret[1]).toBe(expect.any("thread"));
                expect(task_ret[1]).toBe(thread);
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                task.wait(0.05);
                expect(coroutine.status(task_ret[1])).toBe("suspended");
                task.cancel(task_ret[1]);
                expect(coroutine.status(task_ret[1])).toBe("dead");
                task.wait(0.5);
                expect(success).toBe(0);
            end)
        end)
    end)

    describe("other", function()
        test("Counting", function()
            expect({task.count("stdw")}).toHaveLength(4);
            expect({task.count("std")}).toHaveLength(3);
            expect({task.count("st")}).toHaveLength(2);
            expect({task.count("s")}).toHaveLength(1);
            expect({task.count()}).toHaveLength(1);
            expect(task.count()).toBe(0);
            task.defer(function() end)
            task.delay(0, function() end)
            task.spawn(function() task.wait() end)
            task.spawn(function() end)
            expect(task.count()).toBe(3);
            expect(
                task.count("s") +
                task.count("t") +
                task.count("d") +
                task.count("w")
            ).toBe(task.count());
            task.wait(0.5);
            expect(task.count()).toBe(0);
        end)

        -- based on https://github.com/lune-org/lune/tree/ff83c401b8cc915ec2e2e5dbfd29a39303f7a575/tests/task
        describe("nested", function()
            test("Spawn", function()
                local flag: boolean = false;
                task.spawn(function()
                    local function nested3()
                        task.spawn(function()
                            task.wait(0.01);
                            flag = true;
                        end)
                    end
                    local function nested2()
                        task.spawn(function()
                            task.wait(0.01);
                            nested3();
                        end)
                    end
                    local function nested1()
                        task.spawn(function()
                            task.wait(0.01);
                            nested2();
                        end)
                    end
                    task.wait(0.01);
                    nested1();
                end)
                expect(task.count("s")).toBe(1);
                task.wait(0.25);
                expect(task.count("s")).toBe(0);
                expect(flag).toBeTruthy();
            end)
            test("Defer", function()
                local flag: boolean = false;
                task.defer(function()
                    local function nested3()
                        task.defer(function()
                            task.wait(0.01);
                            flag = true;
                        end)
                    end
                    local function nested2()
                        task.defer(function()
                            task.wait(0.01);
                            nested3();
                        end)
                    end
                    local function nested1()
                        task.defer(function()
                            task.wait(0.01);
                            nested2();
                        end)
                    end
                    task.wait(0.01);
                    nested1();
                end)
                expect(task.count("d")).toBe(1);
                task.wait(0.25);
                expect(task.count("d")).toBe(0);
                expect(flag).toBeTruthy();
            end)
            test("Delay", function()
                local flag: boolean = false;
                task.delay(0.01, function()
                    local function nested3()
                        task.delay(0.01, function()
                            flag = true;
                        end)
                    end
                    local function nested2()
                        task.delay(0.01, nested3);
                    end
                    local function nested1()
                        task.delay(0.01, nested2);
                    end
                    nested1();
                end)
                expect(task.count("s")).toBe(1);
                task.wait(0.25);
                expect(task.count("s")).toBe(0);
                expect(flag).toBeTruthy();
            end)
        end)
    end)
end)
