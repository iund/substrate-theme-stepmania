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
	return "return "..obj[type(t)](t,"")
end

Serialize=table.dump
