﻿NDSummary.OnToolTipsLoaded("LuaClass:Extensions.Color",{45:"<div class=\"NDToolTip TClass LLua\"><div class=\"TTSummary\">Color related functions and metatable extensions.</div></div>",47:"<div class=\"NDToolTip TShared LLua\"><div id=\"NDPrototype47\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><div class=\"PParameterCells\" data-WideColumnCount=\"3\" data-NarrowColumnCount=\"2\"><div class=\"PBeforeParameters\" data-WideGridArea=\"1/1/3/2\" data-NarrowGridArea=\"1/1/2/3\" style=\"grid-area:1/1/3/2\"><span class=\"SHKeyword\">function</span> ColorToHex(</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"1/2/2/3\" data-NarrowGridArea=\"2/1/3/2\" style=\"grid-area:1/2/2/3\">color,</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"2/2/3/3\" data-NarrowGridArea=\"3/1/4/2\" style=\"grid-area:2/2/3/3\">alpha</div><div class=\"PAfterParameters NegativeLeftSpaceOnWide\" data-WideGridArea=\"2/3/3/4\" data-NarrowGridArea=\"4/1/5/3\" style=\"grid-area:2/3/3/4\">)</div></div></div></div><div class=\"TTSummary\">Returns the hexidecimal color string for a color object. This will be in the format #RRGGBB or #RRGGBBAA depending on the value of the second argument.</div></div>",48:"<div class=\"NDToolTip TShared LLua\"><div id=\"NDPrototype48\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><div class=\"PParameterCells\" data-WideColumnCount=\"3\" data-NarrowColumnCount=\"2\"><div class=\"PBeforeParameters\" data-WideGridArea=\"1/1/2/2\" data-NarrowGridArea=\"1/1/2/3\" style=\"grid-area:1/1/2/2\"><span class=\"SHKeyword\">function</span> HexToColor(</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"1/2/2/3\" data-NarrowGridArea=\"2/1/3/2\" style=\"grid-area:1/2/2/3\">hex</div><div class=\"PAfterParameters\" data-WideGridArea=\"1/3/2/4\" data-NarrowGridArea=\"3/1/4/3\" style=\"grid-area:1/3/2/4\">)</div></div></div></div><div class=\"TTSummary\">Translates a hex string to a color object. This handles the following formats: #RGB #RGBA #RRGGBB #RRGGBBAA</div></div>",49:"<div class=\"NDToolTip TShared LLua\"><div id=\"NDPrototype49\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><div class=\"PParameterCells\" data-WideColumnCount=\"3\" data-NarrowColumnCount=\"2\"><div class=\"PBeforeParameters\" data-WideGridArea=\"1/1/3/2\" data-NarrowGridArea=\"1/1/2/3\" style=\"grid-area:1/1/3/2\"><span class=\"SHKeyword\">function</span> NamedColor(</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"1/2/2/3\" data-NarrowGridArea=\"2/1/3/2\" style=\"grid-area:1/2/2/3\">name,</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"2/2/3/3\" data-NarrowGridArea=\"3/1/4/2\" style=\"grid-area:2/2/3/3\">alpha</div><div class=\"PAfterParameters\" data-WideGridArea=\"2/3/3/4\" data-NarrowGridArea=\"4/1/5/3\" style=\"grid-area:2/3/3/4\">)</div></div></div></div><div class=\"TTSummary\">Creates a new color based off of a named color from the CSS color specification.</div></div>",51:"<div class=\"NDToolTip TShared LLua\"><div id=\"NDPrototype51\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><div class=\"PParameterCells\" data-WideColumnCount=\"3\" data-NarrowColumnCount=\"2\"><div class=\"PBeforeParameters\" data-WideGridArea=\"1/1/4/2\" data-NarrowGridArea=\"1/1/2/3\" style=\"grid-area:1/1/4/2\"><span class=\"SHKeyword\">function</span> HSVToColor(</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"1/2/2/3\" data-NarrowGridArea=\"2/1/3/2\" style=\"grid-area:1/2/2/3\">hue,</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"2/2/3/3\" data-NarrowGridArea=\"3/1/4/2\" style=\"grid-area:2/2/3/3\">saturation,</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"3/2/4/3\" data-NarrowGridArea=\"4/1/5/2\" style=\"grid-area:3/2/4/3\">value</div><div class=\"PAfterParameters NegativeLeftSpaceOnWide\" data-WideGridArea=\"3/3/4/4\" data-NarrowGridArea=\"5/1/6/3\" style=\"grid-area:3/3/4/4\">)</div></div></div></div><div class=\"TTSummary\">HSVToColor now returns a color with the correct metatable set.</div></div>",52:"<div class=\"NDToolTip TShared LLua\"><div id=\"NDPrototype52\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><div class=\"PParameterCells\" data-WideColumnCount=\"3\" data-NarrowColumnCount=\"2\"><div class=\"PBeforeParameters\" data-WideGridArea=\"1/1/4/2\" data-NarrowGridArea=\"1/1/2/3\" style=\"grid-area:1/1/4/2\"><span class=\"SHKeyword\">function</span> HSLToColor(</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"1/2/2/3\" data-NarrowGridArea=\"2/1/3/2\" style=\"grid-area:1/2/2/3\">hue,</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"2/2/3/3\" data-NarrowGridArea=\"3/1/4/2\" style=\"grid-area:2/2/3/3\">saturation,</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"3/2/4/3\" data-NarrowGridArea=\"4/1/5/2\" style=\"grid-area:3/2/4/3\">lightness</div><div class=\"PAfterParameters NegativeLeftSpaceOnWide\" data-WideGridArea=\"3/3/4/4\" data-NarrowGridArea=\"5/1/6/3\" style=\"grid-area:3/3/4/4\">)</div></div></div></div><div class=\"TTSummary\">HSLToColor now returns a color with the correct metatable set.</div></div>",54:"<div class=\"NDToolTip TShared LLua\"><div id=\"NDPrototype54\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><div class=\"PParameterCells\" data-WideColumnCount=\"3\" data-NarrowColumnCount=\"2\"><div class=\"PBeforeParameters\" data-WideGridArea=\"1/1/2/2\" data-NarrowGridArea=\"1/1/2/3\" style=\"grid-area:1/1/2/2\"><span class=\"SHKeyword\">function</span> meta:GetHex(</div><div class=\"PName InFirstParameterColumn InLastParameterColumn\" data-WideGridArea=\"1/2/2/3\" data-NarrowGridArea=\"2/1/3/2\" style=\"grid-area:1/2/2/3\">alpha</div><div class=\"PAfterParameters\" data-WideGridArea=\"1/3/2/4\" data-NarrowGridArea=\"3/1/4/3\" style=\"grid-area:1/3/2/4\">)</div></div></div></div><div class=\"TTSummary\">Returns the hexidecimal color string for this color object.</div></div>",55:"<div class=\"NDToolTip TShared LLua\"><div id=\"NDPrototype55\" class=\"NDPrototype\"><div class=\"PSection PPlainSection\"><span class=\"SHKeyword\">function</span> meta:GetInverted()</div></div><div class=\"TTSummary\">Returns an inverted version of this color.</div></div>"});