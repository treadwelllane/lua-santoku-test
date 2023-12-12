-- TODO: Refine this: show nesting of tags,
-- allow continuing on failure with summary of
-- errors, etc.

local compat = require("santoku.compat")
local tup = require("santoku.tuple")
local err = require("santoku.err")
local gen = require("santoku.gen")
local fs = require("santoku.fs")
local sys = require("santoku.system")
local str = require("santoku.string")

local M = {}

M.MT = {
  __call = function (M, ...)
    return M.test(...)
  end
}

M.MT_TEST = {
  __index = _G
}

local tags = tup()

M.test = function (tag, fn)
  assert(compat.hasmeta.call(fn))
  assert(type(tag) == "string")
  tags = tup(tags(tag))
  local ret = tup(xpcall(fn, function (...)
    print()
    print(debug.traceback())
    return ...
  end))
  if not ret() then
    print()
    tup.each(print, tup.filter(compat.id, tup.sel(2, ret())))
    print()
    print(tup.concat(tup.interleave(": ", tags())))
    print()
    os.exit(1)
  end
  tags = tup(tup.sel(-1, tags()))
end

M.runfiles = function (files, interp, match, stop)
  local sent = tup()
  return err.pwrap(function (check)
    print()
    gen.ivals(files)
      :map(function (fp)
        if check(fs.isdir(fp)) then
          return fs.files(fp, { recurse = true }):map(check)
        else
          return gen.pack(fp)
        end
      end)
      :flatten()
      :each(function (fp)
        if not fp or match and not fp:match(match) then
          return
        end
        if interp then
          print("Test: " .. fp)
          local ok, err, cd = sys.execute(str.split(interp):append(fp):unpack())
          check.err(sent).ok(ok, err, cd)
        elseif str.endswith(fp, ".lua") then
          print("Test: " .. fp, ":  ")
          check.err(sent).ok(fs.loadfile(fp, setmetatable({}, M.MT_TEST)))()
        else
          print("Test: " .. fp)
          local ok, err, cd = sys.execute(fp)
          check.err(sent).ok(ok, err, cd)
        end
      end)
  end, function (a, ...)
    if a == sent and stop then
      return false, ...
    elseif a == sent then
      print(...)
      return true
    else
      return a, ...
    end
  end)
end

return setmetatable(M, M.MT)
