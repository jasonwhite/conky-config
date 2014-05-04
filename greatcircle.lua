--[[
    Copyright: (c) 2014 Jason White

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to
    deal in the Software without restriction, including without limitation the
    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
    sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
    IN THE SOFTWARE.

    Author: Jason White
]]

require 'cairo'

--[[
    Configuration settings. Change these if you dare.
]]
local settings = {
    font = {
        -- Font used for small text (e.g., cpu info)
        small = "Cantarell",

        -- Font used for large text (e.g., time)
        large = "Impact",
    },

    cpu = {
        -- Number of CPUs
        count = 4,

        -- Starting and ending angles
        -- 0 and math.pi*2 are at 3:00 on a clock
        angle_start = math.pi * 1.25,
        angle_end   = math.pi * 1.75,
    },

    --[[
        Time formatting.

        If you wish to use a
    ]]
    time = {
        --[[
            Time format (e.g., 12:37 PM)

            If you wish to use 24-hour time, you may need to adjust the font
            and/or font size such that the text below doesn't overlap.
        ]]
        time = "%I:%M %p", -- 12-hour time
        --time = "%H:%M",  -- 24-hour time

        -- Day of the week
        day  = "%A",

        -- Date (e.g., October 16, 2137)
        date = "%B %e, %Y",
    },

    --[[
        List of network interfaces to display.

        You can discover your network interface names by running the "ip link"
        command.

        The number of "lanes" in the ring will automatically adjust to the
        number of network interfaces.

        Outer rings are listed first, inner rings are listed last.
    ]]
    network = {
        "wlo1",
        "eno1",
    },

    -- Battery ID
    battery = 0,
}


--[[
    Draws a ring in the clockwise direction.
]]
local function draw_ring(cr, ring, percentage)
    local sa, ea = ring.start_angle, ring.end_angle

    local t_arc = percentage * (ea - sa)

    cairo_new_sub_path(cr);

    cairo_set_line_width(cr, ring.thickness)

    -- Draw background ring
    if ring.bg then
        cairo_arc(cr, ring.x, ring.y, ring.radius, sa, ea)
        cairo_set_source_rgba(cr, unpack(ring.bg))
        cairo_stroke(cr)
    end

    -- Draw foreground ring
    if ring.fg then
        cairo_arc(cr, ring.x, ring.y, ring.radius, sa, sa + t_arc)
        cairo_set_source_rgba(cr, unpack(ring.fg))
        cairo_stroke(cr)
    end

    cairo_close_path(cr);
end

--[[
    Draws a ring in the counter-clockwise direction.
]]
local function draw_ring_inverse(cr, ring, percentage)
    local sa, ea = ring.start_angle, ring.end_angle

    local t_arc = percentage * (ea - sa)

    cairo_new_sub_path(cr);

    cairo_set_line_width(cr, ring.thickness)

    -- Draw background ring
    if ring.bg then
        cairo_arc_negative(cr, ring.x, ring.y, ring.radius, sa, ea)
        cairo_set_source_rgba(cr, unpack(ring.bg))
        cairo_stroke(cr)
    end

    -- Draw foreground ring
    if ring.fg then
        cairo_arc_negative(cr, ring.x, ring.y, ring.radius, sa, sa + t_arc)
        cairo_set_source_rgba(cr, unpack(ring.fg))
        cairo_stroke(cr)
    end

    cairo_close_path(cr);
end

--[[
    Draws aligned text.
]]
local function draw_text_aligned(cr, text, x, y, x_align, y_align)
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)
    cairo_move_to(cr,
        x - extents.width * x_align,
        y - extents.height * y_align
        );
    cairo_show_text(cr, text);
end

--[[
    Converts a percentage to a suitable color
]]
local function percent_to_color(p, alpha)
    if (p > .25) then
        if (p < .65) then
            return 1, .5, 0, alpha -- Orange
        else
            return 1, 0, 0, alpha -- Red
        end
    else
        return 1, 1, 1, alpha -- Normal
    end
end

--[[
    Useful positions and sizes. This is a table that is created on startup.
]]
local metrics

--[[
    Draws the time widget
]]
local function draw_time_rings(cr)
    local t = os.date("*t");

    local ring = {
        bg          = {.1, .1, .1, 0.1},
        fg          = { .7, .9, 1, .5 },
        x           = metrics.center_x,
        y           = metrics.center_y,
        radius      = metrics.radius - 2,
        thickness   = 4,
        start_angle = -math.pi * 0.5,
        end_angle   = math.pi * 1.5
    }

    -- Draw hours
    draw_ring(cr, ring, (t.hour % 12) / 12);

    -- Draw minutes
    ring.radius = ring.radius - ring.thickness - 2;
    ring.fg[4] = 0.6
    draw_ring(cr, ring, t.min / 60);

    -- Draw seconds
    ring.radius = ring.radius - ring.thickness - 2;
    ring.fg[4] = 0.7
    draw_ring(cr, ring, t.sec / 60);

end

--[[
    Draws the time text
]]
local function draw_time_display(cr)
    local time = os.date(settings.time.time);
    local day  = os.date(settings.time.day);
    local date = os.date(settings.time.date);

    local extents = cairo_text_extents_t:create()

    -- Set the time font
    cairo_select_font_face(cr, settings.font.large, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, 56);

    -- Get the size of the time text
    cairo_text_extents(cr, time, extents)

    local time_w = extents.width;

    -- Center horizontally
    local time_x = metrics.center_x - time_w / 2
    local time_y = metrics.center_y

    -- Draw the text
    cairo_set_source_rgba(cr, 1, 1, 1, 0.7);
    cairo_move_to(cr, time_x, time_y);
    cairo_show_text(cr, time);

    -- Set the day/date font
    cairo_select_font_face(cr, settings.font.small, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
    cairo_set_font_size(cr, 15);

    -- Get the size of the day text
    cairo_text_extents(cr, day, extents)

    local day_x = time_x + 4
    local day_y = time_y + extents.height + 2

    -- Draw the day
    cairo_set_source_rgb(cr, 0.01, 0.75, 1)
    cairo_move_to(cr, day_x, day_y)
    cairo_show_text(cr, day)

    -- Get the size of the date text
    cairo_text_extents(cr, date, extents)

    -- Right-align the date under the time
    local date_x = time_x + time_w - extents.width
    local date_y = time_y + extents.height + 2

    -- Draw the date
    cairo_move_to(cr, date_x, date_y)
    cairo_show_text(cr, date)
end

--[[
    Draws a single CPU widget at the specified coordinates.

    The ID is a number starting at 1 for each CPU.
]]
local function draw_cpu_widget(cr, x, y, id)
    local ring = {
        bg          = { 1, 1, 1, 0.2 },
        x           = x,
        y           = y,
        radius      = 32,
        thickness   = 10,
        start_angle = -math.pi * 1.3,
        end_angle   = math.pi * 0.3
    }

    local usage = tonumber(conky_parse("${cpu cpu".. id .."}")) or 0
    local percent = usage/100

    ring.fg = { percent_to_color(percent, 0.8) }

    draw_ring(cr, ring, percent);

    -- Draw the CPU ID
    cairo_select_font_face(cr, settings.font.small, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
    cairo_set_font_size(cr, 10);
    cairo_set_source_rgb(cr, .8, .8, .8);

    -- Draw the name
    draw_text_aligned(cr, "CPU " .. id, x, y - 4, 0.5, 0.5)

    -- Draw the CPU frequency
    draw_text_aligned(cr,
        conky_parse("${freq_g ".. id .."}") .. " GHz",
        x, y, 0.5, -0.5
        )

    -- Draw the percentage
    draw_text_aligned(cr, usage .. "%", x, y + ring.radius, 0.5, 0)
end

--[[
    Draws all CPU widgets at pre-computed coordinates.
]]
local function draw_cpu_widgets(cr, cpus)
    for k,v in pairs(cpus) do
        draw_cpu_widget(cr, v.x, v.y, k)
    end
end

--[[
    Calculate the positions for the CPU widgets
]]
local function get_cpus()
    local cpus = {}

    --local angle_start = math.pi*.5 - settings.cpu_spread/2
    --local angle_end = math.pi*0.5 + settings.cpu_spread/2
    local angle_start = settings.cpu.angle_start
    local angle_end   = settings.cpu.angle_end
    local angle_inc   = (angle_end - angle_start) / (settings.cpu.count-1)
    local angle       = angle_start -- current angle
    local length      = metrics.radius - 84

    for i=1, settings.cpu.count do
        table.insert(cpus, {
            x = length * math.cos(angle) + metrics.center_x,
            y = length * math.sin(angle) + metrics.center_y,
        })
        angle = angle + angle_inc
    end

    return cpus;
end

-- High watermarks for each network interface
local network_max = {}

--[[
    Draws single network ring. This includes the upload and download speeds.
]]
local function draw_network_ring(cr, interface, radius, thickness)
    local ring = {
        bg          = { 1, 1, 1, 0.2 },
        x           = metrics.center_x,
        y           = metrics.center_y,
        radius      = radius,
        thickness   = thickness,
        start_angle = -math.pi * 0.98,
        end_angle   = -math.pi * 0.52
    }

    local rate_up = tonumber(conky_parse("${upspeedf ".. interface .."}"))
    local rate_down = tonumber(conky_parse("${downspeedf ".. interface .."}" ))

    -- Calculate high water marks
    local max = network_max[interface]
    if not max then
        max = {1, 1}
    end

    max[1] = math.max(max[1], rate_up)
    max[2] = math.max(max[1], rate_down)
    network_max[interface] = max

    -- Upload speed bar
    local p = rate_up / max[1]
    ring.fg = { percent_to_color(p, .8) }
    draw_ring(cr, ring, p);

    -- Download speed bar
    local p = rate_down / max[2]
    ring.fg = { percent_to_color(p, .8) }
    ring.start_angle = -math.pi * 0.02
    ring.end_angle   = -math.pi * 0.48
    draw_ring_inverse(cr, ring, p);
end

--[[
    Draws all network rings.
]]
local function draw_network_rings(cr)
    local group_radius = 130
    local group_thickness = 12
    local spacing = 1

    local interfaces = settings.network
    local n = #interfaces

    if n == 0 then
        return
    end

    local thickness = (group_thickness - spacing*(n - 1))/n

    -- Starting radius
    local radius = group_radius + (group_thickness - thickness) * .5

    -- Draw the first ring
    draw_network_ring(cr, interfaces[1], radius, thickness)

    for i=2, n do
        radius = radius - thickness - spacing
        draw_network_ring(cr, interfaces[i], radius, thickness)
    end
end

--[[
    Draws the memory ring.
]]
local function draw_memory_ring(cr)
    local ring = {
        bg          = { 1, 1, 1, 0.2 },
        fg          = { 1, 1, 1, 0.8 },
        x           = metrics.center_x,
        y           = metrics.center_y,
        radius      = 130,
        thickness   = 12,
        start_angle = math.pi * 0.02,
        end_angle   = math.pi * 0.98,
    }

    local p = (tonumber(conky_parse("${memperc}")) or 0) /100

    draw_ring(cr, ring, p);
end

-- Nice battery status names.
local battery_state = {
    C = "Charging",
    D = "Discharging",
    F = "Full",
    E = "Empty",

    -- The battery ring should not be displayed if this is the case.
    --N = "Not Present",
    --U = "Unknown",
}

--[[
    Draws the battery ring and charge percentage.
]]
local function draw_battery_widget(cr)
    local state = battery_state[conky_parse("${battery_short}"):sub(1,1)]
    if not state then
        return
    end

    local ring = {
        fg          = { 1, 0, 0, 1 },
        x           = metrics.center_x,
        y           = metrics.center_y,
        radius      = metrics.radius - 22,
        thickness   = 4,
        start_angle = math.pi * -0.5,
        end_angle   = math.pi * 1.5,
    }

    local battery = conky_parse("${battery_percent}")
    local p = tonumber(battery)/100

    if p > .5 then
        if p > .75 then
            ring.fg = { 0, 1, 0, 1 }
        else
            ring.fg = { 1, 1, 0, 1 }
        end
    else
        if p > .25 then
            ring.fg = { 1, .5, 0, 1 }
        else
            ring.fg = { 1, 0, 0, 1 }
        end
    end

    draw_ring(cr, ring, p);

    cairo_select_font_face(cr, settings.font.large, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, 40);
    cairo_set_source_rgba(cr, 1, 1, 1, .7);

    local y = metrics.center_y + metrics.radius

    draw_text_aligned(cr, battery .. "%",
        metrics.center_x,
        y - 62, .5, 0
        )

    cairo_select_font_face(cr, settings.font.small, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
    cairo_set_font_size(cr, 12);
    cairo_set_source_rgb(cr, 0.01, 0.75, 1);

    draw_text_aligned(cr, state,
        metrics.center_x,
        y - 60, .5, -1
        )
end

local cpus;

-- Called when the window size changes
local function invalidate()
    metrics = {
        width    = conky_window.width,
        height   = conky_window.height,
        center_x = conky_window.width * .5,
        center_y = conky_window.height * .5,
        radius   = math.min(conky_window.width, conky_window.height) * .5
    }

    cpus = get_cpus()
end

function conky_main()
    if conky_window == nil then
        return
    end

    -- Window size change?
    if (not metrics or
        metrics.width ~= conky_window.width or
        metrics.height ~= conky_window.height
        ) then
        print("Window invalidated")
        invalidate()
    end

    -- Create a surface to draw on.
    local cs = cairo_xlib_surface_create(
        conky_window.display,
        conky_window.drawable,
        conky_window.visual,
        conky_window.width,
        conky_window.height
        )
    local cr = cairo_create(cs)

    -- Draw all the widgets
    draw_network_rings(cr)
    draw_memory_ring(cr)
    draw_battery_widget(cr)
    draw_cpu_widgets(cr, cpus)
    draw_time_rings(cr)
    draw_time_display(cr)

    -- Cleanup
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
