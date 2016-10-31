void GiveWeaponMenu( int client, int team, RTLoadout loadout, CSWeaponCategory category )
{
    g_MenuStateTeam[client] = team;
    g_MenuStateLoadout[client] = loadout;
    g_MenuStateCategory[client] = category;

    char teamAbbrev[8];
    GetTeamAbbreviation( team, teamAbbrev, sizeof(teamAbbrev) );

    char loadoutName[16];
    GetLoadoutName( loadout, loadoutName, sizeof(loadoutName) );

    char weaponCategoryName[16];

    if ( category == WCAT_PISTOL )
    {
        weaponCategoryName = "sidearm";
    }
    else
    {
        weaponCategoryName = "primary";
    }

    char buffer[128];
    Format( buffer, sizeof(buffer), "%s %s %s:", teamAbbrev, loadoutName, weaponCategoryName );

    Panel menu = new Panel();
    menu.SetTitle( buffer );
        
    int currentCost = GetLoadoutCost( client, team, loadout );
    int moneyAvailable = GetStartMoney( loadout ) - currentCost;
    AddMoneyAvailableItems( menu, loadout, moneyAvailable );

    char weaponName[32];

    for ( int i = GetWeaponListMin( category ); i <= GetWeaponListMax( category ); ++i )
    {
        CSWeapon weapon = view_as<CSWeapon>(i);

        if ( !CanBuyWeapon( client, team, loadout, weapon ) ) continue;

        GetWeaponName( weapon, weaponName, sizeof(weaponName) );

        CSWeapon current = category == WCAT_PISTOL
            ? GetSecondary( client, team, loadout )
            : GetPrimary( client, team, loadout ); 

        int cost = GetWeaponCost( client, weapon );
        int curCost = GetWeaponCost( client, current );
        int diff = cost - curCost;

        if ( diff == 0 || !ShouldShowMoney( loadout ) )
        {
            Format( buffer, sizeof(buffer), "%s", weaponName );
        }
        else if ( diff < 0 )
        {
            Format( buffer, sizeof(buffer), "%s (+$%i)", weaponName, -diff );
        }
        else
        {
            Format( buffer, sizeof(buffer), "%s (-$%i)", weaponName, diff );
        }

        if ( diff > moneyAvailable )
        {
            menu.DrawItem( buffer, ITEMDRAW_DISABLED );
        }
        else
        {
            menu.DrawItem( buffer );
        }
    }

    AddBackItem( menu );
    menu.Send( client, MenuHandler_Weapon, MENU_TIME_LENGTH );

    delete menu;
}

public int MenuHandler_Weapon( Menu menu, MenuAction action, int param1, int param2 )
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
    CSWeaponCategory category = g_MenuStateCategory[client];

    int index = 0;
    for ( int i = GetWeaponListMin( category ); i <= GetWeaponListMax( category ); ++i )
    {
        CSWeapon weapon = view_as<CSWeapon>(i);
        if ( !CanBuyWeapon( client, team, loadout, weapon ) ) continue;

        ++index;
        if ( param2 == index )
        {
            if ( category == WCAT_PISTOL )
            {
                SetSecondary( client, team, loadout, weapon );
            }
            else
            {
                SetPrimary( client, team, loadout, weapon );
            }

            SaveLoadouts( client );
        }
    }
    
    GiveLoadoutMenu( client, team, loadout );
}
