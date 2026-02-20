# AutoCAD Script - Toggle-Lyer
Toggles Demolition, Existing, and New AutoCAD layers on or off.

How to install:
In AutoCAD, run the command APPLOAD. Use the Load/Unload Applications file browser to locate and load the toggleLayer.lsp script.

How it works:
Layer ON/OFF by case-insensitive substring match
Groups covered by commands:
DEMO      → matches "demo" and "(d)"
NEW       → matches "new" and "(n)"
PROPOSED  → matches "proposed" and shorthand "prop" (guards against "property")
EXIST     → matches "exist" and "(e)"

Commands:
DEMO-ON       / DEMO-OFF
NEW-ON        / NEW-OFF
PROPOSED-ON   / PROPOSED-OFF
EXIST-ON      / EXIST-OFF
