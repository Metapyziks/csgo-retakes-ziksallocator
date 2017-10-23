/**
 * Display the main loadout selection menu to the given client.
 *
 * @param client    Client to display the menu to.
 * @noreturn
 */
void GiveMainMenu( int client )
{
    char buffer[128];

    Handle menu = CreateMenu( MenuHandler_Main );

    Format( buffer, sizeof(buffer), "%t", "LoadoutMenuHeading" );
    SetMenuTitle( menu, buffer );

    Format( buffer, sizeof(buffer), "%t", "PistolLoadout" );
    AddMenuInt( menu, view_as<int>( LOADOUT_PISTOL ), buffer );

    Format( buffer, sizeof(buffer), "%t", "FullBuyLoadout" );
    AddMenuInt( menu, view_as<int>( LOADOUT_FULL ), buffer );

    Format( buffer, sizeof(buffer), "%t", "AWPLoadout" );
    AddMenuInt( menu, view_as<int>( LOADOUT_SNIPER ), buffer );

    Format( buffer, sizeof(buffer), "%t", "ResetAll" );
    AddMenuInt( menu, -1, buffer );

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
