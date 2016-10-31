void AddGearOption( Panel menu, char[] name, int available, int cost, bool equipped )
{
    char buffer[64];
    bool enabled = true;

    if ( equipped )
    {
        Format( buffer, sizeof(buffer), "Disable %s (+$%i)", name, cost );
    }
    else
    {
        Format( buffer, sizeof(buffer), "Enable %s (-$%i)", name, cost );
        enabled = available >= cost;
    }

    menu.DrawItem( buffer, enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
}

void AddMoneyAvailableItems( Panel menu, RTLoadout loadout, int moneyAvailable )
{
    if ( !ShouldShowMoney( loadout ) ) return;

    char buffer[64];
    Format( buffer, sizeof(buffer), "Money available: $%i", moneyAvailable );

    menu.DrawItem( buffer, ITEMDRAW_RAWLINE );
}

void AddBackItem( Panel menu )
{
    menu.DrawItem( " ", ITEMDRAW_RAWLINE  );
    menu.CurrentKey = 9;
    menu.DrawItem( "Back" );
}

void GiveLoadoutMenu( int client, int team, RTLoadout loadout )
{
    g_MenuStateTeam[client] = team;
    g_MenuStateLoadout[client] = loadout;

    char teamAbbrev[8];
    GetTeamAbbreviation( team, teamAbbrev, sizeof(teamAbbrev) );

    char loadoutName[16];
    GetLoadoutName( loadout, loadoutName, sizeof(loadoutName) );

    char buffer[128];
    Format( buffer, sizeof(buffer), "%s %s loadout:", teamAbbrev, loadoutName );

    Panel menu = new Panel();
    menu.SetTitle( buffer );
    
    int currentCost = GetLoadoutCost( client, team, loadout );
    int moneyAvailable = GetStartMoney( loadout ) - currentCost;
    AddMoneyAvailableItems( menu, loadout, moneyAvailable );

    if ( loadout == LOADOUT_SNIPER )
    {
        menu.DrawItem( GetSniper( client, team ) ? "Disable AWP rounds" : "Enable AWP rounds" );
    }

    if ( ShowKevlarOption( client, team, loadout ) )
    {
        AddGearOption( menu, "Kevlar", moneyAvailable,
            KEVLAR_COST, GetKevlar( client, team, loadout ) );
    }

    if ( ShowHelmetOption( client, team, loadout ) )
    {
        int cost = HELMET_COST;
        if ( !GetKevlar( client, team, loadout ) )
        {
            cost += KEVLAR_COST;
        }

        AddGearOption( menu, "Helmet", moneyAvailable,
            cost, GetHelmet( client, team, loadout ) );
    }

    if ( ShowDefuseOption( client, team, loadout ) )
    {
        AddGearOption( menu, "Defuse Kit", moneyAvailable,
            DEFUSE_COST, GetDefuse( client, team, loadout ) );
    }

    if ( ShowPrimaryOption( client, team, loadout ) )
    {
        char weaponName[32];
        GetWeaponName( GetPrimary( client, team, loadout ), weaponName, sizeof(weaponName) );

        Format( buffer, sizeof(buffer), "Primary: %s", weaponName );

        menu.DrawItem( buffer );
    }

    if ( ShowSecondaryOption( client, team, loadout ) )
    {
        char pistolName[32];
        GetWeaponName( GetSecondary( client, team, loadout ), pistolName, sizeof(pistolName) );

        Format( buffer, sizeof(buffer), "Sidearm: %s", pistolName );

        menu.DrawItem( buffer );
    }

    AddBackItem( menu );
    menu.Send( client, MenuHandler_Loadout, MENU_TIME_LENGTH );

    delete menu;
}

public int MenuHandler_Loadout( Menu menu, MenuAction action, int param1, int param2 )
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
        GiveTeamMenu( client, loadout );
        return;
    }

    if ( loadout == LOADOUT_SNIPER )
    {
        if ( param2 == 1 )
        {
            SetSniper( client, team, !GetSniper( client, team ) );
            SaveLoadouts( client );
        }

        param2 -= 1;
    }

    if ( ShowKevlarOption( client, team, loadout ) )
    {
        if ( param2 == 1 )
        {
            SetKevlar( client, team, loadout, !GetKevlar( client, team, loadout ) );
            SaveLoadouts( client );
        }

        param2 -= 1;
    }

    if ( ShowHelmetOption( client, team, loadout ) )
    {
        if ( param2 == 1 )
        {
            SetHelmet( client, team, loadout, !GetHelmet( client, team, loadout ) );
            SaveLoadouts( client );
        }

        param2 -= 1;
    }

    if ( ShowDefuseOption( client, team, loadout ) )
    {
        if ( param2 == 1 )
        {
            SetDefuse( client, team, loadout, !GetDefuse( client, team, loadout ) );
            SaveLoadouts( client );
        }

        param2 -= 1;
    }

    if ( ShowPrimaryOption( client, team, loadout ) )
    {
        if ( param2 == 1 )
        {
            GiveWeaponCategoryMenu( client, team, loadout );
            return;
        }

        param2 -= 1;
    }

    if ( ShowSecondaryOption( client, team, loadout ) )
    {
        if ( param2 == 1 )
        {
            GiveWeaponMenu( client, team, loadout, WCAT_PISTOL );
            return;
        }

        param2 -= 1;
    }

    GiveLoadoutMenu( client, team, loadout );
}
