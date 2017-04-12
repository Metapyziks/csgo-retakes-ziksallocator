float g_LastMoveTime[MAXPLAYERS+1];
bool g_AliveLastRound[MAXPLAYERS+1];

float g_RoundStartTime = 0.0;
int g_RoundPlayerCount = 0;

void Afk_OnClientConnected( int client )
{
    g_LastMoveTime[client] = GetGameTime();
}

void Afk_OnPlayerInput( int client, int buttons, int mouse[2] )
{
    if ( !IsClientValidAndInGame( client ) ) return;

    bool moved = buttons != 0;
    bool looked = mouse[0] != 0 || mouse[1] != 0;

    if ( moved || looked )
    {
        g_LastMoveTime[client] = GetGameTime();
    }
}

void Afk_OnRoundStart()
{
    g_RoundStartTime = GetGameTime();
    g_RoundPlayerCount = 0;

    for ( int client = 1; client <= MaxClients; ++client )
    {
        g_AliveLastRound[client] = false;

        if ( !IsClientValidAndInGame( client ) || !IsOnTeam( client ) ) continue;

        int team = GetClientTeam( client );
        if ( team != CS_TEAM_T && team != CS_TEAM_CT ) continue;

        g_AliveLastRound[client] = true;
        ++g_RoundPlayerCount;
    }
}

void Afk_ForceSpectate( int client )
{
    if ( !IsClientValidAndInGame( client ) ) return;

    char clientName[64];
    GetClientName( client, clientName, sizeof(clientName) );
    
    Retakes_MessageToAll( "Moving {GREEN}%s{NORMAL} to spectator team for being AFK.", clientName );

    CS_SwitchTeam( client, CS_TEAM_SPEC );
}

void Afk_OnRoundEnd()
{
    float roundLength = GetGameTime() - g_RoundStartTime;
    if ( roundLength < 10.0 ) return;

    if ( g_RoundPlayerCount < 3 ) return;

    for ( int client = 1; client <= MaxClients; ++client )
    {
        bool wasAlive = g_AliveLastRound[client];

        if ( !IsClientValidAndInGame( client ) || !IsOnTeam( client ) || !wasAlive ) continue;

        int team = GetClientTeam( client );
        if ( team != CS_TEAM_T && team != CS_TEAM_CT ) continue;

        if ( g_LastMoveTime[client] < g_RoundStartTime )
        {
            Afk_ForceSpectate( client );
        }
    }
}