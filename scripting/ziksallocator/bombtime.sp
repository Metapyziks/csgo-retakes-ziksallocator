float g_DetonateTime = 0.0;
float g_DefuseEndTime = 0.0;
int g_DefusingClient = -1;
bool g_CurrentlyDefusing = false;
float g_DefuseTime = 0.4;

void BombTime_PlayerDeath( Event event )
{
    int victim = GetClientOfUserId( event.GetInt( "userid" ) );
    int attacker = GetClientOfUserId( event.GetInt( "attacker" ) );

    if ( g_DefusingClient != victim || !g_CurrentlyDefusing ) return;
    if ( !IsClientValidAndInGame( victim ) ) return;
    if ( !IsClientValidAndInGame( attacker ) ) return;

    float timeRemaining = g_DefuseEndTime - GetGameTime();
    if ( timeRemaining > 0.0 )
    {
        char defuserName[64];
        GetClientName( victim, defuserName, sizeof(defuserName) );

        char timeString[32];
        FloatToStringFixedPoint( timeRemaining, 2, timeString, sizeof(timeString) );

        Retakes_MessageToAll( "%t", "DefuserDiedTimeLeftMessage", defuserName, timeString );
    }
    else
    {
        char attackerName[64];
        GetClientName( attacker, attackerName, sizeof(attackerName) );

        char timeString[32];
        FloatToStringFixedPoint( -timeRemaining, 2, timeString, sizeof(timeString) );
        
        Retakes_MessageToAll( "%t", "PostDefuseKillTimeMessage", attackerName, timeString );
    }
}

void BombTime_BombBeginPlant( Event event )
{
    if ( !Retakes_Enabled() ) return;

    int bomb = FindEntityByClassname( -1, "weapon_c4" );
    if ( bomb != -1 )
    {
        float armedTime = GetEntPropFloat( bomb, Prop_Send, "m_fArmedTime", 0 );
        SetEntPropFloat( bomb, Prop_Send, "m_fArmedTime", armedTime - 3, 0 );
    }
}

void BombTime_BombPlanted( Event event )
{
    g_DetonateTime = GetGameTime() + GetC4Timer();
    g_DefusingClient = -1;
    g_CurrentlyDefusing = false;
}

void BombTime_BombDefused( Event event )
{
    int defuser = GetClientOfUserId( event.GetInt( "userid" ) );

    if ( !IsClientValidAndInGame( defuser ) ) return;

    float timeRemaining = g_DetonateTime - GetGameTime();

    char defuserName[64];
    GetClientName( defuser, defuserName, sizeof(defuserName) );

    char timeString[32];
    FloatToStringFixedPoint( timeRemaining, 2, timeString, sizeof(timeString) );

    Retakes_MessageToAll( "%t", "SuccessfulDefuseTimeLeftMessage", defuserName, timeString );
}

void BombTime_BombBeginDefuse( Event event )
{
    int defuser = GetClientOfUserId( event.GetInt( "userid" ) );
    bool hasKit = event.GetBool( "haskit" );

    float endTime = GetGameTime() + (hasKit ? 5.0 : 10.0);
    
    g_CurrentlyDefusing = true;

    if ( g_DefusingClient == -1 || g_DefuseEndTime < g_DetonateTime )
    {   
        g_DefuseEndTime = endTime;
        g_DefusingClient = defuser;
    }

    if ( g_DefuseEndTime < g_DetonateTime )
    {
        int bomb = FindEntityByClassname( -1, "planted_c4" );
        if ( bomb == -1 )
        {
            Retakes_MessageToAll( "Unable to find bomb!" );
        }
        else if ( BombTime_AnyLivingTerrorists() )
        {
            Retakes_MessageToAll( "At least one terrorist is alive!" );
        }
        else if ( BombTime_AnyLiveGrenades() )
        {
            Retakes_MessageToAll( "At least one grenade is active!" );            
        }
        else       
        {
            CreateTimer( 0.1, BombTime_DefuseTimeDebug );
        }
    }
}

/*
    flashbang_projectile
    decoy_projectile
    hegrenade_projectile
    molotov_projectile
    smokegrenade_projectile
    tagrenade_projectile
    inferno
*/

bool BombTime_AnyLiveGrenadesOfClass( char[] classname )
{
    int ent;
    while ( (ent = FindEntityByClassname( -1, classname )) != -1 )
    {
        if ( IsValidEntity( ent ) ) return true;                
    }

    return false;
}

bool BombTime_AnyLiveGrenades() 
{   
    return (BombTime_AnyLiveGrenadesOfClass("flashbang_projectile") ||
            BombTime_AnyLiveGrenadesOfClass("decoy_projectile") ||
            BombTime_AnyLiveGrenadesOfClass("hegrenade_projectile") ||
            BombTime_AnyLiveGrenadesOfClass("molotov_projectile") ||
            BombTime_AnyLiveGrenadesOfClass("smokegrenade_projectile") ||
            BombTime_AnyLiveGrenadesOfClass("flashbang_projectile") ||
            BombTime_AnyLiveGrenadesOfClass("inferno")); // fire from molotov/incendiary
}

Action BombTime_DefuseTimeDebug( Handle timer )
{
    int bomb = FindEntityByClassname( -1, "planted_c4" );
    if ( bomb == -1 || !g_CurrentlyDefusing ) return;

    SetEntPropFloat( bomb, Prop_Send, "m_flDefuseLength", g_DefuseTime, 0 );
    SetEntPropFloat( bomb, Prop_Send, "m_flDefuseCountDown", GetGameTime() + g_DefuseTime, 0 );

    float defuseLength = GetEntPropFloat( bomb, Prop_Send, "m_flDefuseLength", 0 );
    float defuseCountDown = GetEntPropFloat( bomb, Prop_Send, "m_flDefuseCountDown", 0 );

    Retakes_MessageToAll( "m_flDefuseLength = %f, m_flDefuseCountDown = %f, GetGameTime() = %f", defuseLength, defuseCountDown, GetGameTime() );
}

void BombTime_BombAbortDefuse( Event event )
{
    int defuser = GetClientOfUserId( event.GetInt( "userid" ) );

    if ( g_DefusingClient == defuser )
    {
        g_CurrentlyDefusing = false;
    }
}

void BombTime_BombExploded( Event event )
{
    float timeRemaining = g_DefuseEndTime - g_DetonateTime;

    if ( IsClientValidAndInGame( g_DefusingClient ) && timeRemaining >= 0.0 )
    {
        char defuserName[64];
        GetClientName( g_DefusingClient, defuserName, sizeof(defuserName) );

        char timeString[32];
        FloatToStringFixedPoint( timeRemaining, 2, timeString, sizeof(timeString) );

        Retakes_MessageToAll( "%t", "BombExplodedTimeLeftMessage", defuserName, timeString );
    }
}

bool BombTime_AnyLivingTerrorists()
{
    for ( int client = 1; client <= MaxClients; ++client )
    {
        if ( !IsClientValidAndInGame( client ) || !IsOnTeam( client ) ) continue;

        int team = GetClientTeam( client );
        if ( team != CS_TEAM_T ) continue;

        if ( IsPlayerAlive( client ) ) return true;    
    }
    return false;
}