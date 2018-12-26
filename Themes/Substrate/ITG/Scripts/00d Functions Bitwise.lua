--Bitwise int ops
function signint(uint,msb) local max=2^msb return math.mod(uint+max,2^(msb+1))-max end
function unsignint(int,msb) local max=2^(msb+1) return math.mod(int+max,max) end
function inttobits(int,msb,lsb)
	local floor,mod,bits,uint=math.floor,math.mod,{},unsignint(int,msb)*2^lsb
	for bit=lsb,msb do bits[bit+1]=mod(floor(uint/(2^bit)),2)~=0 end
	return bits
end
function bitstouint(bits,msb,lsb)
	local uint=0
	for bit=lsb,msb do uint=uint+(bits[bit+1] and 1 or 0)*2^bit end
	return math.floor(uint/2^lsb)
end
function bitstoint(bits,msb,lsb) return signint(bitstouint(bits,msb,lsb),msb-lsb) end
function mergebits(...)
	local bits={}
	for ia=1,arg.n do
		for ib,bit in next,arg[ia],nil do bits[ib]=bit end
	end
	return bits
end

function bnot(a) for i,v in next,a,nil do a[i]=not v end return a end
function band(a,b) local c={} for i=1,table.getn(a) do c[i]=a[i] and b[i] end return c end
function bor(a,b) local c={} for i=1,table.getn(a) do c[i]=a[i] or b[i] end return c end
function bxor(a,b) local c={} for i=1,table.getn(a) do c[i]=a[i] and not b[i] or b[i] and not a[i] end return c end

function bshl(a,places)
	local c={}
	local numbits=table.getn(a)
	for i=places+1,numbits do c[i-places]=a[i] end
	for i=numbits-places,numbits do c[i]=false end
	return c
end

function bshr(a,places) --TODO doesn't work
	local c={}
	local numbits=table.getn(a)
	for i=1,places do c[i]=false end
	for i=places+1,numbits do c[i]=a[i-places] end
	return c
end
--[[

Common boolean ops:

not
and
or
xor


--]]
