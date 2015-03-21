# Thranduil - WIP

A UI module for LÖVE. Facilitates the creation of game specific UI through UI elements that have all 
their logic abstracted away (anything having to do with input and the element's state), leaving you with the job of specifying how those elements will be drawn.

## Usage

Require the [module](https://github.com/adonaac/thranduil/blob/master/ui/UI.lua):

```lua
UI = require 'ui/UI'
```

And register it to most of LÖVE's callbacks:

```lua
function love.load()
  UI.registerEvents()
end
```

## Table of Contents

* [Introduction](#introduction)
* [Elements](#elements)
  * [Button](#button)
    * [Base attributes](#base-attributes)
    * [Methods](#methods)
    * [Basic button drawing](#basic-button-drawing)
  * [Frame](#frame)
    * [Base attributes](#base-attributes-1)
    * [Close attributes](#close-attributes)
    * [Drag attributes](#drag-attributes)
    * [Resize attributes](#resize-attributes)
    * [Methods](#methods-1)
    * [Basic frame drawing](#basic-frame-drawing)
  * [Textinput](#textinput)
    * [Base attributes](#base-attributes-2)
    * [Text attributes](text-attributes)
    * [Methods](#methods-2)
    * [Basic textinput drawing](#basic-textinput-drawing)
* [Mixins](#mixins)
  * [Base](#base)
    * [Attributes](#base-attributes)
    * [Methods](#base-methods)
  * [Closeable](#closeable)
    * [Attributes](#closeable-attributes)
  * [Container](#container)
    * [Attributes](#container-attributes)
    * [Methods](#container-methods)
  * [Draggable](#draggable)
    * [Attributes](#draggable-attributes)
    * [Methods](#draggable-methods)
  * [Resizable](#resizable)
    * [Attributes](#resizable-attributes)
* [Extensions](#extensions)
* [Themes](#themes)

## Introduction

For this example we'll create a button object at position `(10, 10)` with width/height `(90, 90)`:

```lua
button = UI.Button(10, 10, 90, 90)
```

This object can then be updated via `button:update(dt)` and it will automatically have its attributes changed as the user hovers, selects or presses it. Drawing however is handled by you, which means that the button's draw function has to be defined. 

This function will use the object's attributes to change how it looks under different states. The UI module is designed in this way so that you can have absolute control over how each UI element looks, which means that integration with a game (which usually needs random UI elements in the most unexpected places) is as straightforward as working with any other game object.

The way in which draw functions are added to objects is explained in the [Extensions](#extensions) section.

```lua
Theme.Button.draw = function(self)
  love.graphics.setColor(64, 64, 64)
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  if self.down then
    love.graphics.setColor(32, 32, 32)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  end
  love.graphics.setColor(255, 255, 255)
end
```

## Elements

### Button

<p align="center">
  <img src="https://github.com/adonaac/thranduil/blob/master/images/button.png?raw=true" alt="button"/>
</p>

A button is a rectangle that can be pressed. Implements:

* [Base](#base)
* [Draggable](#draggable)
* [Resizable](#resizable)

```lua
function init()
  button = UI.Button(0, 0, 100, 100)
end

function update(dt)
  button:update(dt)
  if button.pressed then print('button was pressed!') end
  if button.released then print('button was released!') end
  if button.down then print('button is down!') end
end
```

#### Methods

---

**`new(x, y, w, h, settings):`** creates a new button. The settings table is optional, see [Extensions](#extensions).

```lua
button = UI.Button(0, 0, 100, 100)
```

---

**`press():`** mimicks a button press, setting `pressed` and `released` to true for one frame.

```lua
function update(dt)
  button:update(dt)
  -- Automatically presses the button whenever the mouse hovers over it
  if button.enter then button:press() end
end
```

---

### Frame

<p align="center">
  <img src="https://github.com/adonaac/thranduil/blob/master/images/frame.png?raw=true" alt="button"/>
</p>

A frame is a container/panel/window that can contain other UI elements. Implements:

* [Base](#base)
* [Closeable](#closeable)
* [Container](#container)
* [Draggable](#draggable)
* [Resizable](#resizable)

```lua
function init()
  frame = UI.Frame(0, 0, 100, 100)
end

function update(dt)
  frame:update(dt)
  if frame.enter then print('Focused element #: ' .. frame.currently_focused_element) end
  if frame.exit then print('# of elements: ' .. #frame.elements) end
  if frame.selected then print('frame is being interacted with!') end
end
```

#### Close attributes

* If the `closeable` attribute is not set, then the close button logic for this frame won't happen. 
* If `closed` is set to true then the frame won't update nor be drawn. 
* The close button's theme is inherited from the frame by default, but can be changed via `frame.close_button.theme`.
* Default values are set if the attribute is omitted on the settings table on this frame's creation.

| Attribute | Description | Default Value |
| :-------- | :---------- | :------------ |
| closeable | if this frame can be closed or not | false |
| closed | if the frame is closed or not | false |
| closing | if the close button is being held down | |
| close_margin | top-right margin for close button | 5 |
| close_button_width | width of the close button | 10 |
| close_button_height | height of the close button | 10 |
| close_button | a reference to the close button | |

```lua
function init()
  frame = UI.Frame(0, 0, 100, 100, {closeable = true, close_margin = 10, 
                                    close_button_width = 10, close_button_height = 10})
end

function update(dt)
  frame:update(dt)
  if frame.close_button.pressed then print('close button pressed!') end
  if frame.closed then print('the frame is closed!') end
  if not frame.closed then print('the frame is not closed!') end
  frame.closed = not frame.closed
end
```

#### Drag attributes

* If the `draggable` attribute is not set, then the dragging logic for this frame won't happen. 
* Default values are set if the attribute is omitted on the settings table on this frame's creation.

| Attribute | Description | Default Value |
| :-------- | :---------- | :------------ |
| draggable | if this frame can be dragged or not | false |
| dragging | if this frame is being dragged | |
| drag_margin | top margin for drag bar | self.h/5 |
| drag_hot | true if the mouse is over this frame's drag area (inside its x, y, w, h rectangle) | |
| drag_enter | true on the frame the mouse enters this frame's drag area | |
| drag_exit | true on the frame the mouse exits this frame's exit area | |

```lua
function init()
  frame = UI.Frame(0, 0, 100, 100, {draggable = true, drag_margin = 20})
end

function update(dt)
  frame:update(dt)
  if frame.dragging then print('frame being dragged!') end
end
```

#### Resize attributes

* If the `resizable` attribute is not set, then the resizing logic for this frame won't happen. 
* Default values are set if the attribute is omitted on the settings table on this frame's creation.

| Attribute | Description | Default Value |
| :-------- | :---------- | :------------ |
| resizable | if this frame can be resized or not | false |
| resizing | if this frame is being resized | |
| resize_margin | top-left-bottom-right margin for resizing | 6 |
| resize_hot | true if the mouse is over this frame's resize area | |
| resize_enter | true on the frame the mouse enters this frame's resize area | |
| resize_exit | true on the frame the mouse exits this frame's resize area | |
| min_width | minimum frame width | 20 |
| min_height | minimum frame height | self.h/5 |

```lua
function init()
  frame = UI.Frame(0, 0, 100, 100, {resizable = true, resize_margin = 10, 
                                    min_width = 100, min_height = 100})
end

function update(dt)
  frame:update(dt)
  if frame.resizing then print('frame being resized!') end
end
```

#### Methods

---

**`new(x, y, w, h, settings):`** creates a new frame. The settings table is optional and default values will be used in case some attributes are omitted.

```lua
frame = UI.Frame(0, 0, 100, 100, {draggable = true, resizable = true})
```

---

**`addElement(element):`** adds an element to the frame. Elements added must be specified with their positions in relation to the frame's top-left position. An `element_id` number is returned which can then be used with the `getElement` function to get a reference to an element inside a frame.

``` lua
-- the button is drawn at position (5, 5) from the frame's top-left corner
local button_id = frame:addElement(UI.Button(5, 5, 100, 100))
```

---

#### Basic frame drawing

```lua
frame.draw = function(self)
  -- Draw frame
  love.graphics.setColor(64, 64, 64)
  if self.hot then love.graphics.setColor(96, 96, 96) end
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  
  -- Draw resize border
  if self.resizable then
    love.graphics.setColor(32, 32, 32)
    if self.resize_hot then love.graphics.setColor(64, 64, 64) end
    if self.resizing then love.graphics.setColor(48, 48, 48) end
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.resize_margin)
    love.graphics.rectangle('fill', self.x, self.y + self.h - self.resize_margin, self.w, self.resize_margin)
    love.graphics.rectangle('fill', self.x, self.y, self.resize_margin, self.h)
    love.graphics.rectangle('fill', self.x + self.w - self.resize_margin, self.y, self.resize_margin, self.h)
  end
  
  -- Draw drag bar
  if self.draggable then
    love.graphics.setColor(32, 32, 32)
    if self.drag_hot then love.graphics.setColor(64, 64, 64) end
    if self.dragging then love.graphics.setColor(48, 48, 48) end
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.drag_margin)
  end
end
```

### Textinput

<p align="center">
  <img src="https://github.com/adonaac/thranduil/blob/master/images/textinput.png?raw=true" alt="button"/>
</p>

A textinput is an UI element you can write to. It's a single line of text (not to be confused with a [Textarea](#textarea)) and supports scrolling, copying, deleting, pasting and selecting of text.

#### Base attributes

| Attribute | Description |
| :-------- | :---------- |
| x, y | the textinput's top-left position |
| w, h | the textinput's width and height |
| hot | true if the mouse is over this textinput (inside its x, y, w, h rectangle) |
| selected | true if the textinput is currently selected (if its being interacted with or selected with TAB) |
| pressed | true on the frame the textinput was pressed |
| down | true when the textinput is being held down after being pressed |
| released | true on the frame the textinput was released |
| enter | true on the frame the mouse enters this button's area |
| exit | true on the frame the mouse exits this button's area |
| selected_enter | true on the frame the button enters selection |
| selected_exit | true on the frame the button exists selection |

```lua
function init()
  textinput = UI.Textinput(0, 0, 100, 100)
end

function update(dt)
  textinput:update(dt)
  if frame.selected_enter then print('textinput selected!') end
  if frame.selected_exit then print('textinput unselected!') end
end
```

#### Text attributes

* Default values are set if the attribute is omitted on the settings table on this textinput's creation.

| Attribute | Description | Default Value |
| :-------- | :---------- | :------------ |
| text | the text as a string | |
| text_x, text_y | text's top-left position | |
| text_margin | top-left margin for the text | 5 |
| text_max_length | maximum number of characters this textinput holds | |
| selection_position.x, .y | selection's top-left position | |
| selection_size.w, .h | selection's width and height | |
| index | textinput's cursor index | |
| select_index | if text is being selected, textinput's second cursor index, otherwise nil| |
| string | the text string but represented as a table of characters | |
| font | the font to be used for this textinput object | currently set font |

```lua
function init()
  textinput = UI.Textinput(0, 0, 100, 100, {text_margin = 10, text_max_length = 10})
end

function update(dt)
  textinput:update(dt)
  print('text x, y: ', textinput.text_x, textinput.text_y)
  print('cursor index: ', textinput.index)
  print('before cursor character: ', textinput.string[textinput.index-1])
  if textinput.select_index then
    print('text being selected: ', textinput.text:sub(textinput.index, textinput.select_index-1))
  end
end
```

#### Methods

---

**`new(x, y, w, h, settings):`** creates a new textinput. The settings table is optional and default values will be used in case some attributes are omitted.

```lua
textinput = UI.Textinput(0, 0, 100, 100, {font = love.graphics.newFont('.ttf', 24)})
```

---

**`backspace()`** mimicks a `backspace` action and deletes the character before the cursor.

---

**`bind(key, action):`** binds a key to a button action. Current actions are:

| Action | Default Key | Description |
| :----- | :---------- | :---------- |
| left-click | mouse1 | mouse's left click |
| move-left | left | moves the cursor to the left once |
| move-right | right | moves the cursor to the right once |
| first | up | moves the cursor to the start of the text |
| last | down | moves the cursor to the end of the text |
| lshift | lshift | shift modifier |
| backspace | backspace | deletes before the cursor |
| delete | delete | deletes after the cursor |
| lctrl | lctrl | ctrl modifier |
| cut | x | cuts the selected text with `lctrl + cut` |
| copy | c | copies the selected text with `lctrl + copy` |
| paste | p | pastes the copied or cut text with `lctrl + paste` |
| all | a | selects all text with `lctrl + all` |

```lua
-- makes it so that lctrl + m selects all text instead of lctrl + a
textinput:bind('m', 'all')
```

---

**`copySelected():`** mimicks a `lctrl + copy` action and copies the selected text.

---

**`cutSelected():`** mimicks a `lctrl + cut` action and cuts the selected text.

---

**`delete():`** mimicks a `delete` action and deletes the text after the cursor.

---

**`deleteSelected():`** deletes all selected text.

---

**`destroy():`** destroys the textinput. Nilling a UI element won't remove it from memory because the UI module also keeps a reference of each object created with it.

```lua
-- won't remove the textinput object from memory
textinput = nil

-- removes the textinput object from memory
textinput:destroy()
textinput = nil
```

---

**`first():`** mimicks a `first` action and moves the cursor to the first character of the text.

---

**`last():`** mimicks a `last` action and moves the cursor to the last character of the text.

---

**`moveLeft():`** mimicks a `move-left` action and moves the cursor one character to the left.

---

**`moveRight():`** mimicks a `move-right` action and moves the cursor one character to the right.

---

**`pasteCopyBuffer():`** mimicks a `lctrl + paste` action and pastes copied or cut text.

---

**`selectAll():`** mimicks a `lctrl + all` action and selects all characters.

---

**`selectLeft():`** mimicks a `lshift + move-left` action and selects one character to the left.

---

**`selectAll():`** mimicks a `lshift + move-right` action and selects one character to the right.

---

**`setText(text):`** sets the textinput's text.

---

**`textinput(character)`** mimicks a normal key input press and adds a single character to the text.

---

#### Basic textinput drawing

```lua
textinput.draw = function(self)
    local font = love.graphics.getFont()
    love.graphics.setFont(self.font)

    -- Draw textinput background
    love.graphics.setColor(32, 32, 32)
    if self.hot then love.graphics.setColor(64, 64, 64) end
    if self.selected then love.graphics.setColor(48, 48, 48) end
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)

    -- Set scissor
    love.graphics.setScissor(self.x, self.y, self.w - self.text_margin, self.h)

    -- Draw text
    love.graphics.setColor(128, 128, 128)
    love.graphics.print(self.text, self.text_x, self.text_y)

    -- Draw selection
    love.graphics.setColor(192, 192, 192, 64)
    if self.selection_position and self.selected then
        love.graphics.rectangle('fill', 
                                self.selection_position.x, self.selection_position.y, 
                                self.selection_size.w, self.selection_size.h)
    end

    -- Unset stuff 
    love.graphics.setScissor()
    love.graphics.setFont(font)
    love.graphics.setColor(255, 255, 255, 255)
end
```

## Mixins

Internally each UI element is composed of multiple mixins (reusable code that's common between elements) as well as specific code that makes that element work. For the purposes of saving documentation space by not repeating the same attributes and methods over multiple objects, I've listed those mixins here, but when using the UI library you probably won't need to care about them. On the [Elements](#elements) section, when an UI element implements Base, Draggable and Resizable for instance, it means that it contains all the attributes and methods of those 3 mixins.

---

### Base

Base mixin that gives core functionality to all UI elements.

#### Attributes

| Attribute | Description |
| :-------- | :---------- |
| x, y | the element's top-left position |
| w, h | the element's width and height |
| hot | true if the mouse is over this element (inside its x, y, w, h rectangle) |
| selected | true if the element is currently selected (if its being interacted with or selected with TAB) |
| pressed | true on the frame the element was pressed |
| down | true when the element is being held down after being pressed |
| released | true on the frame the element was released |
| enter | true on the frame the mouse enters this element's area |
| exit | true on the frame the mouse exits this element's area |
| selected_enter | true on the frame the element enters selection |
| selected_exit | true on the frame the element exists selection |

#### Methods

**`bind(key, action):`** binds a key to a button action. Current actions are:

| Action | Default Key | Description |
| :----- | :---------- | :---------- |
| left-click | mouse1 | mouse's left click |
| key-enter | return | activation key, enter |

---

### Closeable

Makes it so that a UI element has a close button and that it can be closed.

#### Attributes

* If the `closeable` attribute is not set to true, then the close button logic for this element won't happen. 
* If `closed` is set to true then the frame won't update nor be drawn. 
* Default values are set if the attribute is omitted on the settings table on this element's creation.

| Attribute | Description | Default Value |
| :-------- | :---------- | :------------ |
| closeable | if this element can be closed or not | false |
| closed | if the element is closed or not | false |
| close_margin | top-right margin for close button | 5 |
| close_button_width | width of the close button | 10 |
| close_button_height | height of the close button | 10 |
| close_button_extensions | the extensions to be used for the close button | |
| close_button | a reference to the close button | |

---

### Container

Adds the ability for an UI element to contain other UI elements.

#### Attributes

| Attribute | Description | Default Value |
| :-------- | :---------- | :------------ |
| elements | a table holding all children inside this element | {} |
| currently_focused_element | index of the child that is currently focused | |
| any_selected | if any child is selected or not | false |

#### Methods

**`bind(key, action):`** binds a key to a button action. Current actions are:

| Action | Default Key | Description |
| :----- | :---------- | :---------- |
| focus-next | tab | selects the next child to focus on (sets its `.selected` attribute to true) |
| previous-modifier | lshift | modifier key to be pressed with `focus-next` to focus on the previous child |
| unselect | escape | unselects the currently selected child |

**`focusNext():`** mimicks a `focus-next` action and focuses on the next child

**`focusPrevious():`** mimicks a `focus-previous` action and focuses on the previous child

**`unselect():`** mimicks a `unselect` action and unselects the currently focused child

---

### Draggable

#### Attributes

* If the `draggable` attribute is not set to true, then the dragging logic for this element won't happen. 
* Default values are set if the attribute is omitted on the settings table on this element's creation.

| Attribute | Description | Default Value |
| :-------- | :---------- | :------------ |
| draggable | if this element can be dragged or not | false |
| drag_margin | top margin for drag bar | self.h/5 |
| drag_hot | true if the mouse is over this element's drag area (inside its x, y, w, h rectangle) | |
| drag_enter | true on the frame the mouse enters this element's drag area | |
| drag_exit | true on the frame the mouse exits this element's exit area | |
| drag_min_limit_x, y | minimum x, y limit this element can be dragged to | |
| drag_max_limit_x, y | maximum x, y limit this element can be dragged to | |
| only_drag_horizontally | only drags the element horizontally | |
| only_drag_vertically | only drags the element vertically | |

#### Methods

**`setDragLimits(x_min, y_min, x_max, y_max):`** sets this element's drag limits

```lua
-- Makes it so that the element can't be dragged below x = 100 and above x = 400
element:setDragLimits(100, nil, 400, nil)
```

---

### Resizable

Makes it so that this UI element can be resized with the mouse (by dragging its borders).

#### Attributes

* If the `resizable` attribute is not set to true, then the resizing logic for this element won't happen. 
* Default values are set if the attribute is omitted on the settings table on this element's creation.

| Attribute | Description | Default Value |
| :-------- | :---------- | :------------ |
| resizable | if this element can be resized or not | false |
| resize_margin | top-left-bottom-right margin for resizing | 6 |
| resize_hot | true if the mouse is over this element's resize area | |
| resize_enter | true on the frame the mouse enters this element's resize area | |
| resize_exit | true on the frame the mouse exits this element's resize area | |
| min_width | minimum element width | 20 |
| min_height | minimum element height | self.h/5 |

## Extensions

