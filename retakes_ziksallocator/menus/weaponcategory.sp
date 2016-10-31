void GiveWeaponCategoryMenu( int client, int team, RTLoadout loadout )
{
    g_MenuStateTeam[client] = team;
    g_MenuStateLoadout[client] = loadout;

    int available = 0;
    CSWeaponCategory lastValid;

    for ( int i = 0; i < sizeof(g_PrimaryCategories); ++i )
    {
        CSWeaponCategory category = g_PrimaryCategories[i];
        if ( !ShouldShowWeaponCategory( client, team, loadout, category ) ) continue;

        ++available;
        lastValid = category;
    }

    if ( available == 0 ) return;

    if ( available == 1 )
    {
        GiveWeaponMenu( client, team, loadout, lastValid );
        return;
    }

    char teamAbbrev[8];
    GetTeamAbbreviation( team, teamAbbrev, sizeof(teamAbbrev) );

    char loadoutName[16];
    GetLoadoutName( loadout, loadoutName, sizeof(loadoutName) );

    char buffer[128];
    Format( buffer, sizeof(buffer), "%s %s primary:", teamAbbrev, loadoutName );

    Panel menu = new Panel();
    menu.SetTitle( buffer );
    
    int currentCost = GetLoadoutCost( client, team, loadout );
    int moneyAvailable = GetStartMoney( loadout ) - currentCost;
    AddMoneyAvailableItems( menu, loadout, moneyAvailable );

    CSWeapon weapon = GetPrimary( client, team, loadout );
    int cost = GetWeaponCost( client, weapon );
    moneyAvailable += cost;

    if ( weapon != WEAPON_NONE && ShouldShowMoney( loadout ) )
    {
        Format( buffer, sizeof(buffer), "No weapon (+$%i)", cost );
        menu.DrawItem( buffer );
    }
    else
    {
        menu.DrawItem( "No weapon" );
    }

    for ( int i = 0; i < sizeof(g_PrimaryCategories); ++i )
    {
        CSWeaponCategory category = g_PrimaryCategories[i];
        if ( !ShouldShowWeaponCategory( client, team, loadout, category ) ) continue;

        bool enabled = CanSelectWeaponCategory( client, team, loadout, moneyAvailable, category );

        GetWeaponCategoryName( category, buffer, sizeof(buffer) );
        menu.DrawItem( buffer, enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
    }

    AddBackItem( menu );
    menu.Send( client, MenuHandler_WeaponCategory, MENU_TIME_LENGTH );

    delete menu;
}

public int MenuHandler_WeaponCategory( Menu menu, MenuAction action, int param1, int param2 )
{
    if ( action == MenuAction_End )
    {
        delete menu;
        return;
    }

    if ( action != MenuAction_Select ) return;

    int client = param1;
    int team = g_MenuStateTeam[client];
    RTLoadout loadout = g_MenuStateLoadout[client];

    if ( param2 == 9 ) // Go back
    {
        GiveLoadoutMenu( client, team, loadout );
        return;
    }
    
    if ( param2 == 1 ) // No weapon
    {
        SetPrimary( client, team, loadout, WEAPON_NONE );
        SaveLoadouts( client );
        GiveLoadoutMenu( client, team, loadout );
    }

    int categoryIndex = param2 - 2;

    CSWeaponCategory category = g_PrimaryCategories[categoryIndex];
    GiveWeaponMenu( client, team, loadout, category );
}
