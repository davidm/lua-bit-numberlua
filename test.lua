-- tests of bit.numberlua'

package.path = 'lmod/?.lua;' .. package.path
local bit = require 'bit.numberlua'

local function mystr(o)
  if type(o) == 'number' then return '0x'..bit.tohex(o)
  else return tostring(o) end
end
local function checkeq(a, b)
  if a ~= b then error('not equal\n'..mystr(a)..'\n'..mystr(b), 2) end
end

-- bit.tobit (not necessarily the same as BitOp currently)
-- examples on http://bitop.luajit.org/api.html
checkeq(bit.tobit(0xffffffff), 0xffffffff)     --> -1 *
checkeq(bit.tobit(0xffffffff + 1), 0) --> 0
checkeq(bit.tobit(2^40 + 1234), 1234)    --> 1234

-- bit.tohex
checkeq(bit.tohex(0), '00000000')
checkeq(bit.tohex(0, 1), '0')
-- examples on http://bitop.luajit.org/api.html
checkeq(bit.tohex(1), '00000001')
checkeq(bit.tohex(-1), 'ffffffff')
checkeq(bit.tohex(0xffffffff), 'ffffffff')
checkeq(bit.tohex(-1, -8), 'FFFFFFFF')
checkeq(bit.tohex(0x21, 4), '0021')
checkeq(bit.tohex(0x87654321, 4), '4321')

-- bit.bnot
checkeq(bit.bnot(0), 0xffffffff)
checkeq(bit.bnot(1), 0xfffffffe)
--checkeq(bit.bnot(-1), 0)  --should it normalize?
checkeq(bit.bnot(0xffffffff), 0)
checkeq(bit.bnot(0x13579bdf), 0xeca86420)

-- bit.band
checkeq(bit.band(0,0), 0)
checkeq(bit.band(0xffffffff,0xffffffff), 0xffffffff)
checkeq(bit.band(0xffffffff,0), 0)
checkeq(bit.band(0xa207f158,0x2e1054c9), 0x22005048)
-- note: multiple args not currently supported

-- bit.btest
checkeq(bit.btest(0,0), false)
checkeq(bit.btest(0xf000,0xf000), true)
checkeq(bit.btest(0xffffffff,0), false)

--- bit.bor
checkeq(bit.bor(0,0), 0)
checkeq(bit.bor(0xffffffff,0xffffffff), 0xffffffff)
checkeq(bit.bor(0xffffffff,0), 0xffffffff)
checkeq(bit.bor(0xa207f158,0x2e1054c9), 0xae17f5d9)
-- note: multiple args not currently supported

-- bit.bxor
checkeq(bit.bxor(0,0), 0)
checkeq(bit.bxor(0xffffffff,0xffffffff), 0)
checkeq(bit.bxor(0xffffffff,0), 0xffffffff)
checkeq(bit.bxor(0xa207f158,0x2e1054c9), 0x8c17a591)

-- bit.extract
checkeq(bit.extract(0, 0), 0)
checkeq(bit.extract(0, 31,31), 0)
checkeq(bit.extract(0xabcd, 4,8), 0xbc)
checkeq(bit.extract(0xabcd, 0,32), 0xabcd)

-- bit.replace
checkeq(bit.replace(0xabcd, 0xe, 4,8), 0xa0ed)
checkeq(bit.replace(0xabcd, 0, 0), 0xabcc)
checkeq(bit.replace(0xabcc, 1, 0), 0xabcd)
checkeq(bit.replace(0x2bcdefef, 1, 31), 0xabcdefef)
checkeq(bit.replace(0xabcdefef, 0, 31), 0x2bcdefef)

-- bit.rol, bit.ror
-- examples on http://bitop.luajit.org/api.html
checkeq(bit.rol(0x12345678, 12), 0x45678123)
checkeq(bit.ror(0x12345678, 12), 0x67812345)

-- bit.lrotate, bit.rrotate
checkeq(bit.rol, bit.lrotate)
checkeq(bit.ror, bit.rrotate)

-- bit.bswap
-- examples on http://bitop.luajit.org/api.html
checkeq(bit.bswap(0x12345678), 0x78563412)
checkeq(bit.bswap(0x78563412), 0x12345678)

-- bit.arshift
checkeq(bit.arshift(0, 0), 0)
checkeq(bit.arshift(0xffffffff, 0), 0xffffffff)
checkeq(bit.arshift(0xffffffff, 4), 0xffffffff)
checkeq(bit.arshift(0xffffffff, 32), 0xffffffff)
checkeq(bit.arshift(0x7fffffff, 4), 0x07ffffff)
checkeq(bit.arshift(0x7fffffff, 31), 0)
checkeq(bit.arshift(0x7fffffff, 32), 0)

-- BIT.bit32.
-- Optionally run bitwise.lua from Lua test suite.
-- http://www.lua.org/tests/5.2/
if TEST_BIT32 then
  _G.bit32 = require 'bit.numberlua' . bit32
  dofile 'contrib/bitwise.lua'
end
-- additional tests:
-- trigger recursion... (once broken)
checkeq(bit.bit32.bor (1,2,4,8,16,2^30,2^31), 0xc000001f)
checkeq(bit.bit32.bxor(1,2,4,8,16,2^30,2^31), 0xc000001f)
checkeq(bit.bit32.bxor(-1,-1,-1,-1,-1), 2^32-1)
checkeq(bit.bit32.band(255,255*2,255*4,255*8,255*16), 255-15)

-- BIT.bit
-- Optionally run bittest.lua (included) from LuaBitOp test suite.
-- http://bitop.luajit.org/
--if TEST_BIT then
  package.loaded.bit = bit.bit
  dofile 'contrib/bittest.lua'
--end

-- BIT.bit.


print 'DONE'
