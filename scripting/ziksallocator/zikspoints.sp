Handle g_ZiksPointsCookie = INVALID_HANDLE;

int g_ZiksPoints[MAXPLAYERS+1];
bool g_ZiksPointsLoaded[MAXPLAYERS+1];

void ZiksPoints_SetupClientCookies()
{
    if ( g_ZiksPointsCookie != INVALID_HANDLE ) return;

    g_ZiksPointsCookie = RegClientCookie( "retakes_ziks_points", "Ziks points", CookieAccess_Protected );
}

void ZiksPoints_OnClientConnected()
{
    g_ZiksPoints[client] = 0;
    g_ZiksPointsLoaded[client] = false;
}

bool ZiksPointsLoaded( int client )
{
    return IsClientValidAndInGame( client ) && g_ZiksPointsLoaded[client];
}

void SaveZiksPoints( int client )
{
    if ( !IsClientValidAndInGame( client ) || IsFakeClient( client ) ) return;

    char buffer[16];
    IntToString( g_ZiksPoints[client], buffer, sizeof(buffer) );

    SetClientCookie( client, g_ZiksPointsCookie, buffer );
}

void RestoreZiksPoints( int client )
{
    if ( !IsClientValidAndInGame( client ) || IsFakeClient( client ) || !AreClientCookiesCached( client ) ) return;
    if ( g_ZiksPointsLoaded[client] ) return;

    char buffer[16];
    GetClientCookie( client, g_ZiksPointsCookie, buffer, sizeof(buffer) );

    g_ZiksPoints[client] = StringToInt( buffer );
    g_ZiksPointsLoaded[client] = true;
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
}

void ZiksPoints_Deduct( int client, int points )
{
    if ( points <= 0 ) return;
    if ( !IsClientValidAndInGame( client ) ) return;
    if ( !ZiksPointsLoaded( client ) ) RestoreZiksPoints( client );
}
