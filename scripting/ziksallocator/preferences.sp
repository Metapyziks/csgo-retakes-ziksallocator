/**
 * Kevlar enabled state for each client on either team for all loadout types.
 */
bool g_Kevlar[MAXPLAYERS+1][TEAM_COUNT*LOADOUT_COUNT];

/**
 * Helmet enabled state for each client on either team for all loadout types.
 */
bool g_Helmet[MAXPLAYERS+1][TEAM_COUNT*LOADOUT_COUNT];

/**
 * Defuse kit enabled state for each client for all loadout types.
 */
bool g_Defuse[MAXPLAYERS+1][LOADOUT_COUNT];

/**
 * AWP round flags for each client on either team.
 */
bool g_Sniper[MAXPLAYERS+1][TEAM_COUNT*SNIPER_FLAG_COUNT];

/**
 * Primary weapon selection for each client on either team for all loadout types.
 */
CSWeapon g_Primary[MAXPLAYERS+1][TEAM_COUNT*LOADOUT_COUNT];

/**
 * Secondary weapon selection for each client on either team for all loadout types.
 */
CSWeapon g_Secondary[MAXPLAYERS+1][TEAM_COUNT*LOADOUT_COUNT];

/**
 * Sets kevlar enabled state for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to set kevlar enabled state for.
 * @param team      Team for which to set kevlar enabled state for.
 * @param loadout   Loadout type for which to set kevlar enabled state for.
 * @param enabled   If true, the client is set to receive kevlar during
 *                  loadouts of the given type when on the given team.
 * @noreturn
 */
void SetKevlar( int client, int team, RTLoadout loadout, bool enabled )
{
    g_Kevlar[client][GetTeamLoadoutIndex( team , loadout )] = enabled;
    if ( !enabled ) SetHelmet( client, team, loadout, false );
}

/**
 * Gets kevlar enabled state for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to get kevlar enabled state for.
 * @param team      Team for which to get kevlar enabled state for.
 * @param loadout   Loadout type for which to get kevlar enabled state for.
 * @return          True if the client is set to receive kevlar during
 *                  loadouts of the given type when on the given team.
 */
bool GetKevlar( int client, int team, RTLoadout loadout )
{
    return g_Kevlar[client][GetTeamLoadoutIndex( team , loadout )];
}

/**
 * Sets helmet enabled state for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to set helmet enabled state for.
 * @param team      Team for which to set helmet enabled state for.
 * @param loadout   Loadout type for which to set helmet enabled state for.
 * @param enabled   If true, the client is set to receive a helmet during
 *                  loadouts of the given type when on the given team.
 * @noreturn
 */
void SetHelmet( int client, int team, RTLoadout loadout, bool enabled )
{
    g_Helmet[client][GetTeamLoadoutIndex( team , loadout )] = enabled;
    if ( enabled ) SetKevlar( client, team, loadout, true );
}

/**
 * Gets helmet enabled state for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to get helmet enabled state for.
 * @param team      Team for which to get helmet enabled state for.
 * @param loadout   Loadout type for which to get helmet enabled state for.
 * @return          True if the client is set to receive a helmet during
 *                  loadouts of the given type when on the given team.
 */
bool GetHelmet( int client, int team, RTLoadout loadout )
{
    return GetKevlar( client, team, loadout ) && g_Helmet[client][GetTeamLoadoutIndex( team , loadout )];
}

/**
 * Sets defuse kit enabled state for a client during loadouts of the given type.
 *
 * @param client    Client to set defuse kit enabled state for.
 * @param team      Must be CS_TEAM_CT, or nothing will be set.
 * @param loadout   Loadout type for which to set defuse kit enabled state for.
 * @param enabled   If true, the client is set to receive a defuse kit during
 *                  loadouts of the given type.
 * @noreturn
 */
void SetDefuse( int client, int team, RTLoadout loadout, bool enabled )
{
    if ( team != CS_TEAM_CT ) return;
    g_Defuse[client][loadout] = enabled;
}

/**
 * Gets defuse kit enabled state for a client during loadouts of the given type.
 *
 * @param client    Client to get defuse kit enabled state for.
 * @param team      Must be CS_TEAM_CT, or will return false.
 * @param loadout   Loadout type for which to get defuse kit enabled state for.
 * @return          True if the client is set to receive a defuse kit during
 *                  loadouts of the given type.
 */
bool GetDefuse( int client, int team, RTLoadout loadout )
{
    if ( team != CS_TEAM_CT ) return false;
    return g_Defuse[client][loadout];
}

/**
 * Sets / clears AWP round flag for a client when on the given team.
 *
 * @param client    Client to set AWP round flag for.
 * @param team      Team for which to set AWP round flag for.
 * @param flag      Flag to either set or clear.
 * @param enabled   If true, the given flag is set. Otherwise it is cleared.
 * @noreturn
 */
void SetSniperFlag( int client, int team, RTSniperFlag flag, bool value )
{
    g_Sniper[client][GetTeamSniperFlagIndex( team, flag )] = value;
}

/**
 * Gets an AWP round flag for a client when on the given team.
 *
 * @param client    Client to get AWP round flag for.
 * @param team      Team for which to get AWP round flag for.
 * @param flag      Flag to get.
 * @return          True if the given flag is set, false otherwise.
 */
bool GetSniperFlag( int client, int team, RTSniperFlag flag )
{
    return g_Sniper[client][GetTeamSniperFlagIndex( team, flag )];
}

/**
 * Sets primary weapon selection for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to set primary weapon selection for.
 * @param team      Team for which to set primary weapon selection for.
 * @param loadout   Loadout type for which to set primary weapon selection for.
 * @param weapon    Primary weapon to equip during loadouts of the given type
 *                  when the client is on the given team.
 * @noreturn
 */
void SetPrimary( int client, int team, RTLoadout loadout, CSWeapon weapon )
{
    g_Primary[client][GetTeamLoadoutIndex( team , loadout )] = weapon;
}

/**
 * Gets primary weapon selection for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to get primary weapon selection for.
 * @param team      Team for which to get primary weapon selection for.
 * @param loadout   Loadout type for which to get primary weapon selection for.
 * @return          Primary weapon to equip during loadouts of the given type
 *                  when the client is on the given team.
 */
CSWeapon GetPrimary( int client, int team, RTLoadout loadout )
{
    return g_Primary[client][GetTeamLoadoutIndex( team , loadout )];
}

/**
 * Sets secondary weapon selection for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to set secondary weapon selection for.
 * @param team      Team for which to set secondary weapon selection for.
 * @param loadout   Loadout type for which to set secondary weapon selection for.
 * @param weapon    Secondary weapon to equip during loadouts of the given type
 *                  when the client is on the given team.
 * @noreturn
 */
void SetSecondary( int client, int team, RTLoadout loadout, CSWeapon weapon )
{
    g_Secondary[client][GetTeamLoadoutIndex( team , loadout )] = weapon;
}

/**
 * Gets secondary weapon selection for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to get secondary weapon selection for.
 * @param team      Team for which to get secondary weapon selection for.
 * @param loadout   Loadout type for which to get secondary weapon selection for.
 * @return          Secondary weapon to equip during loadouts of the given type
 *                  when the client is on the given team.
 */
CSWeapon GetSecondary( int client, int team, RTLoadout loadout )
{
    return g_Secondary[client][GetTeamLoadoutIndex( team , loadout )];
}

/**
 * Resets a client's preferences for all loadouts to their defaults.
 *
 * @param client    Client to reset loadout preferences for.
 * @noreturn
 */
void ResetAllLoadouts( int client )
{
    for ( int i = 0; i < view_as<int>(RTLoadout); ++i )
    {
        RTLoadout loadout = view_as<RTLoadout>(i);
        ResetLoadout( client, CS_TEAM_T, loadout );
        ResetLoadout( client, CS_TEAM_CT, loadout );
    }
}

/**
 * Resets a client's preferences for a given team and loadout to their defaults.
 *
 * @param client    Client to reset loadout preferences for.
 * @param team      Team to reset loadout preferences for.
 * @param loadout   Loadout type to reset preferences for.
 * @noreturn
 */
void ResetLoadout( int client, int team, RTLoadout loadout )
{
    SetHelmet( client, team, loadout, false );
    SetKevlar( client, team, loadout, false );
    SetDefuse( client, team, loadout, false );
    SetPrimary( client, team, loadout, WEAPON_NONE );
    SetSecondary( client, team, loadout, team == CS_TEAM_T ? WEAPON_GLOCK : WEAPON_HKP2000 );

    switch ( loadout )
    {
        case LOADOUT_PISTOL:
        {
            SetKevlar( client, team, loadout, true );
        }
        case LOADOUT_FORCE:
        {
            SetHelmet( client, team, loadout, true );
            SetKevlar( client, team, loadout, true );
            SetPrimary( client, team, loadout, WEAPON_UMP45 );
        }
        case LOADOUT_FULL:
        {
            SetHelmet( client, team, loadout, true );
            SetKevlar( client, team, loadout, true );
            SetDefuse( client, team, loadout, true );
            SetPrimary( client, team, loadout, team == CS_TEAM_T ? WEAPON_AK47 : WEAPON_M4A1 );
        }
        case LOADOUT_SNIPER:
        {
            SetSniperFlag( client, team, SNIPER_ENABLED, false );
            SetSniperFlag( client, team, SNIPER_SOMETIMES, true );
            SetSniperFlag( client, team, SNIPER_NEVERALONE, true );
            SetHelmet( client, team, loadout, true );
            SetKevlar( client, team, loadout, true );
            SetDefuse( client, team, loadout, true );
            SetPrimary( client, team, loadout, WEAPON_AWP );
            SetSecondary( client, team, loadout, team == CS_TEAM_T ? WEAPON_TEC9 : WEAPON_FIVESEVEN );
        }
    }
}
