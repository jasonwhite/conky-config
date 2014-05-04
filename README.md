# "Great Circle" Conky Config

This is my [Conky][] configuration. It is purely Lua-drawn and automatically
adjusts to the size of the Conky window.

[Conky]: http://en.wikipedia.org/wiki/Conky_(software)

# Screenshots

Blank background:

![Conky with no background](https://raw.githubusercontent.com/jasonwhite/conky-config/master/greatcircle.png)

Conky on my desktop and with a battery attached:

![Conky with background and battery attached](https://raw.githubusercontent.com/jasonwhite/conky-config/master/greatcircle_bg.png)

# Dependencies

 * Conky with Lua support.
 * Cantarell and Impact fonts.

# Installation

Clone the repository:

    $ git clone https://github.com/jasonwhite/conky-config.git ~/.config/conky

If you don't want to clone it to `~/.config/conky`, you'll have to change this
line in the `greatcircle` file so that it can find the Lua file.

    lua_load ~/.config/conky/greatcircle.lua

# Running It

    $ ~/.config/conky/start

Or

    $ conky -c ~/.config/conky/greatcircle

You may wish to have it started automatically when you log in. To do this, have
the above executed by your window manager or desktop environment on startup.

# Closing It

If all Conky must die, then you should:

    $ killall conky

# Configuration

The size and position of the window is configured in the file `greatcircle`. By
default, it is displayed on the desktop background at a specific size and place.
Other possible arrangements are commented out in the same file.

Settings such as the fonts used, number of CPUs, network interface names, and
time formatting can be configured in `greatcircle.lua`.

# License

MIT License:

    Copyright (c) 2014 Jason White
    
    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
