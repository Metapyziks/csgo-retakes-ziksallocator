/**
 * Time in seconds that menus should remain open for before automatically closing.
 */
Handle g_CVMenuTimeSeconds = INVALID_HANDLE;

/**
 * Percentage chance of a random weapon round.
 */
Handle g_CVRandomProbability = INVALID_HANDLE;

Handle g_CVHeadshotOnly = INVALID_HANDLE;

/**
 * Pistol round start money.
 */
Handle g_CVPistolStartMoney = INVALID_HANDLE;

/**
 * Force-buy round start money.
 */
Handle g_CVForceStartMoney = INVALID_HANDLE;

/**
 * Normal round start money.
 */
Handle g_CVFullStartMoney = INVALID_HANDLE;

/**
 * Maximum total value of randomly allocated grenades.
 */
Handle g_CVMaxGrenadeValue = INVALID_HANDLE;

/**
 * "Percentage chance of decoys being considered for random grenade allocation.
 */
Handle g_CVDecoyProbability = INVALID_HANDLE;

/**
 * Total number of grenades a player can hold.
 */
Handle g_CVNadeLimitTotal = INVALID_HANDLE;

/**
 * Total number of grenades of a particular type (except flashbangs) a player can hold.
 */
Handle g_CVNadeLimitDefault = INVALID_HANDLE;

/**
 * Total number of flashbangs a player can hold.
 */
Handle g_CVNadeLimitFlash = INVALID_HANDLE;

/**
 * Creates or finds all convars used by this plugin.
 *
 * @noreturn
 */
void SetupConVars()
{
    g_CVMenuTimeSeconds = CreateConVar( "sm_retakes_menu_time", "15", "Time in seconds that menus should remain open for before automatically closing.", FCVAR_NOTIFY );

    g_CVRandomProbability = CreateConVar( "sm_retakes_random_chance", "5", "Percentage chance of a random weapon round", FCVAR_NOTIFY );
    g_CVHeadshotOnly = CreateConVar( "sm_retakes_headshot_only", "0", "Enable headshot only mode", FCVAR_NOTIFY );

    g_CVPistolStartMoney = CreateConVar( "sm_retakes_pistol_startmoney", "800", "Pistol round start money", FCVAR_NOTIFY );
    g_CVForceStartMoney = CreateConVar( "sm_retakes_forcebuy_startmoney", "2400", "Force-buy round start money", FCVAR_NOTIFY );
    g_CVFullStartMoney = CreateConVar( "sm_retakes_fullbuy_startmoney", "16000", "Normal round start money", FCVAR_NOTIFY );

    g_CVMaxGrenadeValue = CreateConVar( "sm_retakes_grenade_maxvalue", "800", "Maximum total value of randomly allocated grenades", FCVAR_NOTIFY );
    g_CVDecoyProbability = CreateConVar( "sm_retakes_decoy_chance", "10", "Percentage chance of decoys being considered for random grenade allocation", FCVAR_NOTIFY );

    g_CVNadeLimitTotal = FindConVar( "ammo_grenade_limit_total" );
    g_CVNadeLimitDefault = FindConVar( "ammo_grenade_limit_default" );
    g_CVNadeLimitFlash = FindConVar( "ammo_grenade_limit_flashbang" );
}

/**
 * Time in seconds that menus should remain open for before automatically closing.
 *
 * @return          Time in seconds.
 */
int GetMenuTimeSeconds()
{
    return GetConVarInt( g_CVMenuTimeSeconds );
}

/**
 * Finds the percentage probability of a random weapon round.
 *
 * @return          Probability in percent.
 */
int GetRandomLoadoutProbability()
{
    return GetConVarInt( g_CVRandomProbability );
}

bool GetIsHeadshotOnly()
{
    return GetConVarBool( g_CVHeadshotOnly );
}

/**
 * Gets the amount of money that a client can allocate between
 * different gear and weapons on a given loadout type.
 *
 * @param loadout   Loadout type to get start money for.
 * @return          Money available for loadouts of the given type.
 */
int GetStartMoney( RTLoadout loadout )
{
    switch ( loadout )
    {
        case LOADOUT_PISTOL:
            return GetConVarInt( g_CVPistolStartMoney );
        case LOADOUT_FORCE:
            return GetConVarInt( g_CVForceStartMoney );
        case LOADOUT_FULL, LOADOUT_SNIPER:
            return GetConVarInt( g_CVFullStartMoney );
    }

    return 0;
}

/**
 * Gets the maximum value of grenades that can be given to players
 * on the given team with the given loadout type.
 *
 * @param team      Team to get the maximum value for.
 * @param loadout   Loadout to get the maximum value for.
 * @return          Maximum total value of grenades.
 */
int GetMaxNadeValue( int team, RTLoadout loadout )
{
    return GetConVarInt( g_CVMaxGrenadeValue );
}

/**
 * Percentage probability of a decoy being available when randomly
 * selecting a grenade.
 *
 * @param loadout   Loadout type to get decoy probability for.
 * @return          Probability of a decoy being available for randomly
 *                  selection, in percent. 
 */
int GetDecoyProbability( RTLoadout loadout )
{
    return GetConVarInt( g_CVDecoyProbability );
}

/**
 * Gets the maximum number of grenades that a player can hold when on the
 * given team during loadouts of the given type.
 *
 * @param team      Team to get maximum grenade count for.
 * @param loadout   Loadout type to get maximum grenade count for.
 * @return          Maximum number of grenades that can be held.
 */
int GetMaxTotalGrenades( int team, RTLoadout loadout )
{
    return GetConVarInt( g_CVNadeLimitTotal );
}

/**
 * Gets the maximum number of grenades of the given type that a player
 * can hold when on the given team during loadouts of the given type.
 *
 * @note            Valid grenade chars are {h, f, m, i, s, d}.
 * @param team      Team to get maximum grenade count for.
 * @param loadout   Loadout type to get maximum grenade count for.
 * @param nadeChar  Grenade type to get maximum grenade count for.
 * @return          Maximum number of grenades that can be held.
 */
int GetMaxGrenades( int team, RTLoadout loadout, char nadeChar )
{
    switch ( nadeChar )
    {
        case 'h', 'm', 'i', 's', 'd':
            return GetConVarInt( g_CVNadeLimitDefault );
        case 'f':
            return GetConVarInt( g_CVNadeLimitFlash );
    }

    return 0;
}
