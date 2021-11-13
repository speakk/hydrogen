## Usage guide



### Concord component example:

```lua
Concord.entity(self.world)
  :give("ui", {
    element = require 'ui.main_menu'(),
    active = true
  })
```

### Concord system example:

```lua
local UiSystem = Concord.system({ pool = { "ui" }})

function UiSystem:update(dt)
  for _, entity in ipairs(self.pool) do
    if entity.ui.active then
      entity.ui.element:update(dt)
    end
  end
end

function UiSystem:draw()
  for _, entity in ipairs(self.pool) do
    if entity.ui.active then
      entity.ui.element:draw()
    end
  end
end

function UiSystem:mouse_moved(x, y)
  local realX, realY = push:toGame(x, y)
  for _, entity in ipairs(self.pool) do
    entity.ui.element:mouse_moved(realX, realY)
  end
end

function UiSystem:mouse_pressed(x, y, button)
  local realX, realY = push:toGame(x, y)
  for _, entity in ipairs(self.pool) do
    entity.ui.element:mouse_pressed(realX, realY, button)
  end
end

return UiSystem

```

### ui.main_menu file:

```lua
local font = love.graphics.newFont('media/fonts/ThaleahFat.ttf', 48, "mono")
local titleFont = love.graphics.newFont('media/fonts/ThaleahFat.ttf', 82, "mono")

local Gamestate = require "libs.hump.gamestate"

return function()
  local screenW, screenH = push:getDimensions()

  local fullscreenContainer = require 'myui.elements.container'({
    layout = "vertical",
    w = screenW,
    h = screenH,
    transform_func = function(x, y) return push:toGame(x, y) end
  })

  local menu = require 'myui.elements.container'({
    layout = "vertical",
    w = 400,
    h = 400,
    backgroundColor = {0.2, 0.7, 0.5, 0.1}
  })

  fullscreenContainer:addChild(menu)

  menu:addChild(require 'myui.elements.text'({
    text = "HEXAMOL",
    font = titleFont,
    margin = 20,
    color = { 1, 0.4, 0.2 }
  }))

  menu:addChild(require 'myui.elements.button'(
    {
      w = 200,
      h = 50,
      onClick = function()
        -- Workaround to make sure leave is called in in_game
        local stateTack = Gamestate.getStack()
        if #stateTack > 1 then
          Gamestate.pop()
        end
        Gamestate.switch(require('states.dummy'))
        Gamestate.switch(require('states.in_game'))
      end
end
    })):addChild(require 'myui.elements.text'(
    {
      text = "New Game",
      font = font
    }
    ))

  menu:addChild(require 'myui.elements.button'(
    {
      w = 100,
      h = 50,
      onClick = function()
        love.event.quit()
      end
    })):addChild(require 'myui.elements.text'(
    {
      text = "Quit",
      font = font
    }
    ))

  return fullscreenContainer
end
```