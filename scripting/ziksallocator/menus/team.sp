void GiveTeamMenu( int client, RTLoadout loadout )
{
    g_MenuStateLoadout[client] = loadout;

    char loadoutName[16];
    GetLoadoutName( loadout, loadoutName, sizeof(loadoutName) );

    char buffer[128];
    Format( buffer, sizeof(buffer), "Configure %s loadout:", loadoutName );

    Handle menu = CreateMenu( MenuHandler_Team );
    SetMenuTitle( menu, buffer );
    AddMenuInt( menu, CS_TEAM_T, "Terrorist" );
    AddMenuInt( menu, CS_TEAM_CT, "Counter-Terrorist" );
    SetMenuExitBackButton( menu, true );
    DisplayMenu( menu, client, MENU_TIME_LENGTH );
}

public int MenuHandler_Team( Handle menu, MenuAction action, int param1, int param2 )
{
    LogMessage( "TeamMenu: %i, %i", view_as<int>( action ), param2 );

    if ( action == MenuAction_Cancel && param2 == MenuCancel_ExitBack )
    {
        GiveMainMenu( param1 );
        return;
    }

    if ( action == MenuAction_End )
    {
        CloseHandle( menu );
        return;
    }

    if ( action != MenuAction_Select ) return;

    int client = param1;
    int team = GetMenuInt( menu, param2 );
    RTLoadout loadout = g_MenuStateLoadout[client];

    GiveLoadoutMenu( client, team, loadout );
}
