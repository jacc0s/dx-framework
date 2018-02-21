elements.list = {};
function dx.grid(x, y, w, h)
	local self = new('list', x, y, w, h);
	self.titleh = 25;
	self.columns = {};
	self.items = {};
	self.itemh = 45;
	self.itemSpace = 2;
	self.maxItems = nil;
	self.sp = 1;
	self.ep = nil;
	self.selectedItem = 0;
	self.rt = DxRenderTarget(self.w, self.h, true);
	self.rt_updated = false;

	local function updateRT()
		dxSetRenderTarget(self.rt, true);
		self.drawItems();
		dxSetRenderTarget();
	end

	local function resizeColumn(col, val)
		if (col.autosize) then
			local tw = type(val) == "number" and val or dxGetTextWidth(val, 1.5);

			if (tw > col.width) then
				col.width = tw + 10;
			end
		end
	end

	function self.addColumn(val, width)
		local col = {};

		col.autosize = not width;
		col.val = val;
		col.width = width or dxGetTextWidth(val, 1.5) + 10;
		--col.btn = dx.button(val, 0, 0, width, self.titleh);
		--col.btn.onclick = function() self.sort(val) end

		table.insert(self.columns, col);
		return col;
	end

	function self.removeColumn(i)
		table.remove(self.columns, i);
	end

	function self.addItem(val, data, img, func)
		local item = {};

		item.values = type(val) ~= "table" and {val} or val;
		item.data = data;
		item.onClick = func or function()end
		item.onSelect = function()end
		item.img = img;
		item.img_col_index = 1;

		table.insert(self.items, item);

		updateRT();

		return item;
	end

	function self.removeItem(i)
		table.remove(self.items, i);
	end

	function self.clear()
		self.items = {};
		self.selectedItem = 0;
		self.sp = 1;
		updateRT();
	end

	function self.sort(_type)
		local f = function(a, b) return a < b end

		if (_type) then
			f = function(a, b)
				if (a.data[_type] and b.data[_type]) then
					return a.data[_type] > b.data[_type];
				else
					error("can't sort by that key (not found)", 4);
				end
			end
		end

		table.sort(self.items, f);
		updateRT();
	end

	function self.draw()
		self.maxItems = math.floor((self.h-self.titleh)/(self.itemh+self.itemSpace));

		dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(0,0,0,150));

		if (not self.rt_updated or self.mouseOn()) then
			updateRT(); -- draw items onto rt
			self.rt_updated = true;
		end
		
		dxDrawImage(self.x, self.y, self.w, self.h, self.rt);
	end

	function self.drawItems()
		self.ep = #self.items < self.maxItems and #self.items or self.sp + self.maxItems - 1;

		local xOff = 0;

		for j=1, #self.columns do
			local yOff = self.titleh;
			local col = self.columns[j];

			-- column title
			dxDrawText(col.val, xOff, 0, xOff + col.width, self.titleh, tocolor(255,255,220), 1.5, "default", "left", "center");

			for i=self.sp, self.ep do
				local item = self.items[i];
				local val = item.values[j];

				-- item click pos
				item.pos = {
					x = self.x,
					y = self.y + yOff,
					w = self.w,
					h = self.itemh
				}

				-- item styling
				local style = self.style;
				local mo = self.ontop and self.mouseOn(item.pos.x, item.pos.y, item.pos.w, item.pos.h)
				local textFont = (mo and style.itemHover.font) or style.itemText.font
				local textSize = (mo and style.itemHover.size) or style.itemText.size
				local textColor = (self.selectedItem == i and style.itemSelect.textColor) or (mo and style.itemHover.textColor) or item.color or style.itemText.color
				local bgColor = (self.selectedItem == i and style.itemSelect.color) or (mo and style.itemHover.bgColor) or item.bgColor or style.itemBg.color

				-- item bg
				if (j == 1) then
					dxDrawRectangle(0, yOff, self.w, self.itemh, bgColor);
				end

				-- item image
				if (item.img and fileExists(item.img) and item.img_col_index == j) then
					resizeColumn(col, self.itemh);

					dxDrawImage(xOff, yOff, self.itemh, self.itemh, item.img, 0, 0, 0);
				end

				-- item text
				if (val) then
					resizeColumn(col, val);

					if (style.itemText.shadow) then
						dxDrawText(val, xOff+1, yOff+1, xOff + col.width+1, yOff + self.itemh+1, tocolor(0, 0, 0, 255), textSize, textFont, "left", "center", true, false, false, false, false);
					end

					dxDrawText(val, xOff, yOff, xOff + col.width, yOff + self.itemh, textColor, textSize, textFont, "left", "center", true, false, false, false, false);
				end

				yOff = yOff + self.itemh + self.itemSpace;
			end
			
			xOff = xOff + col.width + 10;
		end
	end

	function self.onKey(key, down)
		if (not self.mouseOn()) then return end
		
		self.updated = false;

		if (key == "mouse_wheel_down") then
			if (self.sp <= #self.items - self.maxItems) then
				self.sp = self.sp + 1;
			end

		elseif (key == "mouse_wheel_up") then
			if (self.sp > 1) then
				self.sp = self.sp - 1;
			end

		elseif (key == 'mouse1' and not down) then
			for i=self.sp, self.ep do
				local item = self.items[i];

				if (self.mouseOn(item.pos.x, item.pos.y, item.pos.w, item.pos.h)) then
					self.selectedItem = i;
					return item.onClick;
				end
			end
		end
	end

	return self;
end
