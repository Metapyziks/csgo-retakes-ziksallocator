/**
 * Chooses a loadout type for the next round.
 *
 * @return          Loadout type selected for the next round.
 */
RTLoadout GetLoadout()
{
    int rand = GetRandomInt( 0, 99 );
    int pistolChance = GetLoadoutTypeProbability( LOADOUT_PISTOL );
    int forceChance = GetLoadoutTypeProbability( LOADOUT_PISTOL );

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

    int tSniper = -1; 
    int ctSniper = -1;

    if ( loadout == LOADOUT_FULL )
    {
        tSniper = ChooseSniperPlayer( tPlayers, CS_TEAM_T );
        ctSniper = ChooseSniperPlayer( ctPlayers, CS_TEAM_CT );
    }

    int tCount = GetArraySize( tPlayers );
    int ctCount = GetArraySize( ctPlayers );

    for ( int i = 0; i < tCount; i++ )
    {
        int client = GetArrayCell( tPlayers, i );
        HandleLoadout( client, CS_TEAM_T, client == tSniper ? LOADOUT_SNIPER : loadout );
    }

    for ( int i = 0; i < ctCount; i++ )
    {
        int client = GetArrayCell(ctPlayers, i);
        HandleLoadout( client, CS_TEAM_CT, client == ctSniper ? LOADOUT_SNIPER : loadout );
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

    GetWeaponClassName( GetPrimary( client, team, loadout ), primary, sizeof(primary) );
    GetWeaponClassName( GetSecondary( client, team, loadout ), secondary, sizeof(secondary) );

    int remaining = GetStartMoney( loadout ) - GetLoadoutCost( client, team, loadout );
    
    if ( remaining > GetMaxNadeValue( team, loadout ) ) remaining = GetMaxNadeValue( team, loadout );

    FillGrenades( team, loadout, remaining, nades, sizeof(nades) );

    health = 100;
    kevlar = GetKevlar( client, team, loadout ) ? 100 : 0;
    helmet = GetHelmet( client, team, loadout );
    kit = GetDefuse( client, team, loadout );

    Retakes_SetPlayerInfo( client, primary, secondary, nades, health, kevlar, helmet, kit );
}
