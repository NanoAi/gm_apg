--[[--
local CATEGORY_NAME = "APG"

function ulx.mostspawns( calling_ply, target_plys, dmg )
	local affected_plys = {}

	for i=1, #target_plys do
		local v = target_plys[ i ]
		if v:IsFrozen() then
			ULib.tsayError( calling_ply, v:Nick() .. " is frozen!", true )
		else
			ULib.slap( v, dmg )
			table.insert( affected_plys, v )
		end
	end

	ulx.fancyLogAdmin( calling_ply, "#A slapped #T with #i damage", affected_plys, dmg )
end

local slap = ulx.command( CATEGORY_NAME, "ulx slap", ulx.slap, "!slap" )
slap:addParam{ type=ULib.cmds.PlayersArg }
slap:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="damage", ULib.cmds.optional, ULib.cmds.round }
slap:defaultAccess( ULib.ACCESS_ADMIN )
slap:help( "Slaps target(s) with given damage." )
--]]--