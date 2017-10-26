/**
 * Gets the display name of the given loadout type.
 *
 * @param loadout   Loadout type to get the name of.
 * @param buffer    Character array to write the name to.
 * @param maxLength Size of the destination character array.
 * @noreturn
 */
void GetLoadoutName( int team, RTLoadout loadout, char[] buffer, int maxLength )
{
    switch ( loadout )
    {
        case LOADOUT_PISTOL: Format( buffer, maxLength, "%t", "Pistol" );
        case LOADOUT_FORCE:  Format( buffer, maxLength, "%t", "ForceBuy" );
        case LOADOUT_FULL:   Format( buffer, maxLength, "%t", "FullBuy" );
        case LOADOUT_SNIPER: Format( buffer, maxLength, "%t", "AWP" );
        case LOADOUT_RANDOM:
        {
            if ( GetRandomPrimary( team ) != WEAPON_NONE )
            {
                GetWeaponName( GetRandomPrimary( team ), buffer, maxLength );
            }
            else if ( GetRandomSecondary( team ) != WEAPON_NONE )
            {
                GetWeaponName( GetRandomSecondary( team ), buffer, maxLength );
            }
            else
            {
                Format( buffer, maxLength, "%t", "Knife" );
            }
        }
    }
}

/**
 * Gets whether money available and items costs should be shown
 * in loadout menus for the given loadout.
 *
 * @param loadout   Loadout type to get money visibility for.
 * @return          True if money available and item costs should
                    be shown in loadout menus for the given loadout.
 */
bool ShouldShowMoney( RTLoadout loadout )
{
    return GetStartMoney( loadout ) < 16000;
}

/**
 * Gets whether the given client, when on the given team and during loadouts of
 * the given type, should be given the option to toggle kevlar.
 *
 * @param client    Client to check for kevlar togglability.
 * @param team      Team to check for kevlar togglability.
 * @param loadout   Loadout to check for kevlar togglability.
 * @return          True if kevlar can be toggled.
 */
bool ShowKevlarOption( int client, int team, RTLoadout loadout )
{
    return loadout != LOADOUT_FULL && loadout != LOADOUT_SNIPER;
}

/**
 * Gets whether the given client, when on the given team and during loadouts of
 * the given type, should be given the option to toggle helmets.
 *
 * @param client    Client to check for helmet togglability.
 * @param team      Team to check for helmet togglability.
 * @param loadout   Loadout to check for helmet togglability.
 * @return          True if helmets can be toggled.
 */
bool ShowHelmetOption( int client, int team, RTLoadout loadout )
{
    return loadout != LOADOUT_PISTOL && loadout != LOADOUT_FULL && loadout != LOADOUT_SNIPER;
}

/**
 * Gets whether the given client, when on the given team and during loadouts of
 * the given type, should be given the option to toggle defuse kits.
 *
 * @param client    Client to check for defuse kit togglability.
 * @param team      Team to check for defuse kit togglability.
 * @param loadout   Loadout to check for defuse kit togglability.
 * @return          True if defuse kits can be toggled.
 */
bool ShowDefuseOption( int client, int team, RTLoadout loadout )
{
    return team == CS_TEAM_CT && loadout != LOADOUT_FULL && loadout != LOADOUT_SNIPER;
}

/**
 * Gets whether the given client, when on the given team and during loadouts of
 * the given type, should be given the option to select a primary weapon.
 *
 * @param client    Client to check for primary weapon selectability.
 * @param team      Team to check for primary weapon selectability.
 * @param loadout   Loadout to check for primary weapon selectability.
 * @return          True if primary weapons can be selected.
 */
bool ShowPrimaryOption( int client, int team, RTLoadout loadout )
{
    return loadout != LOADOUT_PISTOL && loadout != LOADOUT_SNIPER;
}

/**
 * Gets whether the given client should be able to select the primary weapon
 * option in the given loadout's menu for the given team.
 *
 * @param client    Client that the menu is to be displayed to.
 * @param team      Team that the loadout menu corresponds to.
 * @param loadout   Loadout that the menu corresponds to.
 * @return          True if the client should be able to select a primary weapon.
 */
bool PrimaryOptionEnabled( int client, int team, RTLoadout loadout )
{
    return true;
}

/**
 * Gets whether the given client, when on the given team and during loadouts of
 * the given type, should be given the option to select a secondary weapon.
 *
 * @param client    Client to check for secondary weapon selectability.
 * @param team      Team to check for secondary weapon selectability.
 * @param loadout   Loadout to check for secondary weapon selectability.
 * @return          True if secondary weapons can be selected.
 */
bool ShowSecondaryOption( int client, int team, RTLoadout loadout )
{
    return true;
}

/**
 * Gets whether the given client should be able to select the secondary weapon
 * option in the given loadout's menu for the given team.
 *
 * @param client    Client that the menu is to be displayed to.
 * @param team      Team that the loadout menu corresponds to.
 * @param loadout   Loadout that the menu corresponds to.
 * @return          True if the client should be able to select a secondary weapon.
 */
bool SecondaryOptionEnabled( int client, int team, RTLoadout loadout )
{
    return loadout != LOADOUT_SNIPER || GetSniperFlag( client, team, SNIPER_ENABLED );
}

/**
 * Gets whether the given weapon category should be visible to the given client
 * in loadout menus for the given team and loadout type. A weapon category is visible
 * if there is at least one weapon in that category priced at leass than the start money
 * of the given loadout type.
 *
 * @param client    Client to check weapon category visibility for.
 * @param team      Team to check weapon category visibility for.
 * @param loadout   Loadout to check weapon category visibility for.
 * @param category  Weapon category to check visibility for.
 * @return          True if the given weapon category should be visible.
 */
bool ShouldShowWeaponCategory( int client, int team, RTLoadout loadout, CSWeaponCategory category )
{
    return CanSelectWeaponCategory( client, team, loadout, GetStartMoney( loadout ), category );
}

/**
 * Gets whether the given weapon category can be selected by the given client in loadout
 * menus for the given team and loadout type. A weapon category is selectable if there is
 * at least one weapon in that category that is currently affordable.
 *
 * @param client    Client to check weapon category selectability for.
 * @param team      Team to check weapon category selectability for.
 * @param loadout   Loadout to check weapon category selectability for.
 * @param money     Maximum price that a weapon can be purchased for.
 * @param category  Weapon category to check selectability for.
 * @return          True if the given weapon category should be selectable.
 */
bool CanSelectWeaponCategory( int client, int team, RTLoadout loadout, int money, CSWeaponCategory category )
{
    for ( int i = GetWeaponListMin( category ); i <= GetWeaponListMax( category ); ++i )
    {
        CSWeapon weapon = view_as<CSWeapon>(i);

        if ( !CanBuyWeapon( client, team, loadout, weapon ) ) continue;
        if ( GetWeaponCost( client, weapon ) > money ) continue;

        return true;
    }

    return false;
}

/**
 * Gets the total cost of the loadout preference for the given client
 * when on the given team during loadouts of the given type.
 *
 * @param client    Client to get loadout cost for.
 * @param team      Team to get loadout cost for.
 * @param loadout   Loadout type to get cost for.
 * @return          Loadout cost for the given client.
 */
int GetLoadoutCost( int client, int team, RTLoadout loadout )
{
    int total = 0;

    if ( GetKevlar( client, team, loadout ) ) total += KEVLAR_COST;
    if ( GetHelmet( client, team, loadout ) ) total += HELMET_COST;
    if ( GetDefuse( client, team, loadout ) ) total += DEFUSE_COST;

    total += GetWeaponCost( client, GetSecondary( client, team, loadout ) );
    total += GetWeaponCost( client, GetPrimary( client, team, loadout ) );

    return total;
}
