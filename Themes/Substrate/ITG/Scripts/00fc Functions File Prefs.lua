--Use a slightly modified lua serialize table, to store preferences in.
--It's only ever going to store these types: tables, strings, numbers, bools.
--[[


proposed format:

	Lua:
	tab={
		[1]="hello"
		[2]="world",
		
		[4]="word",
		["name"]="foo",
		
		
		
		
		subtab={
	
	
	
	
		}
	}
	(eof)
	
	
	
	
	format (potential):

	tab:
		"hello"
		"world"
		4="word"
		name="foo"
		subtab:
			values
	(eof)


	parse:
	
	function Unserialize(contents) --return a table
		local value
		local getsubsection=function(str)
			print("getsubsection("..str..")")
			local out={}
			for n,v in string.gfind(str,"(.-)=(.-)\n") do 
			--out[n]=v end
			out[value(n)]=value(v) end
			return out
		end
		value=function(v)
			return
				string.left(v,1)=="{" and getsubsection(string.sub(v,2,-2)) --table
				or string.left(v,1)=="\"" and string.sub(v,2,-2) --string
				or v=="true" and true or v=="false" and false or tonumber(v) or v --other
		end
		return getsubsection(contents)
	end

	
	



old Proposed format:



{"namea"="valueb"
"nameb"="valueb"
	"sectionc"={
		"nameca"="valueca"
		"namecc"="valuecb"
	
	
	
	}
}





--]]

--[[

function Serialize(t) --recursively generate a table
	local format=string.format
	local concat=table.concat
	local obj={string=function(v) return format("%q",v) end, number=tostring, boolean=tostring}
	
	obj.table=function(t)
		local out={'{'}
		local i=2
		for n,v in next,t,nil do out[i]="["..obj[type(n)](n).."]="..obj[type(v)](v).."," i=i+1 end
		out[i]='}'
		return concat(out,"\n")
	end

	return "return "..obj.table(t)
end

function string.right(str,len) return string.sub(str,string.len(str)+1-len,-1) end
function string.left(str,len) return string.sub(str,1,len) end

function Unserialize(contents) --return a table
	local value
	local getsubsection=function(str)
		print("getsubsection("..str..")")
		local out={}
		for n,v in string.gfind(str,"(.-)=(.-)\n") do 
		--out[n]=v end
		out[value(n)]=value(v) end
		return out
	end
	value=function(v)
		return
			string.left(v,1)=="{" and getsubsection(string.sub(v,2,-2)) --table
			or string.left(v,1)=="\"" and string.sub(v,2,-2) --string
			or v=="true" and true or v=="false" and false or tonumber(v) or v --other
	end
	return getsubsection(contents)
end


print(Serialize(Unserialize([ [
{
"namea"="valueb"
"nameb"="valueb"
	"sectionc"={
		"nameca"="valueca"
		"namecc"="valuecb"
	}
}
] ])))
--]]


--[[
File.Prefs={

	Read=function(path)




		return tab
	end,

	Write=function(path,tab)
		local out=Serialize(tab)


	end

}
--]]
