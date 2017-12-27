local sw, sh = guiGetScreenSize();

styles = {};

styles['default'] = {
	window = {
		color = tocolor(255,255,255,255),
		bgColor = tocolor(0,0,0,225),
		borderColor = tocolor(255,255,255,255),
		closeColor = tocolor(255,255,255,255),
		closeBgColor = tocolor(0,0,0,200),
		closeBgHover = tocolor(255,0,255,120),
		titleColor = tocolor(255,255,255,255),
		titleBgColor = tocolor(111,111,111,255),
		titleHeight = 28,
		borderSize = 1,
		fontSize = 1.5,
		shadow = true,
	},

	button = {
		color = tocolor(255,255,255,255),
		bgColor = tocolor(65,65,65,235),
		borderColor = tocolor(255,255,255,255),
		hover = tocolor(180,180,180,255),
		bgHover = tocolor(45,45,45,235),
		enabledColor = tocolor(0,0,0,200),
		fontSize = 1.60,
		shadow = true,
	},

	checkbox = {
		color = tocolor(255,255,255,255),
		bgColor = tocolor(0,0,0,50),
		hover = tocolor(210,210,210,255),
		bgSelected = tocolor(0,0,0,255),
		enabledColor = tocolor(0,0,0,200),
		shadow = true,
	},

	progressbar = {
		color = tocolor(255,255,255,255),
		bgColor = tocolor(0,0,0,160),
		innerColor = tocolor(255,255,255,255),
		progressColor = tocolor(55,75,255,255),
		enabledColor = tocolor(0,0,0,200),
		spacing = 4,
		fontSize = 1.20,
		shadow = true,
	},

	list = {
		mainBg = {
			color = tocolor(0,0,0,255),
		},

		itemBg = {
			color = tocolor(50,50,50,255),
		},

		itemText = {
			color = tocolor(255,255,255,255),
			font = "default",
			size = 1,
			shadow = false,
		},

		itemHover = {
			bgColor = tocolor(100,100,100,255),
			textColor = tocolor(200,200,55,255),
			font = "default",
			size = 1,
		},

		itemSelect = {
			color = tocolor(44,150,150,255),
			font = "default",
			size = 1,
		},
	},
}

styles['win95'] = {
	window = {
		color = tocolor(255,255,255,255),
		bgColor = tocolor(191,191,191,205),
		borderColor = tocolor(255,255,255,255),
		closeColor = tocolor(255,255,255,255),
		closeBgColor = tocolor(0,0,0,200),
		closeBgHover = tocolor(255,0,255,120),
		titleColor = tocolor(255,255,255,255),
		titleBgColor = tocolor(55,111,255,255),
		titleHeight = 28,
		borderSize = 1,
		fontSize = 1.5,
		shadow = true,
	},

	button = {
		color = tocolor(255,255,255,255),
		bgColor = tocolor(115,115,115,235),
		borderColor = tocolor(255,255,255,255),
		hover = tocolor(180,180,180,255),
		bgHover = tocolor(95,95,95,235),
		enabledColor = tocolor(151,151,151,220),
		fontSize = 1.6,
		shadow = true,
	},

	checkbox = {
		color = tocolor(255,255,255,255),
		bgColor = tocolor(0,0,0,50),
		hover = tocolor(210,210,210,255),
		bgSelected = tocolor(0,0,0,255),
		enabledColor = tocolor(151,151,151,220),
		shadow = true,
	},
}

function err(msg, depth)
	local inf = debug.getinfo(depth+1 or 2);
	print("WARNING: " .. inf.short_src .. ":" .. inf.currentline .. ": " .. msg);
end

function mouse()
	local cx, cy = getCursorPosition();
	return cx and Vector2(cx*sw, cy*sh) or false;
end

function table.copy(t)
	local new = {};
	for k,v in pairs(t) do
		if (type(v) == "table") then
			v = table.copy(v);
		end
		new[k] = v;
	end
	return new;
end

function getStyleList()
	local s = {};
	for k in pairs(styles) do
		s[#s+1] = k;
	end
	return s;
end

function getStyle(st, et)
	local style = styles[st] and styles[st][et];
	return style and table.copy(style);
end
