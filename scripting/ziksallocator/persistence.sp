/**
 * Client cookie storing kevlar preferences.
 */
Handle g_KevlarCookie = INVALID_HANDLE;

/**
 * Client cookie storing helmet preferences.
 */
Handle g_HelmetCookie = INVALID_HANDLE;

/**
 * Client cookie storing defuse kit preferences.
 */
Handle g_DefuseCookie = INVALID_HANDLE;

/**
 * Client cookie storing AWP round preferences.
 */
Handle g_SniperCookie = INVALID_HANDLE;

/**
 * Client cookie storing primary weapon preferences.
 */
Handle g_PrimaryCookie = INVALID_HANDLE;

/**
 * Client cookie storing secondary weapon preferences.
 */
Handle g_SecondaryCookie = INVALID_HANDLE;

/**
 * Records whether cookies have been loaded for each client.
 */
bool g_LoadedCookies[MAXPLAYERS+1];

/**
 * Registers all required client cookies.
 *
 * @noreturn
 */
void SetupClientCookies()
{
    if ( g_KevlarCookie != INVALID_HANDLE ) return;

    g_KevlarCookie = RegClientCookie( "retakes_ziks_kevlar", "Kevlar preferences", CookieAccess_Protected );
    g_HelmetCookie = RegClientCookie( "retakes_ziks_helmet", "Helmet preferences", CookieAccess_Protected );
    g_DefuseCookie = RegClientCookie( "retakes_ziks_defuse", "Defuse preferences", CookieAccess_Protected );
    g_SniperCookie = RegClientCookie( "retakes_ziks_sniper", "Sniper preferences", CookieAccess_Protected );

    g_PrimaryCookie = RegClientCookie( "retakes_ziks_primary", "Primary preferences", CookieAccess_Protected );
    g_SecondaryCookie = RegClientCookie( "retakes_ziks_secondary", "Secondary preferences", CookieAccess_Protected );
}

/**
 * Marks this client as not having loaded loadout cookies yet.
 *
 * @param client    Client to invalidate the loaded cookies of.
 * @noreturn
 */
void InvalidateLoadedCookies( int client )
{
    g_LoadedCookies[client] = false;
}

/**
 * Tests to see if loadouts have been restored from cookies for the
 * given client yet, and attempts to load them if not.
 *
 * @param client    Client to check for loadout cookies for.
 * @return          True if cookies were either previously loaded or
 *                  if they were loaded just now, false otherwise.
 */
bool CheckForSavedLoadouts( int client )
{
    if ( g_LoadedCookies[client] ) return true;
    if ( IsFakeClient( client ) ) return false;

    if ( !AreClientCookiesCached( client ) ) return false;

    g_LoadedCookies[client] = true;
    RestoreLoadouts( client );

    return true;
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

    EncodeBoolArray( g_Kevlar[client], sizeof(g_Kevlar[]), buffer, sizeof(buffer) );
    SetClientCookie( client, g_KevlarCookie, buffer );

    EncodeBoolArray( g_Helmet[client], sizeof(g_Helmet[]), buffer, sizeof(buffer) );
    SetClientCookie( client, g_HelmetCookie, buffer );

    EncodeBoolArray( g_Defuse[client], sizeof(g_Defuse[]), buffer, sizeof(buffer) );
    SetClientCookie( client, g_DefuseCookie, buffer );

    EncodeBoolArray( g_Sniper[client], sizeof(g_Sniper[]), buffer, sizeof(buffer) );
    SetClientCookie( client, g_SniperCookie, buffer );

    EncodeWeaponArray( g_Primary[client], sizeof(g_Primary[]), buffer, sizeof(buffer) );
    SetClientCookie( client, g_PrimaryCookie, buffer );

    EncodeWeaponArray( g_Secondary[client], sizeof(g_Secondary[]), buffer, sizeof(buffer) );
    SetClientCookie( client, g_SecondaryCookie, buffer );
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

    GetClientCookie( client, g_KevlarCookie, buffer, sizeof(buffer) );
    DecodeBoolArray( g_Kevlar[client], sizeof(g_Kevlar[]), buffer );

    GetClientCookie( client, g_HelmetCookie, buffer, sizeof(buffer) );
    DecodeBoolArray( g_Helmet[client], sizeof(g_Helmet[]), buffer );

    GetClientCookie( client, g_DefuseCookie, buffer, sizeof(buffer) );
    DecodeBoolArray( g_Defuse[client], sizeof(g_Defuse[]), buffer );

    GetClientCookie( client, g_SniperCookie, buffer, sizeof(buffer) );
    DecodeBoolArray( g_Sniper[client], sizeof(g_Sniper[]), buffer );

    GetClientCookie( client, g_PrimaryCookie, buffer, sizeof(buffer) );
    DecodeWeaponArray( g_Primary[client], sizeof(g_Primary[]), buffer );

    GetClientCookie( client, g_SecondaryCookie, buffer, sizeof(buffer) );
    DecodeWeaponArray( g_Secondary[client], sizeof(g_Secondary[]), buffer );

    return true;
}
