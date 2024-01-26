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
  tup(function (ok, ...)
    if not ok then
      print()
      print(tup.concat(tup.interleave(": ", tags:unpack())))
      print()
      print(tup.sel(2, ...))
      print()
      print(tup.get(1, ...))
      print()
      os.exit(1)
    end
    tags:pop()
  end, pcall(fn))
end

return setmetatable(M, M.MT)
