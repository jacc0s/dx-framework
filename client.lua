loadstring(exports.utils:load("import"))(); import("baka");

local sw, sh = guiGetScreenSize();
elements = {};

dx = {};
addEventHandler("onClientResourceStart", resourceRoot, function()
	baka.dx = dx;
end)

function new(_type, x, y, w, h)
	local self = {
		type = _type,
		x = x,
		y = y,
		w = w,
		h = h,
		visible = true,
		parent = nil,
		children = {},
		ox = x,
		oy = y,
		onclick = function()end,
		ontop = false,
		enabled = true,
		style = getStyle('default', _type),
		styleType = 'default',
	}

	table.insert(elements[_type], 1, self);

	function self.destroy()
		local elems = elements[self.type];
		for i=1, #elems do
			if (elems[i] == self) then
				for i=1, #self.children do
					self.children[i].destroy();
				end
				return table.remove(elems, i);
			end
		end
	end

	function self.setParent(elem)
		self.parent = elem;
		if (self.type ~= 'list') then
			self.style = getStyle(elem.styleType, self.type);
		end
		table.insert(elem.children, self);
		return self;
	end

	function self.setontop()
		local elems = elements[self.type];
		for i=1, #elems do
			local elem = elems[i];
			if (elem == self) then
				table.remove(elems, i);
				table.insert(elems, 1, self);
				elem.ontop = true;
			else
				elem.ontop = false;
			end
		end
		return self;
	end

	function self.setStyle(st)
		self.style = getStyle(st, self.type);
		self.styleType = st;

		if (not self.style) then
			err("Style '" .. st .. "' doesn't exist; using 'default' instead", 2)
			self.style = getStyle("default", self.type);
			self.styleType = "default";
		end

		if (self.style) then
			for i=1, #self.children do
				local child = self.children[i];
				child.style = getStyle(self.styleType, child.type);
			end
		end

		return self;
	end

	function self.css(...)
		if (arg[2] and type(arg[1]) == "string") then
			self.style[arg[1]] = arg[2];
		elseif (type(arg[1]) == "table") then
			for k,v in pairs(arg[1]) do
				self.style[k] = v;
			end
		end
		return self;
	end

	function self.mouseOn(x, y, w, h)
		local m = mouse();
		if (m and self.enabled) then
			if (not x) then
				if (m.x >= self.x and m.x <= self.x + self.w and m.y >= self.y and m.y <= self.y + self.h) then
					return true;
				end
			else
				if (m.x >= x and m.x <= x + w and m.y >= y and m.y <= y + h) then
					return true;
				end
			end
		end
		return false;
	end

	function self.mouseDown()
		if (self.mouseOn()) then
			return getKeyState('mouse1');
		end
		return false;
	end

	--tween vars
	local vx = 0;
	local vy = 0;
	local tx;
	local ty;
	local tweenCallback;
	local isTweening = false;

	local function move(fx, fy)
		vx = vx * 0.90;
		vy = vy * 0.90;
		vx = vx + fx;
		vy = vy + fy;
		self.x = self.x + vx;
		self.y = self.y + vy;

		local dist = getDistanceBetweenPoints2D;
		if (dist(self.x, self.y, tx, ty) < 0.05) then
			if (tweenCallback and type(tweenCallback) == "function") then
				tweenCallback();
			end
			isTweening = false;
		end
		return self;
	end

	function self.update()
		if (not self.enabled) then
			dxDrawRectangle(self.x, self.y, self.w, self.h, self.style.enabledColor);
		end

		if (isTweening) then
			local fx = tx - self.x;
			local fy = ty - self.y;
			move(fx * 0.01, fy * 0.01);
		end
	end

	function self.tween(x, y, ms, callback)
		tx = x;
		ty = y;
		tweenCallback = callback;
		isTweening = true;
		return self;
	end

	function self.align(state)
		if (not self.parent) then
			if (state == "center") then
				self.x = sw/2-self.w/2;
				self.y = sh/2-self.h/2;
			elseif (state == "centerY") then
				self.y = sh/2-self.h/2;
			elseif (state == "centerX") then
				self.x = sw/2-self.w/2;
			end
		else
			if (state == "center") then
				self.ox = self.parent.w/2-self.w/2;
				self.oy = self.parent.h/2-self.h/2;
			elseif (state == "centerY") then
				self.oy = self.parent.h/2-self.h/2;
			elseif (state == "centerX") then
				self.ox = self.parent.w/2-self.w/2;
			end
		end
		return self;
	end

	function self.setPosition(x, y)
		self.x = x;
		self.y = y;
		return self;
	end

	function self.getPosition()
		return self.x, self.y;
	end

	function self.setSize(w, h)
		self.w = w;
		self.h = h;
		return self;
	end

	function self.getSize()
		return self.w, self.h;
	end

	function self.setVisible(v)
		self.visible = v;
		return self;
	end

	function self.getVisible()
		return self.visible;
	end

	function self.setEnabled(v)
		self.enabled = v;
		return self;
	end

	function self.getEnabled()
		return self.enabled;
	end

	function self.click(callback)
		self.onclick = callback;
		return self;
	end

	return self;
end

addEventHandler('onClientRender', root, function()
	for _type, elems in pairs(elements) do
		for i=#elems, 1, -1 do
			local elem = elems[i];

			if (not elem.parent) then
				if (elem.visible) then
					elem.draw();
					elem.update();

					if (_type ~= 'window') then
						elem.ontop = true;
					end
				end

				for j=1, #elem.children do
					local child = elem.children[j];

					child.x = child.ox + elem.x;
					child.y = child.oy + elem.y;
					child.ontop = elem.ontop;
					child.visible = elem.visible;
					--child.enabled = elem.enabled;

					if (child.visible) then
						child.draw();
						child.update();
					end
				end

				if (_type == 'window' and elem.visible and elem.showBorders) then
					elem.drawBorders();
				end
			end
		end
	end
end);

addEventHandler('onClientKey', root, function(key, down)
	for _type, elems in pairs(elements) do
		for i=1, #elems do
			local elem = elems[i];
			local mo = elem.mouseOn();
			if (elem.visible and elem.enabled) then
				if (key == 'mouse1' and down) then
					if (_type == 'window') then
						if (mo) then
							return elem.setontop();
						else
							elem.ontop = false;
						end
					end
				end
				if (elem.ontop) then
					if (elem.onKey) then
						local callback = elem.onKey(key, down);
						if (callback) then
							return callback();
						end
					end
				end
			end
		end
	end
end);

elements.input = {};
function dx.input(text, x, y, w, h)
	local self = new('input', x, y, w, h);
	self.text = text;
	self.masked = false;
	self.readonly = false;
	self.maxLength = nil;
	self.active = false;
	self.font = "default-bold";
	self.fontSize = 1.35;

	function self.draw()
		local text = self.masked and string.rep("*",self.text:len()) or self.text;
		local textWidth = dxGetTextWidth(text, self.fontSize, self.font, false);

		dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(255,255,255,255));
		dxDrawText(text, self.x, self.y, self.x + self.w, self.y + self.h, tocolor(28, 27, 28, 255), self.fontSize, self.font, "left", "center", true, false, true, false, false);

		if (self.active and getTickCount() % 1000 < 500) then
			local x = textWidth < self.w and self.x + textWidth or self.x + self.w - 3;
			local y = self.y + 2;

			dxDrawRectangle(x, y, 2, 24, tocolor(22, 22, 22, 255), true);
		end
	end

	function self.cancelCharEvent()
		guiSetInputMode("allow_binds");
		removeEventHandler("onClientCharacter", root, self.onChar);
		self.active = false;
	end

	function self.onChar(_char)
		if (self.visible and self.active) then
			self.text = self.text .. _char;
		else
			self.cancelCharEvent();
			self.active = false
		end
	end

	function self.onKey(key, down)
		if (self.readonly) then	return end

		if (key == 'mouse1') then
			if (self.mouseOn()) then
				if (not self.active) then
					guiSetInputMode("no_binds");
					addEventHandler("onClientCharacter", root, self.onChar);
					self.active = true;
				end
			else
				self.cancelCharEvent();
			end
		elseif (key == 'backspace' and down) then
			if (self.active) then
				self.text = self.text:sub(1, -2);
			end
		end
		if (self.active) then
			--cancelEvent();
		end
	end

	return self;
end

elements.list = {};
function dx.grid(text, x, y, w, h)
	local self = new('list', x, y, w, h);
	self.title = text;
	self.titleHeight = 30;
	self.showTitleBar = true;
	self.items = {};
	self.itemh = 35;
	self.itemSpacing = 2;
	self.selectedItem = 0;
	self.sb = {
		w = 16;
		thumb = {};
	}

	self.maxItems = nil;
	self.sp = 1;
	self.ep = nil;
	self.onselect = function()end;

	function self.addItem(title, data, color, draw)
		local item = {};
		item.id = #self.items;
		item.title = title;
		item.data = data;
		item.color = color;
		item.draw = draw;
		item.onclick = function()end;
		item.onDoubleClick = function()end;
		table.insert(self.items, item);
		return item;
	end

	function self.clear()
		self.items = {};
		self.selectedItem = 0;
		self.sp = 1;
	end

	function self.sort(_type)
		local f;
		if (not _type) then
			f = function(a,b) return a < b end
		else
			f = function(a,b) return a[_type] < b[_type] end
		end
		table.sort(self.items, f);
	end

	function self.onKey(key, down)
		if (key == 'arrow_d') then
			if (down) then
				return self.selectNextItem();
			end
		elseif (key == 'arrow_u') then
			if (down) then
				return self.selectPrevItem();
			end
		elseif (key == 'enter') then
			if (not down) then
				if (self.items[self.selectedItem]) then
					return self.items[self.selectedItem].onclick();
				end
			end
		elseif (key == 'mouse1' and self.mouseOn()) then
			if (not down) then
				for j=self.sp, self.ep do
					local item = self.items[j];
					if (item) then
						if (self.mouseOn(item.x, item.y, item.w, item.h)) then
							self.selectedItem = j;
							return item.onclick;
						end
					end
				end
			end
		elseif (key == 'mouse_wheel_up') then
			return self.scroll('up');
		elseif (key == 'mouse_wheel_down') then
			return self.scroll('down');
		end
	end

	function self.selectNextItem()
		if (self.selectedItem == self.ep) then
			self.scroll('down');
		end
		if (self.selectedItem >= #self.items) then
			self.selectedItem = 1;
			self.sp = 1;
		else
			self.selectedItem = self.selectedItem + 1;
		end
		self.onselect(self.items[self.selectedItem]);
	end

	function self.selectPrevItem()
		if (self.selectedItem == self.sp) then
			self.scroll('up');
		end
		if (self.selectedItem <= 1) then
			self.selectedItem = #self.items;
			self.sp = #self.items > self.maxItems and #self.items - self.maxItems or 1;
		else
			self.selectedItem = self.selectedItem - 1;
		end
		self.onselect(self.items[self.selectedItem]);
	end

	function self.draw()
		local style = self.style;
		-- bg
		dxDrawRectangle(self.x, self.y, self.w, self.h, style.mainBg.color, false);

		-- title
		dxDrawRectangle(self.x, self.y, self.w, self.titleHeight, style.mainBg.color, false);
		dxDrawText(self.title, self.x, self.y, self.x + self.w, self.y + self.titleHeight, style.itemText.color, 1.25, "default", "center", "center", true, false, false, false, false);

		-- scrollbar
		self.sb.x = self.x + self.w - self.sb.w;
		self.sb.y = self.y + self.titleHeight;
		self.sb.w = self.sb.w;
		self.sb.h = self.h - self.titleHeight;

		self.sb.thumb.y = self.sb.y + self.sb.w;
		self.sb.thumb.h = 22;

			-- shaft
			dxDrawRectangle(self.sb.x, self.sb.y, self.sb.w, self.sb.h, tocolor(77,77,77,255), false);
			-- thumb
			dxDrawRectangle(self.sb.x, self.sb.thumb.y, self.sb.w, self.sb.thumb.h, tocolor(177,177,177,255), false);
			-- arrows
			dxDrawText("▲", self.sb.x, self.sb.y, self.sb.x + self.sb.w, self.sb.y + self.sb.w, tocolor(211,211,211,255), 1.2, "default", "center", "center", true, false, true, false, false);
			dxDrawText("▼", self.sb.x, self.y + self.h - self.sb.w, self.x + self.w, self.y + self.h, tocolor(211,211,211,255), 1.2, "default", "center", "center", true, false, true, false, false);

		-- draw items
		self.drawItems();
	end

	function self.scroll(state)
		if state == "up" then
			if self.sp > 1 then
				self.sp = self.sp - 1;
			end
			return;
		end
		if state == "down" then
			if self.sp < #self.items - self.maxItems then
				self.sp = self.sp + 1;
			end
		end
	end

	function self.drawItems()
		local style = self.style
		local yOffset = self.itemh + self.itemSpacing
		self.maxItems = math.floor((self.h + self.itemSpacing - self.titleHeight) / yOffset) - 1
		self.ep = self.sp + self.maxItems

		for i=self.sp, self.ep do local item = self.items[i];
			if item then
				item.id = i;
				yOffset = i > self.sp and yOffset + (self.itemh + self.itemSpacing) or 0
				-- clicking positions
				item.x = self.x
				item.y = self.y + self.titleHeight + yOffset
				item.w = self.w - self.sb.w
				item.h = self.itemh

				-- item style
				local mo = self.ontop and self.mouseOn(item.x, item.y, item.w, item.h)
				local textFont = (mo and style.itemHover.font) or style.itemText.font
				local textSize = (mo and style.itemHover.size) or style.itemText.size
				local textColor = (self.selectedItem == i and style.itemSelect.textColor) or (mo and style.itemHover.textColor) or item.color or style.itemText.color
				local bgColor = (self.selectedItem == i and style.itemSelect.color) or (mo and style.itemHover.bgColor) or style.itemBg.color

				-- item bg
				dxDrawRectangle(item.x, item.y, item.w, item.h, bgColor, false)

				-- draw on item
				if item.draw and type(item.draw) == "function" then
					item.draw(item)
				end

				-- item text
				if style.itemText.shadow then
					dxDrawText(item.title, item.x + 1, item.y + 1, item.x + item.w + 1, item.y + item.h + 1, tocolor(0, 0, 0, 255), textSize, textFont, "center", "center", true, false, false, false, false)
				end

				dxDrawText(item.title, item.x, item.y, item.x + item.w, item.y + item.h, textColor, textSize, textFont, "center", "center", true, false, false, false, false)
			end
		end
	end

	return self;
end

elements.window = {};
function dx.window(text, x, y, w, h, color)
	local self = new('window', x, y, w, h);
	self.text = ' ' .. text or '';
	self.style.bgColor = color or self.style.bgColor;
	self.showTitleBar = true;
	self.moveable = true;

	function self.init()
		self.closeBtn = dx.button("X", self.w - self.style.titleHeight, 0, self.style.titleHeight, self.style.titleHeight, self.style.closeBgColor);
		self.closeBtn.setParent(self);
		self.closeBtn.onclick = function() self.visible = false; end
		self.closeBtn.style.bgHover = self.style.closeBgHover;
		self.closeBtn.showBorderOnHover = false;
		self.closeBtn.showBorders = false;
	end

	self.showBorders = true;
	self.init();

	function self.showTitlebar(show)
		if (not show) then
			self.showTitleBar = false;
			self.closeBtn.destroy();
		else
			self.init();
		end
	end

	local mo;

	function self.draw()
		if (self.showTitleBar and self.style.titleHeight > 0 and self.moveable) then
			local x, y = self.drag();
			if (x) then
				self.x = self.x + x;
				self.y = self.y + y;
			end
		end

		dxDrawRectangle(self.x, self.y, self.w, self.h, self.style.bgColor);

		if (self.showTitleBar and self.style.titleHeight > 0) then
			self.closeBtn.visible = true;

			if (self.ontop) then
				local md = self.mouseDown();
				mo = md and self.mouseOn(self.x, self.y, self.w - self.style.titleHeight, self.style.titleHeight);
			end

			dxDrawRectangle(self.x, self.y, self.w, self.style.titleHeight, self.style.titleBgColor);
			--dxDrawImage(self.x, self.y, self.w, self.style.titleHeight, "img/titlebar.jpg", 0, 0, 0, self.style.titleBgColor);

			if (self.style.shadow) then
				dxDrawText(self.text, self.x + 5 + 1, self.y + 1, self.x + self.w - self.style.titleHeight - 10 + 1, self.y + self.style.titleHeight + 1, tocolor(0,0,0,255), self.style.fontSize, "default", "left", "center");
			end

			dxDrawText(self.text, self.x + 5, self.y, self.x + self.w - self.style.titleHeight - 10, self.y + self.style.titleHeight, self.style.color, self.style.fontSize, "default", "left", "center");
		else
			self.closeBtn.visible = false;
		end
	end

	function self.drawBorders()
		dxDrawLine(self.x, self.y, self.x + self.w, self.y, self.style.borderColor, self.style.borderSize)
		if (self.showTitleBar) then
			dxDrawLine(self.x, self.y + self.style.titleHeight, self.x + self.w, self.y + self.style.titleHeight, self.style.borderColor, self.style.borderSize)
		end
		dxDrawLine(self.x, self.y + self.h, self.x + self.w, self.y + self.h, self.style.borderColor, self.style.borderSize)
		dxDrawLine(self.x, self.y, self.x, self.y + self.h, self.style.borderColor, self.style.borderSize)
		dxDrawLine(self.x + self.w, self.y, self.x + self.w, self.y + self.h, self.style.borderColor, self.style.borderSize)
	end

	local px, py = 0, 0;

	function self.drag()
		local m = mouse();
		if (m) then
			if (mo) then
				local x = m.x - px;
				local y = m.y - py;
				px = m.x;
				py = m.y;
				if (x ~= 0 or y ~= 0) then
					return x, y;
				end
			else
				px = m.x;
				py = m.y;
			end
		end
	end

	self.setontop();
	return self;
end

elements.button = {};
function dx.button(text, x, y, w, h, color)
	local self = new('button', x, y, w or 115, h or 35);
	self.text = text or '';
	self.style.bgColor = color or self.style.bgColor;
	self.showBorders = true;
	self.showBorderOnHover = false;

	function self.onKey(key, down)
		if (self.mouseOn()) then
			if (key == 'mouse1' and not down) then
				return self.onclick;
			end
		end
	end

	function self.draw()
		local mo = self.mouseOn();
		local ot = mo and self.ontop or false;
		mo = ot and mo
		local md = ot and self.mouseDown();

		local bgColor = mo and self.style.bgHover or self.style.bgColor;
		local color = md and self.style.hover or self.style.color;
		local textSize = md and 1.37 or self.style.fontSize;

		dxDrawRectangle(self.x, self.y, self.w, self.h, bgColor);
		--dxDrawImage(self.x, self.y, self.w, self.h, "img/button.png", 0, 0, 0, bgColor);

		if (self.style.shadow) then
			dxDrawText(self.text, self.x + 1, self.y + 1, self.x + self.w + 1, self.y + self.h + 1, tocolor(0,0,0,255), textSize, "default", "center", "center", true);
		end

		dxDrawText(self.text, self.x, self.y, self.x + self.w, self.y + self.h, color, textSize, "default", "center", "center", true);

		if (self.showBorders or mo and self.showBorderOnHover) then
			self.drawBorders();
		end
	end

	function self.drawBorders()
		dxDrawLine(self.x, self.y, self.x + self.w, self.y, self.style.borderColor, self.style.borderSize)
		dxDrawLine(self.x, self.y + self.h, self.x + self.w, self.y + self.h, self.style.borderColor, self.style.borderSize)
		dxDrawLine(self.x, self.y, self.x, self.y + self.h, self.style.borderColor, self.style.borderSize)
		dxDrawLine(self.x + self.w, self.y, self.x + self.w, self.y + self.h, self.style.borderColor, self.style.borderSize)
	end

	return self;
end

elements.checkbox = {};
function dx.checkbox(text, x, y, w, h, onclick)
	local self = new('checkbox', x, y, w, h);
	self.text = text;
	self.selected = false;
	self.onclick = onclick or function()end

	function self.onKey(key, down)
		if (self.mouseOn()) then
			if (key == 'mouse1' and not down) then
				return self.toggle;
			end
		end
	end

	function self.draw()
		local co = self.h * 0.85;

		dxDrawRectangle(self.x, self.y, self.w, self.h, self.style.bgColor);
		dxDrawRectangle(self.x, self.y, self.h, self.h);
		if (self.selected) then
			dxDrawRectangle(self.x + co, self.y + co, self.h - co*2, self.h - co*2, self.style.bgSelected);
		end

		local color = self.mouseOn() and self.ontop and self.style.hover or self.style.color;

		dxDrawText(self.text, self.x + self.h + 5, self.y, self.x + self.w - 5, self.y + self.h, color, self.h * 0.075, "default", "left", "center", true);
	end

	function self.toggle()
		self.selected = not self.selected;
		self.onclick(self.selected);
	end

	return self;
end

elements.label = {};
function dx.label(text, x, y, w, h, color, scale, shadowed, font, alignleft, aligntop)
	local self = new('label', x, y, w, h);
	self.text = text;
	self.color = color or tocolor(255,255,255,255);
	self.scale = scale or 1;
	self.bgVisible = false;
	self.bgColor = tocolor(0,0,0,200);
	self.shadow = shadowed or false;

	function self.draw()
		if (self.bgVisible) then
			dxDrawRectangle(self.x, self.y, self.w, self.h, self.bgColor);
		end
		if (self.shadow) then
			dxDrawText(self.text, self.x + 1, self.y + 1, self.x + self.w + 1, self.y + self.h + 1, tocolor(0,0,0,255), self.scale, font or "default", alignleft or "left", aligntop or "top", true);
		end
		dxDrawText(self.text, self.x, self.y, self.x + self.w, self.y + self.h, self.color, self.scale, font or "default", alignleft or "left", aligntop or "top", true);
	end

	return self;
end

elements.image = {};
function dx.image(src, x, y, w, h)
	local self = new('image', x, y, w, h);
	self.src = src;

	function self.draw()
		dxDrawImage(self.x, self.y, self.w, self.h, self.src);
	end

	return self;
end

elements.progressBar = {};
function dx.progressBar(x, y, w, h, onFinish)
	local self = new('progressbar', x, y, w or 115, h or 35);
	self.value = 0;
	self.maxValue = 100;
	self.onFinish = onFinish or function()end
	local called = false;
	--local ms;

	function self.draw()
		dxDrawRectangle(self.x, self.y, self.w, self.h, self.style.bgColor);
		dxDrawRectangle(self.x+self.style.spacing, self.y+self.style.spacing, self.w-self.style.spacing*2, self.h-self.style.spacing*2, self.style.innerColor);

		if (self.value < 0) then
			self.value = 0;
		elseif (self.value > self.maxValue) then
			self.value = self.maxValue;
		end

		if (self.value == self.maxValue) then
			if (not called and type(self.onFinish) == "function") then
				self.onFinish();
				called = true;
			end
		else
			called = false;
		end

		local width = self.value / self.maxValue * (self.w - self.style.spacing*2);
		dxDrawRectangle(self.x+self.style.spacing, self.y+self.style.spacing, width, self.h-self.style.spacing*2, self.style.progressColor);

		if (self.style.shadow) then
			dxDrawText(self.value.."%", self.x+self.style.spacing+1, self.y+self.style.spacing+1, self.x+self.style.spacing + width+1, self.y+self.style.spacing + self.h-self.style.spacing*2+1, tocolor(0,0,0,255), self.style.fontSize, "default", "center", "center", true);
		end
		dxDrawText(self.value.."%", self.x+self.style.spacing, self.y+self.style.spacing, self.x+self.style.spacing + width, self.y+self.style.spacing + self.h-self.style.spacing*2, self.style.color, self.style.fontSize, "default", "center", "center", true);
	end

	return self;
end

function dx.alert(msg, ycallback, ncallback, btn1text, btn2text)
	local self = dx.window("alert", 0, 0, 400, 300);
	self.align("center");
	self.label = dx.label(msg, 0, 0, self.w, self.h - 60, self.style.color, 1.5, true, "default", "center", "center");
	self.label.setParent(self);

	self.closeBtn.onclick = function()
		self.destroy();
	end

	if (not ncallback) then
		local y = dx.button(btn1text or "Ok", 0, 200);
		y.setParent(self);
		y.align('centerX');
		y.onclick = function()
			if (ycallback) then
				ycallback();
			end
			self.destroy();
		end
	end

	if (ycallback and ncallback) then
		local y = dx.button(btn1text or "yes", 60, 200);
		local n = dx.button(btn2text or "no", 225, 200);
		y.setParent(self);
		n.setParent(self);
		y.onclick = function()
			ycallback();
			self.destroy();
		end
		n.onclick = function()
			ncallback();
			self.destroy();
		end
	end

	return self;
end
