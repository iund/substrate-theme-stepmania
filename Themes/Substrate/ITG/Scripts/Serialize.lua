-- Dump a table (t) to a string. Used primarily to save profile data.

function table.dump(t)
	local format_,concat_,next_,type_,dupes,obj=string.format,table.concat,next,type,{}
	obj={
		--doing these manually is faster than calling tostring
		string=function(v) return format_("%q",v) end,
		number=function(v) return v end,
		boolean=function(v) return v and "true" or "false" end,
		table=function(st,indent)
			local subindent,out,i=indent.."\t",{"{"},2
			for n,v in next_,st,nil do
				out[i]=
					subindent.."["
					..obj[type_(n)](n,subindent).."]="
					..obj[type_(v)](v,subindent)..","
				i=i+1
			end
			out[i]=indent.."}"
			return concat_(out,"\r\n")
		end,
		userdata=function(v,d) --this section is only for debugging the theme so it doesn't need to be as fast as possible
			local name=(debug and debug.getmetatable(v).heirarchy.Actor or getmetatable(v) and getmetatable(v).GetName) and v:GetName() or ""
			return (debug and debug.getmetatable(v).heirarchy.Actor or getmetatable(v).GetX) and
				format_("nil --[".."[ %s (%s) x=%d y=%d aux=%d name=%s ]".."]",
					tostring(v),
					IsActorFrame(v) and v:GetNumChildren().." children"
						or (debug and debug.getmetatable(v).heirarchy.BitmapText or getmetatable(v).GetText)
						and format_("%q",v:GetText()) or "",
					v:GetX(), v:GetY(), v:getaux(), name
				)
			or format_("nil --[".."[ metatable=%s ]".."]", obj.table(debug and debug.getmetatable(v).__index or getmetatable(v),d))
		end,
		other=tostring
	}
	setmetatable(obj,{__index=function(t,k) return rawget(t,"other") end}) --fall back to other
	return "return "..obj[type(t)](t,"").."--"
end

Serialize=table.dump

function aaSerialize(t)
	--[[
		Serialize a table, then encapsulate that into a base64 string.

		Do this to avoid excessive "&quot;" bloating,
		however you'd also need to embed a decoder (below) to decapsulate it.
	]]

	--these functions get defined elsewhere, however this file gets parsed first.

	local function explode(str) local out={} local i=1 for c in string.gfind(str,".") do out[i]=c i=i+1 end return out end
	local sextets=explode("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")
	local encode=function(rawin)
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

		return table.concat(o,"")
	end

	local b64str=encode(table.dump(t))
	local len=string.len(b64str)
	return string.format([[
local s="%s"

local explode=function(s) local gfind=string.gfind or string.gmatch local i,o=1,{} for c in gfind(s,".") do o[i]=c i=i+1 end return o end
local invert=function(t) local o={} for k,v in next,t,nil do o[v]=k end return o end

local lookup=invert(explode("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"))
local ch,f,m=string.char,math.floor,math.mod
local sin=explode(s)
local i,j,o,l=1,1,{},%d

while l>=4 do
	local A,B,C,D=sin[j],sin[j+1],sin[j+2],sin[j+3]
	local a,b,c,d=(lookup[A] or 1)-1,(lookup[B] or 0)-1,(lookup[C] or 0)-1,(lookup[D] or 0)-1

	o[i  ]=ch(a*4 + (b>=0 and f(b/16) or 0))
	o[i+1]=ch((b>=0 and m(b,16)*16 or 0) + (c>=0 and f(c/4) or 0)) or nil
	o[i+2]=ch((c>=0 and m(c,4)*64 or 0) + (d>=0 and d or 0)) or nil

	i=i+3 j=j+4 l=l-3
end

return loadstring(table.concat(o,""))()
]],b64str,len)

end
