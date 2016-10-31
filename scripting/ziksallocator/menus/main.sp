void GiveMainMenu( int client )
{
    Handle menu = CreateMenu( MenuHandler_Main );
    SetMenuTitle( menu, "Configure loadouts:" );
    AddMenuInt( menu, view_as<int>( LOADOUT_PISTOL ), "Pistol loadout" );
    AddMenuInt( menu, view_as<int>( LOADOUT_FORCE ), "Force Buy loadout" );
    AddMenuInt( menu, view_as<int>( LOADOUT_FULL ), "Full Buy loadout" );
    AddMenuInt( menu, view_as<int>( LOADOUT_SNIPER ), "AWP loadout" );
    AddMenuInt( menu, -1, "Reset all" );
    DisplayMenu( menu, client, MENU_TIME_LENGTH );
}

public int MenuHandler_Main( Handle menu, MenuAction action, int param1, int param2 )
{
    if ( action == MenuAction_End )
    {
        CloseHandle( menu );
        return;
    }

    if ( action != MenuAction_Select ) return;

    int client = param1;

    if ( GetMenuInt( menu, param2 ) == -1 )
    {
        ResetAllLoadouts( client );
        SaveLoadouts( client );
        return;
    }

    RTLoadout choice = view_as<RTLoadout>( GetMenuInt( menu, param2 ) );

    GiveTeamMenu( client, choice );
}
