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

    g_CurrentlyDefusing = false;

    float timeRemaining = g_DefuseEndTime - GetGameTime();
    if ( timeRemaining > 0.0 )
    {
        char defuserName[64];
        GetClientName( victim, defuserName, sizeof(defuserName) );

        char timeString[32];
        FloatToStringFixedPoint( timeRemaining, 2, timeString, sizeof(timeString) );

        Retakes_MessageToAll( "%t", "DefuserDiedTimeLeftMessage", defuserName, timeString );

        if ( timeRemaining < 1.0 )
        {
            Oof( victim, 1.0 - timeRemaining, 0.5 );
        }
    }
    else
    {
        char attackerName[64];
        GetClientName( attacker, attackerName, sizeof(attackerName) );

        char timeString[32];
        FloatToStringFixedPoint( -timeRemaining, 2, timeString, sizeof(timeString) );
        
        Retakes_MessageToAll( "%t", "PostDefuseKillTimeMessage", attackerName, timeString );

        if ( -timeRemaining < 1.0 )
        {
            Oof( attacker, 1.0 + timeRemaining, 0.5 );
        }
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

    float timeRemaining = g_DetonateTime - g_DefuseEndTime;

    if ( timeRemaining < 0.0 )
    {
        timeRemaining = 0.0;
    }

    if ( GetGameTime() < g_DefuseEndTime - 0.25 )
    {
        Retakes_MessageToAll( "%t", "InstantDefuse" );
    }

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

    if ( g_DefuseEndTime < g_DetonateTime - GetInstantDefuseMargin() )
    {
        CreateTimer( 0.1, BombTime_InstantDefuseTest );
    }
}

bool BombTime_AnyLiveGrenadesOfClass( char[] classname, bool allowIfStationary = false, float minDistance = 8192.0 )
{
    float clientOrigin[3];
    float vec[3];

    if ( !IsClientValidAndInGame( g_DefusingClient ) )
    {
        return false;
    }

    GetClientAbsOrigin( g_DefusingClient, clientOrigin );

    const float VELOCITY_ERROR = 0.001;

    float minDistance2 = minDistance * minDistance;

    int ent = -1;
    while ( (ent = FindEntityByClassname( ent, classname )) != -1 )
    {
        if ( !IsValidEntity( ent ) ) continue;

        GetEntPropVector( ent, Prop_Data, "m_vecOrigin", vec );

        vec[0] -= clientOrigin[0];
        vec[1] -= clientOrigin[1];
        vec[2] -= clientOrigin[2];

        float dist2 = vec[0] * vec[0] + vec[1] * vec[1] + vec[2] * vec[2];

        if ( dist2 <= minDistance2 ) return true;

        if ( !allowIfStationary ) continue;

        GetEntPropVector( ent, Prop_Data, "m_vecVelocity", vec );

        if ( FloatAbs( vec[0] ) <= VELOCITY_ERROR
            && FloatAbs( vec[1] ) <= VELOCITY_ERROR
            && FloatAbs( vec[2] ) <= VELOCITY_ERROR )
        {
            continue;
        }

        return true;
    }

    return false;
}

bool BombTime_AnyLiveGrenades() 
{
    return BombTime_AnyLiveGrenadesOfClass( "flashbang_projectile", true ) ||
        BombTime_AnyLiveGrenadesOfClass( "decoy_projectile", true, 128.0 ) ||
        BombTime_AnyLiveGrenadesOfClass( "hegrenade_projectile" ) ||
        BombTime_AnyLiveGrenadesOfClass( "molotov_projectile" ) ||
        BombTime_AnyLiveGrenadesOfClass( "smokegrenade_projectile", true, 0.0 ) ||
        // the smoke screen will be ignored for this
        BombTime_AnyLiveGrenadesOfClass( "inferno", false, 512.0 ); // fire from molotov/incendiary
}

Action BombTime_InstantDefuseTest( Handle timer )
{
    int bomb = FindEntityByClassname( -1, "planted_c4" );
    if ( bomb == -1 || !g_CurrentlyDefusing ) return;

    if ( !BombTime_AnyLivingTerrorists() && !BombTime_AnyLiveGrenades() )
    {
        SetEntPropFloat( bomb, Prop_Send, "m_flDefuseLength", g_DefuseTime, 0 );
        SetEntPropFloat( bomb, Prop_Send, "m_flDefuseCountDown", GetGameTime() + g_DefuseTime, 0 );
        return;
    }

    CreateTimer( 0.1, BombTime_InstantDefuseTest );
}

void BombTime_BombAbortDefuse( Event event )
{
    g_CurrentlyDefusing = false;
}

void BombTime_BombExploded( Event event )
{
    float timeRemaining = g_DefuseEndTime - g_DetonateTime;

    g_CurrentlyDefusing = false;

    if ( IsClientValidAndInGame( g_DefusingClient ) && timeRemaining >= 0.0 )
    {
        char defuserName[64];
        GetClientName( g_DefusingClient, defuserName, sizeof(defuserName) );

        char timeString[32];
        FloatToStringFixedPoint( timeRemaining, 2, timeString, sizeof(timeString) );

        Retakes_MessageToAll( "%t", "BombExplodedTimeLeftMessage", defuserName, timeString );

        if ( timeRemaining < 1.0 )
        {
            Oof( g_DefusingClient, 1.0 - timeRemaining, 1.0 );
        }
    }
}

bool BombTime_AnyLivingTerrorists()
{
    for ( int client = 1; client <= MaxClients; ++client )
    {
        if ( !IsClientValidAndInGame( client ) ) continue;

        int team = GetClientTeam( client );
        if ( team != CS_TEAM_T ) continue;

        if ( IsPlayerAlive( client ) ) return true;    
    }
    return false;
}