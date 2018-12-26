---SM5 (5.0.12) File handling functions.
File={
	Exists=function(path) return FILEMAN:DoesFileExist(path) end,

	Open=function(path,mode)
		--[[
			mode: (bitmask)
			READ		= 0x1,
			WRITE		= 0x2,
			STREAMED	= 0x4, (direct write)
			SLOW_FLUSH	= 0x8 (delayed write)
		]]
		local p=THEME:GetCurrentThemeDirectory().."../../"..assert(path)
		if not p or not FILEMAN:DoesFileExist(p) then return nil end
		local handle=RageFileUtil.CreateRageFile()
		if not handle:Open(path,mode) then
			Trace(sprintf("FileOpen(): Cannot open %s for mode %d, due to %s",path,mode,handle:GetError()))
			handle:destroy()
			return nil
		else
			return handle
		end
	end,
	Close=function(handle) handle:Close() handle:destroy() end,

	--reading
	ReadLine=function(handle) return not handle:AtEOF() and handle:GetLine() or nil end,
	ReadContents=function(handle)
		local cont={}
		local chunk=1
		while not handle:AtEOF() do cont[chunk]=handle:Read() inc(chunk) end
		return table.concat(cont)
	end,

	--writing
	WriteLine=function(handle,line) handle:PutLine(line) end,
	WriteContents=function(handle,contents) handle:Seek(0) handle:Write(contents) end,

	--file tamper verification TODO
--[[
	Hash={
		Verify=function(path)
			local hashpath=path..".hash"
			local handle=File.Open(hashpath,2)
			if handle then
				local hash=File.ReadContents(hashpath)
				File.Close(handle)
				return hash
			else
				return nil
			end
		end,
		Update=function(path)
			if File.Exists(path) then
				local hash=FILEMAN:GetHashForFile(path)
				local hashpath=path..".hash"
				local handle=File.Open(hashpath,2)
				if handle then
					File.WriteContents(hash)
					File.Close(handle)
				end
			end
		end,
	}
--]]
}

function DumpFile(path,rettable) --Convenience function to return a file's contents, with file handling done automatically.
	local lines={}
	local handle=File.Open(path,1)
	if handle then
		local l=1
		local nextline=File.ReadLine
		for line in nextline,handle,nil do lines[l]=line l=l+1 end
		File.Close(handle)
	end
	return table.getn(lines)>0 and (rettable and lines or join("\n",lines)) or nil
end
