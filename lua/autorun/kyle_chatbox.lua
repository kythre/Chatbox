if SERVER then 	AddCSLuaFile() return end

print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")

chatbox = {}

function chatbox.init()
	chatbox.frame = vgui.Create( "DFrame" )
	chatbox.frame:SetTitle("Chatbox")
	chatbox.frame:SetSize( ScrW()*0.25, ScrH()*0.25 )
	chatbox.frame:SetPos( ScrW()*0.04, (ScrH() - chatbox.frame:GetTall()) - ScrH()*0.177)
	chatbox.frame:SetMinWidth( 300 )
	chatbox.frame:SetMinHeight( 100 )
	chatbox.frame:SetDraggable( true )
	chatbox.frame:SetSizable( false )
	chatbox.frame:SetDeleteOnClose(false)
	chatbox.frame:Hide()
	chatbox.frame.Paint = function( self, w, h )
		chatbox.blur( self, 10, 5, 1 ) --ADD TO SETTINGS MENUE. ADD ALLLL THIS SHIT TO A SETTINGS MENU GAT DAM DIS GONNA BE BEAUTIFUl
		draw.RoundedBox( 14, 0, 0, w, h, Color( 30, 30, 30, 200 ) ) --body
		draw.RoundedBox( 0, 0, 0, w, 25, Color( 80, 80, 80, 100 ) ) --header
	end
	
	chatbox.textentry = vgui.Create( "DTextEntry", chatbox.frame  ) -- create the form as a child of frame
	chatbox.textentry:SetSize( chatbox.frame:GetWide(), 20 )
	chatbox.textentry:SetPos( 0, chatbox.frame:GetTall()-chatbox.textentry:GetTall()-1 )
	chatbox.textentry:SetEditable( true )
	chatbox.textentry:Hide()
	chatbox.textentry.OnEnter = function( self )
		LocalPlayer():ConCommand( "say \""..self:GetValue().."\"" )
	
		chatbox.textentry:SetText("")
		chatbox.close()
	end
	chatbox.textentry.AllowInput = function( self, stringValue )
		return false
	end

	
	--[[
	chatbox.textarea = vgui.Create( "RichText", chatbox.frame )
	chatbox.textarea:SetPos(0,0)
	chatbox.textarea:Dock( TOP )
	chatbox.textarea:SetSize(chatbox.frame:GetWide(), chatbox.frame:GetTall()-chatbox.textentry:GetTall()-30)
	]]
	
	chatbox.html = vgui.Create( "DHTML" , chatbox.frame )
	chatbox.html:Dock( FILL )
	chatbox.html:SetHTML("<ul id=\"chat\"></ul>")

end

function chatbox.open(z)
	chatbox.frame:MakePopup()
	chatbox.frame:Show()
	chatbox.textentry:Show()
	chatbox.textentry:RequestFocus()
	gamemode.Call( "StartChat" )
end

function chatbox.close()
	chatbox.frame:Hide()
	chatbox.textentry:Hide()
	chatbox.frame:SetMouseInputEnabled( false )
	chatbox.frame:SetKeyboardInputEnabled( false )
	gui.EnableScreenClicker( false )
	gamemode.Call( "FinishChat" )
	chatbox.textentry:SetText( "" )
	gamemode.Call( "ChatTextChanged", "" )
end

local blur = Material( "pp/blurscreen" )
function chatbox.blur( panel, layers, density, alpha )
	local x, y = panel:LocalToScreen(0, 0)
	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( blur )

	for i = 1, 3 do
		blur:SetFloat( "$blur", ( i / layers ) * density )
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
	end
end

hook.Add( "ChatText", "kyle_chatbox_chattext", function( index, name, text, type )
	if type == "joinleave" or type == "none" then
		chatbox.html:Call( "document.body.innerHTML += \"<li><span style='color:rgba(255,255,255,255);'>"..text.."</span></li>\";")
	end
end )

function chat.AddText( ... )
	local args = { ... }
	local message = ""
	local messagec = ""
	local color = ""
	for _, obj in pairs( args ) do
		if type(obj) == "table" then -- We were passed a color object
			color ="style='color:rgba("..obj.r..","..obj.g..","..obj.b..",255);'"
		elseif type(obj) == "string" then -- This is just a string
			message = message.."<span "..color..">"..obj.."</span>"
			messagec = messagec..obj
		elseif obj:IsPlayer() then
			message = message.."<span "..color..">"..obj:Nick().."</span>"
			messagec = messagec..obj
		end
	end
	chatbox.html:Call( "document.body.innerHTML += \"<li>"..message.."</li>\";")
end

hook.Add( "PlayerBindPress", "kyle_chatbox_playerbindpress", function( x, y, z )
	if not (y == "messagemode2" or y == "messagemode") then return end
	chatbox.open( y == "messagemode2" )
	return true
end )




if not GAMEMODE then
	hook.Remove("Initialize", "kyle_chatbox_init")
	hook.Add("Initialize", "kyle_chatbox_init", function()
		include("autorun/kyle_chatbox.lua")
		chatbox.init()
	end)
	else
	chatbox.init()
	return
end
