/**
 * Adds a gear toggle option with the given name, cost and equipped state,
 * with the option being enabled if the given available money value is
 * greater than or equal to the cost.
 *
 * @param menu      Menu to add the option to.
 * @param name      Name of the gear item.
 * @param available Amount of money available to buy gear.
 * @param cost      Cost of the gear item.
 * @param equipped  True if the client already has this item equipped.
 * @noreturn
 */
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

/**
 * Display the loadout menu corresponding to the given team and loadout
 * type to the given client.
 *
 * @param client    Client to display the menu to.
 * @param team      Team of the loadout to display the menu for.
 * @param loadout   Loadout type to display the menu for.
 * @noreturn
 */
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
        bool enabled = GetSniperFlag( client, team, SNIPER_ENABLED );
        int flagStyle = enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;

        menu.DrawItem( enabled ? "Disable AWP rounds" : "Enable AWP rounds" );
        menu.DrawItem( GetSniperFlag( client, team, SNIPER_SOMETIMES )
            ? "Frequency: Sometimes" : "Frequency: Always if available", flagStyle );
        menu.DrawItem( GetSniperFlag( client, team, SNIPER_NEVERALONE )
            ? "AWP when alone: Disabled" : "AWP when alone: Enabled", flagStyle );
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

        menu.DrawItem( buffer, PrimaryOptionEnabled( client, team, loadout )
            ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
    }

    if ( ShowSecondaryOption( client, team, loadout ) )
    {
        char pistolName[32];
        GetWeaponName( GetSecondary( client, team, loadout ), pistolName, sizeof(pistolName) );

        Format( buffer, sizeof(buffer), "Sidearm: %s", pistolName );

        menu.DrawItem( buffer, SecondaryOptionEnabled( client, team, loadout )
            ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
    }

    AddBackExitItems( menu );
    menu.Send( client, MenuHandler_Loadout, GetMenuTimeSeconds() );

    delete menu;
}

/**
 * Menu handler for the loadout menu.
 *
 * @param menu      Menu to handle an action for.
 * @param action    Type of action to handle.
 * @param param1    First piece of auxiliary info.
 * @param param2    Second piece of auxiliary info.
 * @return          Handler response.
 */
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

    if ( param2 == BACK_ITEM_INDEX )
    {
        GiveTeamMenu( client, loadout );
        return;
    }
    
    if ( param2 == EXIT_ITEM_INDEX )
    {
        return;
    }

    if ( loadout == LOADOUT_SNIPER )
    {
        if ( param2 > 0 && param2 <= SNIPER_FLAG_COUNT )
        {
            RTSniperFlag flag = view_as<RTSniperFlag>(param2 - 1);
            SetSniperFlag( client, team, flag, !GetSniperFlag( client, team, flag ) );
            SaveLoadouts( client );
        }

        param2 -= SNIPER_FLAG_COUNT;
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
