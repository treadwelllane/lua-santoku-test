-- TODO: Refine this: show nesting of tags,
-- allow continuing on failure with summary of
-- errors, etc.

local compat = require("santoku.compat")
local vec = require("santoku.vector")
local tup = require("santoku.tuple")

local M = {}

M.MT = {
  __call = function (o, ...)
    return o.test(...)
  end
}

local tags = vec()

M.test = function (tag, fn)
  assert(compat.hasmeta.call(fn))
  assert(compat.istype.string(tag))
  tags:append(tag)
  local ok, ret = xpcall(fn, function (...)
    return tup(debug.traceback(), ...)
  end)
  if not ok then
    print()
    print(tup.concat(tup.interleave(": ", tags:unpack())))
    print()
    print(tup.sel(2, ret()))
    print()
    print(tup.get(1, ret()))
    print()
    os.exit(1)
  end
  tags:pop()
end

return setmetatable(M, M.MT)
