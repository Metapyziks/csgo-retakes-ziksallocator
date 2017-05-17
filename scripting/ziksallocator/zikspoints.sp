Handle g_ZiksPointsCookie = INVALID_HANDLE;

int g_ZiksPoints[MAXPLAYERS+1];
bool g_ZiksPointsLoaded[MAXPLAYERS+1];
bool g_ZiksPointsModified[MAXPLAYERS+1];

void ZiksPoints_SetupClientCookies()
{
    if ( g_ZiksPointsCookie != INVALID_HANDLE ) return;

    g_ZiksPointsCookie = RegClientCookie( "retakes_ziks_points", "Ziks points", CookieAccess_Protected );
}

void ZiksPoints_OnClientConnected( int client )
{
    g_ZiksPoints[client] = 0;
    g_ZiksPointsLoaded[client] = false;
    g_ZiksPointsModified[client] = false;
}

void ZiksPoints_OnClientDisconnect( int client )
{
    SaveZiksPoints( client );
}

bool ZiksPointsLoaded( int client )
{
    return IsClientValidAndInGame( client ) && g_ZiksPointsLoaded[client];
}

void SaveZiksPoints( int client )
{
    if ( !IsClientValidAndInGame( client ) || !g_ZiksPointsModified[client] ) return;

    char buffer[16];
    IntToString( g_ZiksPoints[client], buffer, sizeof(buffer) );

    SetClientCookie( client, g_ZiksPointsCookie, buffer );
    g_ZiksPointsModified[client] = false;
}

void RestoreZiksPoints( int client )
{
    if ( !IsClientValidAndInGame( client ) || g_ZiksPointsLoaded[client] || !AreClientCookiesCached( client ) ) return;

    char buffer[16];
    GetClientCookie( client, g_ZiksPointsCookie, buffer, sizeof(buffer) );

    g_ZiksPoints[client] = StringToInt( buffer );
    g_ZiksPointsLoaded[client] = true;
    g_ZiksPointsModified[client] = false;
}

int ZiksPoints_Get( int client )
{
    if ( !IsClientValidAndInGame( client ) ) return 0;
    if ( !ZiksPointsLoaded( client ) ) RestoreZiksPoints( client );
    return g_ZiksPoints[client];
}

void ZiksPoints_Award( int client, int points )
{
    if ( points <= 0 ) return;
    if ( !IsClientValidAndInGame( client ) ) return;
    if ( !ZiksPointsLoaded( client ) ) RestoreZiksPoints( client );

    g_ZiksPoints[client] += points;
    g_ZiksPointsModified[client] = true;
    
    char clientName[64];
    GetClientName( client, clientName, sizeof(clientName) );

    char plural[2] = "s";
    if ( points == 1 ) plural[0] = 0;

    Retakes_MessageToAll( "{GREEN}%s{NORMAL} gained {LIGHT_RED}%i{NORMAL} clutch point%s! ({LIGHT_RED}%i{NORMAL} total)",
        clientName, points, plural, g_ZiksPoints[client] );
}

void ZiksPoints_Deduct( int client, int points )
{
    if ( points <= 0 ) return;
    if ( !IsClientValidAndInGame( client ) ) return;
    if ( !ZiksPointsLoaded( client ) ) RestoreZiksPoints( client );
    
    g_ZiksPoints[client] -= points;
    g_ZiksPointsModified[client] = true;

    char clientName[64];
    GetClientName( client, clientName, sizeof(clientName) );

    char plural[2] = "s";
    if ( points == 1 ) plural[0] = 0;

    Retakes_MessageToAll( "{GREEN}%s{NORMAL} lost {LIGHT_RED}%i{NORMAL} clutch point%s! ({LIGHT_RED}%i{NORMAL} total)",
        clientName, points, plural, g_ZiksPoints[client] );
}

void ZiksPoints_PlayerDeath( Event event )
{
    int victim = GetClientOfUserId( event.GetInt( "userid" ) );
    if ( !IsClientValidAndInGame( victim ) ) return;

    int attacker = GetClientOfUserId( event.GetInt( "attacker" ) );
    if ( !IsClientValidAndInGame( attacker ) ) return;

    bool teamKill = GetClientTeam( victim ) == GetClientTeam( attacker );
    if ( teamKill && victim != attacker )
    {
        ZiksPoints_Deduct( attacker, 1 );
    }
}
