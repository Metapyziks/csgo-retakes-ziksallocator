/**
 * Display the team selection menu for a given loadout to the given client.
 *
 * @param client    Client to display the menu to.
 * @param loadout   Previously selected loadout to select a team for.
 * @noreturn
 */
void GiveTeamMenu( int client, RTLoadout loadout )
{
    g_MenuStateLoadout[client] = loadout;

    char loadoutName[32];
    GetLoadoutName( 0, loadout, loadoutName, sizeof(loadoutName) );

    char buffer[128];

    Handle menu = CreateMenu( MenuHandler_Team );
    
    Format( buffer, sizeof(buffer), "%t", "ConfigureLoadout", loadoutName );
    SetMenuTitle( menu, buffer );
    
    Format( buffer, sizeof(buffer), "%t", "TeamTerrorist" );
    AddMenuInt( menu, CS_TEAM_T, buffer );
    
    Format( buffer, sizeof(buffer), "%t", "TeamCounterTerrorist" );
    AddMenuInt( menu, CS_TEAM_CT, buffer );

    SetMenuExitBackButton( menu, true );
    DisplayMenu( menu, client, GetMenuTimeSeconds() );
}

/**
 * Menu handler for the team selection menu.
 *
 * @param menu      Menu to handle an action for.
 * @param action    Type of action to handle.
 * @param param1    First piece of auxiliary info.
 * @param param2    Second piece of auxiliary info.
 * @return          Handler response.
 */
public int MenuHandler_Team( Handle menu, MenuAction action, int param1, int param2 )
{
    if ( action == MenuAction_Cancel && param2 == MenuCancel_ExitBack )
    {
        GiveMainMenu( param1 );
        return 0;
    }

    if ( action == MenuAction_End )
    {
        CloseHandle( menu );
        return 0;
    }

    if ( action != MenuAction_Select ) return 0;

    int client = param1;
    int team = GetMenuInt( menu, param2 );
    RTLoadout loadout = g_MenuStateLoadout[client];

    GiveLoadoutMenu( client, team, loadout );
    return 0;
}
