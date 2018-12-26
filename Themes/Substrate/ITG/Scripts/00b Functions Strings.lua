---Strings
string.gfind=string.gfind or string.gmatch --lua 5.0 -> 5.1 compat
function explode(str) local out={} local i=1 for c in string.gfind(str,".") do out[i]=c i=i+1 end return out end
function split(delim,text) local find=string.find local sub=string.sub local out={} local pos=1 local i=1 while true do local first,last=find(text,delim,pos) if first then out[i]=sub(text,pos,first-1) pos=last+1 else out[i]=sub(text,pos) break end i=i+1 end return out end
function join(delim,list) return table.concat(list,delim) end
subst=string.gsub --function subst(list,token,new) return join(new,split(token,list)) end --yolo. same as gsub really.
function GetPairsFromString(str,delim,eq) local split=split local list=split(delim,str) local out={} for i=1,table.getn(list) do local pair=split(eq or "=",list[i]) out[pair[1]]=pair[2] end return out end
function indent(lev,str) return string.rep('\t',lev)..(str and string.gsub(str,'\n','\n'..string.rep('\t',lev)) or '') end
function quote(str) return string.format("%q",str) end
function string.capitalize(str) return string.upper(string.sub(str,1,1))..string.sub(str,2) end
sprintf=string.format
function printf(...) print(sprintf(unpack(arg))) end
function string.left(str,len) return string.sub(str,1,len) end
function string.right(str,len) return string.sub(str,string.len(str)+1-len,-1) end
function string.nextline(str) return string.gfind(str,"[^\n]+") end --use in a for loop
function string.isinlist(list,str) for _,li in next,list,nil do if string.find(li,str) then return true end end return false end