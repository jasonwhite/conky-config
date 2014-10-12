# "Great Circle" Conky Config

This is my [Conky][] configuration. It is purely Lua-drawn and automatically
adjusts to the size of the Conky window.

[Conky]: http://en.wikipedia.org/wiki/Conky_(software)

# Features

 * Displays:
    - Current time and date.
    - CPU usage.
    - Memory usage.
    - Network usage over multiple interfaces.
    - Battery charge and charging state.
 * Auto-detects the number of CPU cores and network interfaces.
 * Highly configurable, but should work with little to no configuration.

# Screenshots

Conky with some CPU and network usage:

![Conky](https://raw.githubusercontent.com/jasonwhite/conky-config/master/greatcircle.png)

Conky with a battery attached and charging:

![Conky with battery](https://raw.githubusercontent.com/jasonwhite/conky-config/master/greatcircle_battery.png)

# Dependencies

 * Conky with Lua support and Cairo bindings.
 * Cantarell and Impact fonts.

To be sure that your Conky installation has both Lua support and Cairo bindings,
check the output of `conky --version`.
```bash
$ conky --version
 General:
  * Lua

 Lua bindings:
  * Cairo
```
*Note that irrelevant output has been removed.*

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
default, it is displayed on the desktop background in the top left corner.
Other possible arrangements are commented out in the same file.

Settings such as the fonts used, colors, number of CPUs, network interface
names, and time formatting can be configured in `greatcircle.lua`.

# Trouble Shooting?

It's okay, we all have trouble shooting sometimes.

## Missing Cairo Lua bindings

If you get an error that the `cairo` Lua package cannot be found then be sure
that your version of Conky has Cairo bindings for Lua. The output of

    $ conky -v

should contain:

    Lua bindings:
     * Cairo

On Arch Linux, the official `conky` package does not include Cairo bindings.
You'll have to install the `lua-conky` package from the AUR instead.


## Black background without a compositor

If you are not using a compositor such Compiz or Xcompmgr, you need to change a
setting in the file `greatcircle`. Change

    own_window_argb_visual yes

to:

    own_window_argb_visual no

This will disable true transparency. Instead, Conky will perform its own
blending with the desktop background image.

Be sure to completely restart Conky after making the change.

## Known Working Setup

I have primarily tested this on [ArchLinux][] using the following packages:

 * [i3](http://i3wm.org/) (window manager)
 * [xcompmgr](https://wiki.archlinux.org/index.php/xcompmgr) (for compositing)
 * [conky-lua-nv](https://aur.archlinux.org/packages/conky-lua-nv/) (Conky with Lua and Cairo support)

[ArchLinux]: https://www.archlinux.org/

# More Information

 * [Conky Documentation](http://conky.sourceforge.net/documentation.html)
 * [Arch Linux Conky Wiki Page](https://wiki.archlinux.org/index.php/Conky)
 * [Ubuntu Help Page](https://help.ubuntu.com/community/SettingUpConky)

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
