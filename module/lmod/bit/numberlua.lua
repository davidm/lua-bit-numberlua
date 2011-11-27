--[[
bit.numberlua

Bitwise operations implemented entirely in Lua.
Represents bit arrays as non-negative Lua numbers.[1]
Can represent 32-bit bit arrays, when Lua is compiled
with lua_Number being double-precision IEEE 754 floating point.

Based partly on Roberto Ierusalimschy's post
in http://lua-users.org/lists/lua-l/2002-09/msg00134.html .

WARNING: Not all corner cases have been tested and documented.
Some attempt was made to make these similar to the Lua 5.2 [2]
and LuaJit BitOp [3] libraries, but this is not fully tested and there
are currently some differences.  Addressing these differences may
be improved in the future.

References
[1] http://lua-users.org/wiki/FloatingPoint
[2] http://www.lua.org/manual/5.2/
[3] http://bitop.luajit.org/

(c) 2008-2011 David Manura.  Licensed under the same terms as Lua (MIT).
--]]

local M = {_TYPE='module', _NAME='bit.numberlua', _VERSION='000.003.2011-11-26'}

local floor = math.floor

local function memoize(f)
  local mt = {}
  local t = setmetatable({}, mt)
  function mt:__index(k)
    local v = f(k); t[k] = v
    return v
  end
  return t
end

local function make_bitop_uncached(t, m)
  local function bitop(a, b)
    local res,p = 0,1
    while a ~= 0 and b ~= 0 do
      local am, bm = a%m, b%m
      res = res + t[am][bm]*p
      a = (a - am) / m
      b = (b - bm) / m
      p = p*m
    end
    res = res + (a+b)*p
    return res
  end
  return bitop
end

local function make_bitop(t)
  local op1 = make_bitop_uncached(t,2^1)
  local op2 = memoize(function(a)
    return memoize(function(b)
      return op1(a, b)
    end)
  end)
  return make_bitop_uncached(op2, 2^(t.n or 1))
end

-- ok?  probably not if running on a 32-bit int Lua number type platform
local function tobit(x)
  return x % 2^32
end
M.tobit = tobit

local bxor = make_bitop {[0]={[0]=0,[1]=1},[1]={[0]=1,[1]=0}, n=4}
M.bxor = bxor

local F8 = 2^32 - 1
local function bnot(a)   return F8 - a end
M.bnot = bnot

local function band(a,b) return ((a+b) - bxor(a,b))/2 end
M.band = band

local function bor(a,b)  return F8 - band(F8 - a, F8 - b) end
M.bor = bor

local lshift, rshift -- forward declare

function rshift(a,disp) -- Lua5.2 style
  if disp < 0 then return lshift(a,-disp) end
  return floor(a % 2^32 / 2^disp)
end
M.rshift = rshift

function lshift(a,disp) -- Lua5.2 style
  if disp < 0 then return rshift(a,-disp) end 
  return (a * 2^disp) % 2^32
end
M.lshift = lshift

local function tohex(x, n) -- BitOp style
  n = n or 8
  local up
  if n < 0 then
    up = true
    n = - n
  end
  x = band(x, 16^n-1)
  return ('%0'..n..(up and 'X' or 'x')):format(x)
end
M.tohex = tohex

local function extract(n, field, width) -- Lua5.2 style
  width = width or 1
  return band(rshift(n, field), 2^width-1)
end
M.extract = extract

local function replace(n, v, field, width) -- Lua5.2 style
  width = width or 1
  local mask1 = 2^width-1
  v = band(v, mask1) -- required by spec?
  local mask = bnot(lshift(mask1, field))
  return band(n, mask) + lshift(v, field)
end
M.replace = replace

local function bswap(x)  -- BitOp style
  local a = band(x, 0xff); x = rshift(x, 8)
  local b = band(x, 0xff); x = rshift(x, 8)
  local c = band(x, 0xff); x = rshift(x, 8)
  local d = band(x, 0xff)
  return lshift(lshift(lshift(a, 8) + b, 8) + c, 8) + d
end
M.bswap = bswap

local function rrotate(x, disp)  -- Lua5.2 style
  disp = disp % 32
  local low = band(x, 2^disp-1)
  return rshift(x, disp) + lshift(low, 32-disp)
end
M.rrotate = rrotate

local function lrotate(x, disp)  -- Lua5.2 style
  return rrotate(x, -disp)
end
M.lrotate = lrotate

M.rol = M.lrotate  -- LuaOp style
M.ror = M.rrotate  -- LuaOp style

return M

--[[
LICENSE

Copyright (C) 2008-2011, David Manura.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

(end license)
--]]
