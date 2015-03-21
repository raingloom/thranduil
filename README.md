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
    * [Methods](#methods)
    * [Basic button drawing](#basic-button-drawing)
  * [Frame](#frame)
    * [Methods](#methods-1)
    * [Basic frame drawing](#basic-frame-drawing)
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

A button is a rectangle that can be pressed. Implements:

* [Base](#base)
* [Draggable](#draggable)
* [Resizable](#resizable)

#### Methods

---

**`new(x, y, w, h, settings):`** creates a new button. The settings table is optional and default values will be used in case some attributes are omitted.

```lua
button = UI.Button(0, 0, 100, 100, {draggable = true})
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

### Checkbox

A checkbox is like a button that can be checked or not. Implements:

* [Base](#base)
* [Draggable](#draggable)
* [Resizable](#resizable)

#### Attributes

| Attribute | Description |
| :-------- | :---------- |
| checked | if the checkbox is checked or not |

#### Methods

---

**`toggle():`** mimicks a checkbox press, changing the checkbox's `checked` state

```lua
function update(dt)
  checkbox:update(dt)
  -- Automatically changes the checkbox's state on hover enter
  if checkbox.enter then checkbox:toggle() end
end
```

---

### Frame

A frame is a container/panel/window that can contain other UI elements. Implements:

* [Base](#base)
* [Closeable](#closeable)
* [Container](#container)
* [Draggable](#draggable)
* [Resizable](#resizable)

#### Methods

---

**`new(x, y, w, h, settings):`** creates a new frame. The settings table is optional and default values will be used in case some attributes are omitted.

```lua
frame = UI.Frame(0, 0, 100, 100, {draggable = true, drag_margin = 10, resizable = true, resize_margin = 5})
```

---

**`addElement(element):`** adds an element to the frame. Elements added must be specified with their positions in relation to the frame's top-left position. The added element is returned.

``` lua
-- the button is drawn at position (5, 5) from the frame's top-left corner
local button = frame:addElement(UI.Button(5, 5, 100, 100))
```

---

### Scrollarea

A scrollarea is an area that can contain other UI elements and that also can be scrolled. Implements:

* [Base](#base)
* [Container](#container)

#### Attributes

| Attribute | Description | Default Value |
| :-------- | :---------- | :------------ |
| area_width | visible scroll area's width | self.w |
| area_height | visible scroll area's height | self.h |
| scroll_button_width | width of all scroll buttons | 15 |
| scroll_button_height | height of all scroll buttons | 15 |
| show_scrollbars | if scrollbars are visible or not, can still scroll even without them visible | |
| horizontal_scrollbar_button | reference to the horizontal scrollbar slider button | |
| horizontal_scrollbar_left_button | reference to the horizontal scrollbar left button | |
| horizontal_scrollbar_right_button | reference to the horizontal scrollbar right button | |
| horizontal_step | horizontal scrolling step in pixels | 5 |
| horizontal_scrolling | if horizontal scrolling is activated | true if area_width < self.w |
| vertical_scrollbar_button | reference to the vertical scrollbar slider button | |
| vertical_scrollbar_top_button | reference to the vertical scrollbar top button | |
| vertical_scrollbar_bottom_button | reference to the vertical scrollbar bottom button | |
| vertical_step | vertical scrolling step in pixels | 5 |
| vertical_scrolling | if vertical scrolling is activated | true if area_height < self.h |

#### Methods

---

**`new(x, y, w, h, settings):`** creates a new scrollarea. The settings table is optional and default values will be used in case some attributes are omitted.

```lua
scrollarea = UI.Scrollarea(0, 0, 200, 200, {area_width = 100, area_height = 100, show_scrollbars = true})
```

---

**`bind(key, action):`** binds a key to a button action. Current actions are:

| Action | Default Key | Description |
| :----- | :---------- | :---------- |
| scroll-left | left | scrolls left by `horizontal_step` pixels |
| scroll-right | right | scrolls right by `horizontal_step` pixels |
| scroll-up | up | scrolls up by `vertical_step` pixels |
| scroll-down | down | scrolls down by `vertical_step` pixels |

---

**`scrollLeft(step):`** mimicks a `scroll-left` action and scrolls by `step` pixels

**`scrollRight(step):`** mimicks a `scroll-right` action and scrolls by `step` pixels

**`scrollUp(step):`** mimicks a `scroll-up` action and scrolls by `step` pixels

**`scrollDown(step):`** mimicks a `scroll-down` action and scrolls by `step` pixels

---

## Mixins

Internally each UI element is composed of multiple mixins (reusable code that's common between elements) as well as specific code that makes that element work. For the purposes of saving documentation space by not repeating the same attributes and methods over multiple objects, I've listed those mixins here, but when using the UI library you probably won't need to care about them. On the [Elements](#elements) section, when an UI element implements Base, Draggable and Resizable for instance, it means that it contains all the attributes and methods of those 3 mixins.

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

---

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

---

**`bind(key, action):`** binds a key to a button action. Current actions are:

| Action | Default Key | Description |
| :----- | :---------- | :---------- |
| focus-next | tab | selects the next child to focus on (sets its `.selected` attribute to true) |
| previous-modifier | lshift | modifier key to be pressed with `focus-next` to focus on the previous child |
| unselect | escape | unselects the currently selected child |

---

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

