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
    GetLoadoutName( loadout, loadoutName, sizeof(loadoutName) );

    char buffer[128];
    Format( buffer, sizeof(buffer), "Configure %s loadout:", loadoutName );

    Handle menu = CreateMenu( MenuHandler_Team );
    SetMenuTitle( menu, buffer );
    AddMenuInt( menu, CS_TEAM_T, "Terrorist" );
    AddMenuInt( menu, CS_TEAM_CT, "Counter-Terrorist" );
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
