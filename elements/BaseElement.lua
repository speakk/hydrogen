local Class = require 'libs.hump.class'

return Class {
  init = function(self, options)
    self.id = options.id
    self.x = options.x or 0
    self.y = options.y or 0
    self.w = options.w or 0
    self.h = options.h or 0
    self.layout = options.layout
    self.fillW = options.fillW
    self.fillH = options.fillH
    self.growH = options.growH
    self.children = options.children or {}
    self.draw_func = options.draw_func
    self.transform_func = options.transform_func or function(x, y) return x, y end
    self.onClick = options.onClick
    self.margin = options.margin or 0
    self.percentageW = options.percentageW
    self.percentageH = options.percentageH

    for key, prop in pairs(options) do
      if self[key] == nil then
        self[key] = prop
      end
    end
  end,
  draw = function(self, x, y, parentW, parentH)
    if self.backgroundColor then
      love.graphics.setColor(self.backgroundColor)
      love.graphics.rectangle(
      'fill',
      self.x + (x or 0),
      self.y + (y or 0),
      self.w,
      self.h
      )
    end

    if self.draw_func then
      self:draw_func(x, y, parentW or self.w, parentH or self.h)
    end

    for _, element in ipairs(self.children) do
      element:draw(self.x + (x or 0), self.y + (y or 0), parentW or self.w, parentH or self.h)
    end
  end,
  addChild = function(self, child)
    child.transform_func = self.transform_func
    table.insert(self.children, child)

    if child.id then
      self.children[child.id] = child
    end

    return child
  end,
  removeChild = function(self, child)
    for i, existingChild in ipairs(self.children) do
      if existingChild == child then
        table.remove(self.children, i)
        return
      end
    end
  end,
  emptyChildren = function(self)
    for i=#(self.children),1,-1 do
      table.remove(self.children, i)
    end
  end,
  isInElement = function(self, x, y)
    return
      x > self.x and
      x < self.x + self.w and
      y > self.y and
      y < self.y + self.h
  end,
  mouse_moved = function(self, x, y)
    if not self.x or not self.y then return end
    if not x or not y then return end

    for _, child in ipairs(self.children) do
      child:mouse_moved(x - self.x, y - self.y)
    end

    if self:isInElement(x, y) then
      if self.onHover then
        self:onHover(x, y)
      end
    else
      if self.onHoverOut then
        self:onHoverOut(x, y)
      end
    end
  end,
  mouse_pressed = function(self, x, y, button)
    if not self.x or not self.y then return end
    if not x or not y then return end

    for _, child in ipairs(self.children) do
      child:mouse_pressed(x - self.x, y - self.y, button)
    end

    if self:isInElement(x, y) then
      if self.onClick then
        self:onClick(x, y)
      end
    end
  end,
  update = function(self, dt)
    if self.growH then
      self.h = 0
    end

    for _, child in ipairs(self.children) do
      if child.fillW then
        child.x = 0
        child.w = self.w
      end
      if child.fillH then
        child.y = 0
        child.h = self.h
      end
      if child.percentageW then
        child.w = self.w * child.percentageW
      end
      if child.percentageH then
        child.h = self.h * child.percentageH
      end

      child:update(dt)

      if self.growH then
        self.h = self.h + child.h + child.margin
      end
    end

    if self.layout == "vertical" then
      local totalVertical = 0

      for i, child in ipairs(self.children) do
        local margin = child.margin
        if i == #self.children then margin = 0 end
        totalVertical = totalVertical + child.h + margin
      end

      local startY = self.h/2 - totalVertical/2
      local currentY = startY

      for _, child in ipairs(self.children) do
        child.x = self.w/2 - child.w/2
        child.y = currentY

        currentY = currentY + child.h + child.margin
      end
    end

    if self.layout == "horizontal" then
      local totalHorizontal = 0

      for i, child in ipairs(self.children) do
        local margin = child.margin
        if i == #self.children then margin = 0 end
        totalHorizontal = totalHorizontal + child.w + margin
      end

      local startX = self.w/2 - totalHorizontal/2
      local currentX = startX

      for _, child in ipairs(self.children) do
        child.x = currentX
        child.y = self.h/2 - child.h/2

        currentX = currentX + child.w + child.margin
      end
    end
  end
}
