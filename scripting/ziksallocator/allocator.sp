/**
 * Chooses a loadout type for the next round.
 *
 * @return          Loadout type selected for the next round.
 */
RTLoadout GetLoadout()
{
    int rand = GetRandomInt( 0, 99 );
    int pistolChance = GetLoadoutTypeProbability( LOADOUT_PISTOL );
    int forceChance = GetLoadoutTypeProbability( LOADOUT_FORCE );

    if ( rand < pistolChance )
    {
        return LOADOUT_PISTOL;
    }

    if ( rand < pistolChance + forceChance )
    {
        return LOADOUT_FORCE;
    }

    return LOADOUT_FULL;
}

/**
 * A randomly selected primary weapon for LOADOUT_RANDOM rounds.
 */
CSWeapon g_RandomPrimary;

/**
 * A randomly selected secondary weapon for LOADOUT_RANDOM rounds.
 */
CSWeapon g_RandomSecondary;

/**
 * Weapons that can be selected for LOADOUT_RANDOM rounds.
 */
CSWeapon g_RandomWeapons[] = {
    WEAPON_GLOCK,
    WEAPON_HKP2000,
    WEAPON_P250,
    WEAPON_ELITE,
    WEAPON_TEC9,
    WEAPON_FIVESEVEN,
    WEAPON_CZ75A,
    WEAPON_DEAGLE,

    WEAPON_MAC10,
    WEAPON_MP9,
    WEAPON_UMP45,
    WEAPON_BIZON,
    WEAPON_MP7,
    WEAPON_P90,

    WEAPON_NOVA,
    WEAPON_XM1014,
    WEAPON_SAWEDOFF,
    WEAPON_MAG7,
    WEAPON_M249,
    WEAPON_NEGEV,

    WEAPON_GALILAR,
    WEAPON_FAMAS,
    WEAPON_SSG08,
    WEAPON_AK47,
    WEAPON_M4A1,
    WEAPON_M4A1_SILENCER,
    WEAPON_SG556,
    WEAPON_AUG,
    WEAPON_AWP,
    WEAPON_G3SG1,
    WEAPON_SCAR20
};

/**
 * A randomly selected primary weapon for LOADOUT_RANDOM rounds.
 *
 * @return          Randomly selected primary weapon.
 */
CSWeapon GetRandomPrimary()
{
    return g_RandomPrimary;
}

/**
 * A randomly selected secondary weapon for LOADOUT_RANDOM rounds.
 *
 * @return          Randomly selected secondary weapon.
 */
CSWeapon GetRandomSecondary()
{
    return g_RandomSecondary;
}

/**
 * Randomly selects a primary and secondary weapon for LOADOUT_RANDOM rounds.
 *
 * @noreturn
 */
void SelectRandomWeapon()
{
    CSWeapon weapon = g_RandomWeapons[GetRandomInt(0, sizeof(g_RandomWeapons) - 1)];

    if ( GetWeaponCategory( weapon ) == WCAT_PISTOL )
    {
        g_RandomPrimary = WEAPON_NONE;
        g_RandomSecondary = weapon;
    }
    else
    {
        g_RandomPrimary = weapon;
        g_RandomSecondary = WEAPON_NONE;
    }
}

/**
 * Records which clients were allocated an AWP in the previous round.
 */
bool g_WasSniper[MAXPLAYERS+1];

/**
 * Checks to see if the given client was allocated an AWP in the previous round.
 *
 * @param client    Client to check.
 * @return          True if the given client was allocated an AWP in the last round.
 */
bool GetWasSniper( int client )
{
    return g_WasSniper[client];
}

/**
 * Sets whether the given client was allocated an AWP in the previous round.
 *
 * @param client    Client to set whether they were an AWPer.
 * @param value     True if the client was an AWPer, false if not.
 * @noreturn
 */
void SetWasSniper( int client, bool value )
{
    g_WasSniper[client] = value;
}

/**
 * Randomly selects a player from the given list of clients to
 * give an AWP, or -1 if no players have opted in to AWP rounds.
 *
 * @param players   List of client indexes.
 * @param team      Team of the list of players.
 * @return          Client index of the chosen AWP player, or -1.
 */
int ChooseSniperPlayer( ArrayList players, int team )
{
    int sniper = -1;
    int bestScore = -1;
    int count = GetArraySize( players );

    for ( int i = 0; i < count; i++ )
    {
        int client = GetArrayCell( players, i );

        bool wasSniper = GetWasSniper( client );
        SetWasSniper( client, false );

        if ( !GetSniperFlag( client, team, SNIPER_ENABLED ) ) continue;
        if ( count == 1 && GetSniperFlag( client, team, SNIPER_NEVERALONE ) ) continue;
        if ( wasSniper && GetSniperFlag( client, team, SNIPER_SOMETIMES ) ) continue;

        int score = GetRandomInt( 0, 65535 );

        if ( score > bestScore )
        {
            sniper = client;
            bestScore = score;
        }
    }

    if ( sniper != -1 )
    {
        SetWasSniper( sniper, true );
    }

    return sniper;
}

/**
 * Decides if there should be a T-side force buy round.
 *
 * @param loadout   Current loadout type.
 * @param tPlayers  List of Terrorist clients.
 * @param ctPlayers List of Counter-Terrorist clients.
 * @return          True if there should be a T-side force buy round.
 */
bool ShouldHaveTerroristForceRound( RTLoadout loadout, ArrayList tPlayers, ArrayList ctPlayers )
{
    return loadout == LOADOUT_FORCE && GetArraySize( tPlayers ) == GetArraySize( ctPlayers )
        && GetRandomInt( 0, 99 ) < GetTerroristForceProbability();
}

/**
 * Handles allocating weapons to both teams.
 *
 * @param tPlayers  List of Terrorist clients.
 * @param ctPlayers List of Counter-Terrorist clients.
 * @param bombsite  Bombsite to be retaken.
 * @noreturn
 */
void WeaponAllocator( ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite )
{
    RTLoadout loadout = GetLoadout();

    RTLoadout tLoadout = loadout;
    RTLoadout ctLoadout = loadout;

    if ( ShouldHaveTerroristForceRound( loadout, tPlayers, ctPlayers ) )
    {
        tLoadout = LOADOUT_FORCE;
    }

    int tSniper = -1;
    int ctSniper = -1;

    if ( tLoadout == LOADOUT_FULL ) tSniper = ChooseSniperPlayer( tPlayers, CS_TEAM_T );
    if ( ctLoadout == LOADOUT_FULL ) ctSniper = ChooseSniperPlayer( ctPlayers, CS_TEAM_CT );

    if ( loadout == LOADOUT_RANDOM )
    {
        SelectRandomWeapon();
    }

    int tCount = GetArraySize( tPlayers );
    int ctCount = GetArraySize( ctPlayers );

    if ( tLoadout == LOADOUT_FORCE && ctLoadout == LOADOUT_FULL )
    {
        Retakes_MessageToAll( "Terrorist Force Buy round!" );
    }
    else
    {
        char loadoutName[32];
        GetLoadoutName( loadout, loadoutName, sizeof(loadoutName) );
        Retakes_MessageToAll( "%s round!", loadoutName );
    }

    for ( int i = 0; i < tCount; i++ )
    {
        int client = GetArrayCell( tPlayers, i );
        HandleLoadout( client, CS_TEAM_T, client == tSniper ? LOADOUT_SNIPER : tLoadout );
    }

    for ( int i = 0; i < ctCount; i++ )
    {
        int client = GetArrayCell(ctPlayers, i);
        HandleLoadout( client, CS_TEAM_CT, client == ctSniper ? LOADOUT_SNIPER : ctLoadout );
    }
}

/**
 * Handles allocating weapons for a specific client.
 *
 * @param client    Client to allocate weapons to.
 * @param team      Team that the client will spawn as.
 * @param loadout   Loadout chosen for this client.
 * @noreturn
 */
void HandleLoadout( int client, int team, RTLoadout loadout )
{
    char primary[WEAPON_STRING_LENGTH];
    char secondary[WEAPON_STRING_LENGTH];
    char nades[NADE_STRING_LENGTH];
    int health = 100;
    int kevlar = 100;
    bool helmet = true;
    bool kit = true;

    primary = "";
    secondary = "";
    nades = "";

    if ( loadout == LOADOUT_RANDOM )
    {
        GetWeaponClassName( GetRandomPrimary(), primary, sizeof(primary) );
        GetWeaponClassName( GetRandomSecondary(), secondary, sizeof(secondary) );
    }
    else
    {
        GetWeaponClassName( GetPrimary( client, team, loadout ), primary, sizeof(primary) );
        GetWeaponClassName( GetSecondary( client, team, loadout ), secondary, sizeof(secondary) );
        
        int remaining = GetStartMoney( loadout ) - GetLoadoutCost( client, team, loadout );
        
        if ( remaining > GetMaxNadeValue( team, loadout ) ) remaining = GetMaxNadeValue( team, loadout );

        FillGrenades( team, loadout, remaining, nades, sizeof(nades) );

        kevlar = GetKevlar( client, team, loadout ) ? 100 : 0;
        helmet = GetHelmet( client, team, loadout );
        kit = GetDefuse( client, team, loadout );
    }

    Retakes_SetPlayerInfo( client, primary, secondary, nades, health, kevlar, helmet, kit );
}
