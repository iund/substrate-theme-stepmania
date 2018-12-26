---Other Lua types
function SerializeFunction(func) return string.format("%q",string.dump(func)) end

---Misc
function uuid()
	local random = math.random
	local format=string.format
	local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
	local subst=function (c)
		local v = (c == 'x') and random(0, 15) or random(8, 11)
		return format('%x', v)
	end
	return string.gsub(template, '[xy]', subst)
end

--General
function IsBoolean(val) return type(val)=='boolean' end
function IsString(val) return type(val)=='string' end
function IsTable(val) return type(val)=='table' end
function IsNumber(val) return type(val)=='number' end
function IsFunction(val) return type(val)=='function' end

--Modified bcd. Operates on 15 possible chars ( +,-./0123456789 ) and zero ends the string (it has to deal with null-terminated strings elsewhere)

bcd={
	pack=function(data)
		local os=42 --offset. must be hardcoded to 42 or completely break anything passed to the unpack function 
		local s=string.sub local b=string.byte local c=string.char
		local out={}
		local olen=math.ceil(string.len(data)/2)
		for i=1,olen do 
			local ho=i*2-1 local hc=s(data,ho,ho)
			local lo=i*2 local lc=s(data,lo,lo)
			out[i]=c(((hc and b(hc) or os)-os)*16+((lc and b(lc) or os)-os))
		end
		return table.concat(out)
	end,
	unpack=function(data)
		local os=42
		local s=string.sub local b=string.byte local c=string.char local m=math.mod local f=math.floor
		local out={}
		local dlen=string.len(data)
		for i=1,dlen do
			local d=b(s(data,i,i))
			local h=m(f(d/16),16)
			local l=m(d,16) 
			if h>0 then out[i*2-1]=c(h+os) end
			if l>0 then out[i*2]=c(l+os) end
		end
		return table.concat(out)
	end
}

--Stack
stack={
	size=table.getn,
	pop=function(t) t[table.getn(t)]=nil end,
	push=function(t,v) t[table.getn(t)+1]=v end,
	top=function(t) return t[table.getn(t)] end,
}

-- Base 64 encode/decode.

local sextets=explode("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")
local vsextets=table.invert(sextets)

base64={
	encode=function(rawin)
		local lookup=sextets

		local b,f,m=string.byte,math.floor,math.mod
		local sin=explode(rawin)
		local i,j,o,l=1,1,{},table.getn(sin)

		while l>=3 do
			local A,B,C=b(sin[i]),b(sin[i+1]),b(sin[i+2])
			
			o[j]  =lookup[1+ f(A/4) ]                 --AAAAAA
			o[j+1]=lookup[1+ m(A,4)*16 + f(B/16) ]    --      AABBBB
			o[j+2]=lookup[1+ m(B,16)*4 + f(C/64) ]    --            BBBBCC
			o[j+3]=lookup[1+ m(C,64) ]                --                  CCCCCC

			i=i+3
			j=j+4
			l=l-3
		end

		if l>0 then --pad the remainder
			local A,B=
				b(sin[i]),
				l==2 and b(sin[i+1])

			o[j]  =lookup[1+ f(A/4) ]
			o[j+1]=A and lookup[1+ m(A,4)*16 + (B and f(B/16) or 0)] or "="
			o[j+2]=B and lookup[1+ m(B,16)*4] or "="
			o[j+3]="="
		end

		return join("",o)
	end,
	decode=function(rawin)
		local lookup=vsextets

		local ch,f,m=string.char,math.floor,math.mod
		local sin=explode(rawin)
		local i,j,o,l=1,1,{},table.getn(sin)

		while l>=4 do
			local A,B,C,D=sin[j],sin[j+1],sin[j+2],sin[j+3]

			local a,b,c,d=
				(lookup[A] or 1)-1,
				(lookup[B] or 0)-1,
				(lookup[C] or 0)-1,
				(lookup[D] or 0)-1

			o[i  ]=ch(a*4 + (b>=0 and f(b/16) or 0))                              --AAAAAABB
			o[i+1]=ch((b>=0 and m(b,16)*16 or 0) + (c>=0 and f(c/4) or 0)) or nil --        BBBBCCCC
			o[i+2]=ch((c>=0 and m(c,4)*64 or 0) + (d>=0 and d or 0)) or nil       --                CCDDDDDD

			i=i+3
			j=j+4
			l=l-3
		end

		return join("",o)
	end
}
