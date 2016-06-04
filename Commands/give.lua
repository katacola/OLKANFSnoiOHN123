local CATEGORY_NAME = "Utility"

function ulx.give( calling_ply, target_plys, command )
	for _, v in ipairs( target_plys ) do
		v:Give( command )
	end

	ulx.fancyLogAdmin( calling_ply, "#A gave #s to #T", command, target_plys )
end
local give = ulx.command( "Utility", "ulx give", ulx.give, "!give" )
give:addParam{ type=ULib.cmds.PlayersArg }
give:addParam{ type=ULib.cmds.StringArg, hint="command", ULib.cmds.takeRestOfLine }
give:defaultAccess( ULib.ACCESS_SUPERADMIN )
give:help( "give a weapon to a target(s)." )