@echo off

"%SOURCEMOD%/scripting/spcomp.exe" "retakes_ziksallocator.sp" "-i%SOURCEMOD%/scripting" "-o../plugins/retakes_ziksallocator.smx"
"%SOURCEMOD%/scripting/spcomp.exe" "mapchooser_ziks.sp" "-i%SOURCEMOD%/scripting" "-o../plugins/mapchooser.smx"
