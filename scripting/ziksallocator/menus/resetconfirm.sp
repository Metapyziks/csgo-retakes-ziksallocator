void GiveResetConfirmMenu( int client )
{
    Handle menu = CreateMenu( MenuHandler_ResetConfirm );
    SetMenuTitle( menu, "Are you sure?" );
    AddMenuBool( menu, true, "Yes, reset all loadouts" );
    AddMenuBool( menu, false, "Whoops, no thanks!" );
    SetMenuExitBackButton( menu, true );
    DisplayMenu( menu, client, MENU_TIME_LENGTH );
}

public int MenuHandler_ResetConfirm( Handle menu, MenuAction action, int param1, int param2 )
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

    if ( GetMenuBool( menu, param2 ) )
    {
        ResetAllLoadouts( client );
        SaveLoadouts( client );
    }
    
    GiveMainMenu( client );
}
