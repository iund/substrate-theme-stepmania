File.Msd={
	Read=function(handle)
		--format: tab[section][section index][line index] = line

		local tab = {}
		local cur_section = ""
		local nextline=File.ReadLine
		local sub=string.sub
		local find=string.find
		local getn=table.getn
		for line in nextline,handle,nil do
			if sub(line,1,1) == '#' then
				cur_section = sub(line,2,find(line,":")-1)
				tab[cur_section][getn(tab[cur_section] or {})+1] = {} --next section (there is normally multiple with the same name)
			else
				insert(tab[cur_section][getn(tab[cur_section])],
					find(line,';') and sub(line,1,find(line,';')-1) or line --get everything before ;
				)
			end
		end
		return tab
	end,
}

