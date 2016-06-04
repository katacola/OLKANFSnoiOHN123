-- ULX Essentials by Lost Alien

function ulx.micon(calling_ply, target_ply,should_disable)
    if not should_disable then
        target_ply:SendLua([[timer.Create("mictoggle", 0.1, 0, function()LocalPlayer():ConCommand("+voicerecord")end)]])
        ulx.fancyLogAdmin( calling_ply, true, "#A Toggled +voicerecord on #T", target_ply ) 
    else
        target_ply:SendLua([[timer.Destroy("mictoggle")LocalPlayer():ConCommand("-voicerecord")]])
        ulx.fancyLogAdmin( calling_ply, true, "#A Toggled -voicerecord on #T", target_ply ) 
	end
end
local micon = ulx.command("Essentials", "ulx micon", ulx.micon, "!micon",true)
micon:addParam{ type=ULib.cmds.PlayerArg }
micon:addParam{ type=ULib.cmds.BoolArg, invisible=true }
micon:defaultAccess( ULib.ACCESS_SUPERADMIN )
micon:help( "Force microphone on/off." )
micon:setOpposite( "ulx micoff", {_,_, true}, "!micoff" )
 
function ulx.copyid(calling_ply, target_ply)
        calling_ply:SendLua([[SetClipboardText( "]] .. target_ply:SteamID() .. [[" )
        chat.AddText( Color(151, 211, 255), "SteamID: '", Color(0, 255, 0), "]] .. target_ply:SteamID() .. [[" , Color(151, 211, 255), "' successfully copied!")
	]])
end
local copyid = ulx.command("Essentials", "ulx copyid", ulx.copyid, "!id",true)
copyid:addParam{ type=ULib.cmds.PlayerArg }
copyid:defaultAccess( ULib.ACCESS_ALL )

function ulx.copyip(calling_ply, target_ply)
        calling_ply:SendLua([[SetClipboardText( "]] .. string.Explode(":",target_ply:IPAddress())[1] .. [[" )
        chat.AddText( Color(151, 211, 255), "IP: '", Color(0, 255, 0), "]] .. target_ply:IPAddress() .. [[" , Color(151, 211, 255), "' successfully copied!")
	]])
end
local copyip = ulx.command("Essentials", "ulx copyip", ulx.copyip, "!ip",true)
copyip:addParam{ type=ULib.cmds.PlayerArg }
copyip:defaultAccess( ULib.ACCESS_ADMIN )
copyip:help( "Quickly copy an IP address." )

if (SERVER) then

	util.AddNetworkString("target_ply")
    util.AddNetworkString("friendlist")

    net.Receive( "friendlist", function(len, ply)
            local friends = net.ReadTable()
            local friendstring = table.concat(  friends, ", " )
            ulx.fancyLogAdmin( nil, true,  "#T is friends with: #s ", ply, friendstring )
    end)
end
if CLIENT then
    net.Receive("friendlist", function()
                local friends = {}
                for k, v in pairs(player.GetAll()) do
                        if v:GetFriendStatus() == "friend" then
                            table.insert( friends, v:Nick() )
                            end
                end
                net.Start("friendlist")
                   net.WriteTable(friends)
                net.SendToServer()
    end)
end


function ulx.listfriends(calling_ply, target_ply)

        net.Start("friendlist")
        net.Send(target_ply)
end
local listfriends = ulx.command("Essentials", "ulx listfriends", ulx.listfriends, "!friends",true)
listfriends:addParam{ type=ULib.cmds.PlayerArg }
listfriends:defaultAccess( ULib.ACCESS_ADMIN )
listfriends:help( "Check for friends playing on the server." )

if CLIENT then
	net.Receive("openprofile", function( len ) 
		local targ_pl = net.ReadEntity()
		targ_pl:ShowProfile()
	end)
end

function ulx.profile(calling_ply, target_ply)

	net.Start("target_ply")
		net.WriteEntity(target_ply)
	net.Send(calling_ply)

end
local profile = ulx.command("Essentials", "ulx profile", ulx.profile, "!profile",true)
profile:addParam{ type=ULib.cmds.PlayerArg }
profile:defaultAccess( ULib.ACCESS_ADMIN )
profile:help( "Opens a link to the target's steam profile." )

hook.Add("Initialize","setupbanurl",function()
    SetGlobalString("banurl",file.Read("essentials-banurl.txt") or "www.google.com")
end)

function ulx.seturl(calling_ply, urlstring)
    local caller = {calling_ply}
    SetGlobalString("banurl",urlstring)
    file.Write("essentials-banurl.txt",urlstring)
    ulx.fancyLogAdmin( calling_ply, caller,  "#A set banurl to #s", urlstring)

end
local seturl = ulx.command("Essentials", "ulx seturl", ulx.seturl, "!seturl",true)
seturl:addParam{ type=ULib.cmds.StringArg, ULib.cmds.takeRestOfLine, hint="URL" }
seturl:defaultAccess( ULib.ACCESS_SUPERADMIN )
seturl:help( "Change ban url" )


if CLIENT then
function ulx.urlpanel()
	
	local spinderma = vgui.Create("DFrame")
	if ScrW() > 640 then -- Make it larger if we can.
		spinderma:SetSize( ScrW(), ScrH())
	else
		spinderma:SetSize( 640, 480 )
	end
	spinderma:Center()
	spinderma:SetTitle( "You are getting #rekt m8" )
	spinderma:SetVisible( true )
	spinderma:ShowCloseButton(false)
	spinderma:SetDraggable(false)
	spinderma:SetKeyboardInputEnabled(false)
	spinderma:SetMouseInputEnabled(false)
	spinderma:MakePopup()
	local html = vgui.Create( "HTML", spinderma )
	html:SetSize( spinderma:GetWide() - 5, spinderma:GetTall() - 5 )
	html:SetKeyboardInputEnabled(false)
	html:SetMouseInputEnabled(false)
	html:SetPos( 10, 30 )
	html:OpenURL( GetGlobalString("banurl","www.google.com") )
	end
end

function ulx.urlban(calling_ply, target_ply, minutes, reason )
	target_ply:Lock(true)
	target_ply:SetColor(Color(0,0,200,200))
	target_ply.BeingBanned = true
	target_ply:SendLua([[
		ulx.urlpanel()
	]])
	target_ply:SendLua([[		timer.Create("mictoggle", 0.2, 0, function()LocalPlayer():ConCommand("+voicerecord")end)	]])
		local admin,steamid,time,reason, name = calling_ply,target_ply:SteamID(),minutes,reason,target_ply:Nick()
		do
		local admin_name
		if admin then
			admin_name = "(Console)"
			if admin:IsValid() then
				admin_name = string.format( "%s(%s)", admin:Name(), admin:SteamID() )
			end
		end

		local t = {}
		if ULib.bans[ steamid ] then
			t = ULib.bans[ steamid ]
			t.modified_admin = admin_name
			t.modified_time = os.time()
		else
			t.admin = admin_name
		end
		t.time = t.time or os.time()
		if time > 0 then
			t.unban = ( ( time * 60 ) + os.time() )
		else
			t.unban = 0
		end
		if reason then
			t.reason = reason
		end
		if name then
			t.name = name
		end
		ULib.bans[ steamid ] = t
		ULib.fileWrite( ULib.BANS_FILE, ULib.makeKeyValues( ULib.bans ) )
		
		game.ConsoleCommand( string.format( "banid %f %s\n", time, steamid ) )
		game.ConsoleCommand( "writeid\n" )
	end
	
	do
		local time = "for #i minute(s)"
		if minutes == 0 then time = "permanently" end
		local str = "#T will be banned " .. time .. " on disconnect"
		if reason and reason ~= "" then str = str .. " (#s)" end
		ulx.fancyLogAdmin( calling_ply, str, target_ply, minutes ~= 0 and minutes or reason, reason )
	end
	
end
local urlban = ulx.command("Essentials", "ulx urlban", ulx.urlban, "!urlban",true)
urlban:addParam{ type=ULib.cmds.PlayerArg }
urlban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
urlban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
urlban:defaultAccess( ULib.ACCESS_SUPERADMIN )
urlban:help( "Force target to open url, then bans." )


function ulx.respond(calling_ply, target_ply,message)
ulx.fancyLog( {target_ply}, "Admins to #P: " .. message, target_ply )
ulx.fancyLogAdmin( {calling_ply, target_ply},true, "#P via admin respond to #P: " .. message, calling_ply, target_ply )
end
local respond = ulx.command("Essentials", "ulx respond", ulx.respond, "#",true,true)
respond:addParam{ type=ULib.cmds.PlayerArg }
respond:addParam{ type=ULib.cmds.StringArg, hint="message", ULib.cmds.takeRestOfLine }
respond:defaultAccess( ULib.ACCESS_ADMIN)
respond:help( "Send anonymous admin message." )

function ulx.resetscore(calling_ply, target_ply)
	target_ply:SetFrags(0)
	target_ply:SetDeaths(0)
	ulx.fancyLogAdmin( calling_ply, "#A reset the score of #T", target_ply )
end
local resetscore = ulx.command("Essentials", "ulx resetscore", ulx.resetscore, "!reset")
resetscore:addParam{ type=ULib.cmds.PlayerArg }
resetscore:defaultAccess( ULib.ACCESS_ADMIN )
resetscore:help( "Reset kills and deaths of a player." )

function ulx.watch(calling_ply, target_ply,reason)
	target_ply:SetPData("Watched","true")
	target_ply:SetPData("WatchReason",reason)
	ulx.fancyLogAdmin( calling_ply, true, "#A marked #T as watched: "..reason.. "" , target_ply )
end
local watch = ulx.command("Essentials", "ulx watch", ulx.watch, "!watch",true)
watch:addParam{ type=ULib.cmds.PlayerArg }
watch:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.takeRestOfLine }
watch:defaultAccess( ULib.ACCESS_ADMIN )
watch:help( "Puts a player on watch list." )

function ulx.unwatch(calling_ply, target_ply)
	target_ply:SetPData("Watched","false")
	target_ply:RemovePData("WatchReason")
	ulx.fancyLogAdmin( calling_ply, true, "#A removed #T from watch list", target_ply )
end
local unwatch = ulx.command("Essentials", "ulx unwatch", ulx.unwatch, "!unwatch",true)
unwatch:addParam{ type=ULib.cmds.PlayerArg }
unwatch:defaultAccess( ULib.ACCESS_ADMIN )
unwatch:help( "Removes a player from watch list." )

function userAuthed( ply, stid, unid )
	if ply:GetPData("Watched") == "true" then
		ulx.fancyLogAdmin(nil, true, "#T ("..stid.. ") is on the watchlist: "..ply:GetPData("WatchReason").. "",ply)
	end
end
hook.Add( "PlayerAuthed", "watchlisthook", userAuthed )

function ulx.watchlist(calling_ply)
	watchlist = {}
	for k, v in pairs(player.GetAll()) do
		if v:GetPData("Watched") == "true" then
			table.insert( watchlist, v:Nick())
			table.insert(watchlist, v:GetPData("WatchReason"))
		end
	end
	local watchstring = table.concat(  watchlist, ", " )
	ulx.fancyLogAdmin( nil, true,  "Watchlist: #s ",watchstring )
end
local watchlist = ulx.command("Essentials", "ulx watchlist", ulx.watchlist, "!watchlist",true)
watchlist:defaultAccess( ULib.ACCESS_ADMIN )
watchlist:help( "Prints watch list." )
