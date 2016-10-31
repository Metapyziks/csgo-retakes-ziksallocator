/**
 * Client cookie storing kevlar preferences.
 */
Handle g_hKevlarCookie = INVALID_HANDLE;

/**
 * Client cookie storing helmet preferences.
 */
Handle g_hHelmetCookie = INVALID_HANDLE;

/**
 * Client cookie storing defuse kit preferences.
 */
Handle g_hDefuseCookie = INVALID_HANDLE;

/**
 * Client cookie storing AWP round preferences.
 */
Handle g_hSniperCookie = INVALID_HANDLE;

/**
 * Client cookie storing primary weapon preferences.
 */
Handle g_hPrimaryCookie = INVALID_HANDLE;

/**
 * Client cookie storing secondary weapon preferences.
 */
Handle g_hSecondaryCookie = INVALID_HANDLE;

bool g_bLoadedCookies[MAXPLAYERS+1];

/**
 * Registers all required client cookies.
 *
 * @noreturn
 */
void SetupClientCookies()
{
    if ( g_hKevlarCookie != INVALID_HANDLE ) return;

    g_hKevlarCookie = RegClientCookie( "retakes_ziks_kevlar", "Kevlar preferences", CookieAccess_Protected );
    g_hHelmetCookie = RegClientCookie( "retakes_ziks_helmet", "Helmet preferences", CookieAccess_Protected );
    g_hDefuseCookie = RegClientCookie( "retakes_ziks_defuse", "Defuse preferences", CookieAccess_Protected );
    g_hSniperCookie = RegClientCookie( "retakes_ziks_sniper", "Sniper preferences", CookieAccess_Protected );

    g_hPrimaryCookie = RegClientCookie( "retakes_ziks_primary", "Primary preferences", CookieAccess_Protected );
    g_hSecondaryCookie = RegClientCookie( "retakes_ziks_secondary", "Secondary preferences", CookieAccess_Protected );
}

void InvalidateLoadedCookies( int client )
{
    g_bLoadedCookies[client] = false;
}

void CheckForSavedLoadouts( int client )
{
    if ( IsFakeClient( client ) ) return;
    if ( g_bLoadedCookies[client] ) return;

    if ( AreClientCookiesCached( client ) )
    {
        g_bLoadedCookies[client] = true;
        RestoreLoadouts( client );
    }
}

/**
 * Stores all loadout preferences for the given client in cookies.
 *
 * @param client    Client to save loadout preferences for.
 * @noreturn
 */
void SaveLoadouts( int client )
{
    if ( IsFakeClient( client ) ) return;

    char buffer[64];

    EncodeTeamLoadoutBools( g_Kevlar[client], buffer, sizeof(buffer) );
    SetClientCookie( client, g_hKevlarCookie, buffer );

    EncodeTeamLoadoutBools( g_Helmet[client], buffer, sizeof(buffer) );
    SetClientCookie( client, g_hHelmetCookie, buffer );

    EncodeLoadoutBools( g_Defuse[client], buffer, sizeof(buffer) );
    SetClientCookie( client, g_hDefuseCookie, buffer );

    EncodeTeamBools( g_Sniper[client], buffer, sizeof(buffer) );
    SetClientCookie( client, g_hSniperCookie, buffer );

    EncodeWeapons( g_Primary[client], buffer, sizeof(buffer) );
    SetClientCookie( client, g_hPrimaryCookie, buffer );

    EncodeWeapons( g_Secondary[client], buffer, sizeof(buffer) );
    SetClientCookie( client, g_hSecondaryCookie, buffer );
}

/**
 * Loads all loadout preferences for the given client from cookies.
 *
 * @param client    Client to load loadout preferences for.
 * @return          True if loadout preferences were loaded.
 */
bool RestoreLoadouts( int client )
{
    ResetAllLoadouts( client );
    
    if ( IsFakeClient( client ) ) return false;
    if ( !AreClientCookiesCached( client ) ) return false;

    char buffer[64];

    GetClientCookie( client, g_hKevlarCookie, buffer, sizeof(buffer) );
    DecodeTeamLoadoutBools( g_Kevlar[client], buffer );

    GetClientCookie( client, g_hHelmetCookie, buffer, sizeof(buffer) );
    DecodeTeamLoadoutBools( g_Helmet[client], buffer );

    GetClientCookie( client, g_hDefuseCookie, buffer, sizeof(buffer) );
    DecodeLoadoutBools( g_Defuse[client], buffer );

    GetClientCookie( client, g_hSniperCookie, buffer, sizeof(buffer) );
    DecodeTeamBools( g_Sniper[client], buffer );

    GetClientCookie( client, g_hPrimaryCookie, buffer, sizeof(buffer) );
    DecodeWeapons( g_Primary[client], buffer );

    GetClientCookie( client, g_hSecondaryCookie, buffer, sizeof(buffer) );
    DecodeWeapons( g_Secondary[client], buffer );

    return true;
}
