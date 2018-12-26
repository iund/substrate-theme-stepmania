function PlaySound(file,direct) SOUND:PlayOnce(GetPathS(file,direct)) end
function PlaySoundFadeMusic(file,fadevol,dur) PlaySound(file) SOUND:DimMusic(fadevol or 0,dur or 0) end

function GameSoundManager.StopMusic() GameCommand("stopmusic") end

