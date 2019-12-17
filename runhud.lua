function setup_hud()
	RUN_info = {}
    RUN_info.box={
	    pos={x=hud_x_pos,y=hud_y_pos},
	    text={font='Impact', size=hud_font_size, Fonts={'sans-serif'},},
	    bg={alpha=hud_transparency,red=0,green=15,blue=0},
	    flags={draggable=hud_draggable},
	    padding=7
    }
    window = texts.new(RUN_info.box)
    initialize(window, RUN_info.box)
	window:show()
    updatedisplay()
end

 
function initialize(text, settings)
	local properties = L{}
	properties:append('Job :  \\cs(251, 255, 3)${job}\\cr')
	properties:append('${weapons}')
	properties:append('${Engaged}')
	properties:append('${Hybrid}')
	properties:append('${AutoDefense}')	
	properties:append('${Defense}')
	properties:append('${ChangeRune}')	
	properties:append('${AutoRune}')
	properties:append('${AutoTank}')
	properties:append('${Casting}')
	properties:append('${Idle}')
	
	text:clear()
	text:append(properties:concat('\n'))
end
function concat_strings(s)
    local t = { }
    for k,v in ipairs(s) do
        t[#t+1] = tostring(v)
    end
    return table.concat(t,"\n")
end
function set_hud_info()
	end

update_delay=0
function updatedisplay() --update hud display
	if update_delay ~=0 then
		coroutine.sleep(update_delay)
		update_delay = 0
	end
	set_hud_info()
	local info = {}
	info.job = player.job
	info.weapons = "\\cs(204, 0, 0)[F7]\\cr   Change Weapons"
	info.Engaged = "\\cs(204, 0, 0)[F9]\\cr   Engaged Mode"
	info.Hybrid = "\\cs(204, 0, 0)[CTRL+F9]\\cr   Hybrid Mode"	
	info.AutoRune= "\\cs(204, 0, 0)[Win+Pause]\\cr   Auto Rune"
	info.ChangeRune= "\\cs(204, 0, 0)[Win+`]\\cr   Change Rune"
	info.AutoTank = "\\cs(204, 0, 0)[Win+F8]\\cr   Auto Tanking"
	info.AutoDefense = "\\cs(204, 0, 0)[Alt+F8]\\cr   Toggle Auto Defense"
	info.Defense = "\\cs(204, 0, 0)[Alt+F12]\\cr   Reset Defense Mode"
	info.Casting = "\\cs(204, 0, 0)[Win+F11]\\cr   Casting Mode"
	info.Idle = "\\cs(204, 0, 0)[Win+F12]\\cr   Idle Mode"
	
	--button:update(info)
	--button:show()
	window:update(info)
	if display_hud then
		window:show()
	end
end