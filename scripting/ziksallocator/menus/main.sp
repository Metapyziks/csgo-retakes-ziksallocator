/**
 * Display the main loadout selection menu to the given client.
 *
 * @param client    Client to display the menu to.
 * @noreturn
 */
void GiveMainMenu( int client )
{
    Handle menu = CreateMenu( MenuHandler_Main );
    SetMenuTitle( menu, "Configure loadouts:" );
    AddMenuInt( menu, view_as<int>( LOADOUT_PISTOL ), "Pistol loadout" );
    AddMenuInt( menu, view_as<int>( LOADOUT_FULL ), "Full Buy loadout" );
    AddMenuInt( menu, view_as<int>( LOADOUT_SNIPER ), "AWP loadout" );
    AddMenuInt( menu, -1, "Reset all" );
    DisplayMenu( menu, client, GetMenuTimeSeconds() );
}

/**
 * Menu handler for the main loadout selection menu.
 *
 * @param menu      Menu to handle an action for.
 * @param action    Type of action to handle.
 * @param param1    First piece of auxiliary info.
 * @param param2    Second piece of auxiliary info.
 * @return          Handler response.
 */
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
        GiveResetConfirmMenu( client );
        return;
    }

    RTLoadout choice = view_as<RTLoadout>( GetMenuInt( menu, param2 ) );

    GiveTeamMenu( client, choice );
}
