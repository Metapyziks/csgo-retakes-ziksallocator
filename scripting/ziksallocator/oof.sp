
enum OofSound
{
    OOF_SOUND_OOF,
    OOF_SOUND_JON,
    OOF_SOUND_DONETHIS,

    OOF_SOUND_COUNT
}

Handle g_CVOofEnabled = INVALID_HANDLE;
Handle g_CVOofCooldown = INVALID_HANDLE;
Handle g_CVOofTimeDuration = INVALID_HANDLE;
Handle g_CVOofTimeEaseIn = INVALID_HANDLE;
Handle g_CVOofTimeEaseOut = INVALID_HANDLE;
Handle g_CVOofJonId = INVALID_HANDLE;

float g_LastOof[MAXPLAYERS+1];
float g_OofTime = -1.0;
float g_CurTimescale = 1.0;

void Oof_OnPluginStart()
{
    RegConsoleCmd( "sm_oof", Cmd_Oof );

    g_CVOofEnabled = CreateConVar( "sm_oof_enabled", "0", "Enables oofing.", FCVAR_NOTIFY );
    g_CVOofCooldown = CreateConVar( "sm_oof_cooldown", "10", "Time in seconds before a player can oof again.", FCVAR_NOTIFY );
    g_CVOofTimeDuration = CreateConVar( "sm_ooftime_duration", "1.5", "Time in seconds that OofTime should last.", FCVAR_NOTIFY );
    g_CVOofTimeEaseIn = CreateConVar( "sm_ooftime_easein", "0.125", "Time in seconds that OofTime eases in.", FCVAR_NOTIFY );
    g_CVOofTimeEaseOut = CreateConVar( "sm_ooftime_easeout", "1.0", "Time in seconds that OofTime eases out.", FCVAR_NOTIFY );
    g_CVOofJonId = CreateConVar( "sm_oof_jon_id", "334614586", "Steam3 ID for custom JON oof sound", FCVAR_NOTIFY );

    int flags = GetCommandFlags( "sv_cheats" );
    SetCommandFlags( "sv_cheats", flags & ~FCVAR_NOTIFY );
}

bool Oof_IsEnabled()
{
    return GetConVarInt( g_CVOofEnabled ) > 0;
}

int Oof_GetSoundPath( OofSound sound, char[] buffer, int maxLength )
{
    switch ( sound )
    {
        case OOF_SOUND_OOF:         return strcopy( buffer, maxLength, "ziks/test.mp3" );
        case OOF_SOUND_JON:         return strcopy( buffer, maxLength, "ziks/JON.mp3" );
        case OOF_SOUND_DONETHIS:    return strcopy( buffer, maxLength, "ziks/done-this.mp3" );
        default: return 0;
    }
}

float Oof_GetOofCooldown()
{
    return GetConVarFloat( g_CVOofCooldown );
}

float Oof_GetOofTimeDuration()
{
    return GetConVarFloat( g_CVOofTimeDuration );
}

float Oof_GetOofTimeEaseIn()
{
    return GetConVarFloat( g_CVOofTimeEaseIn );
}

float Oof_GetOofTimeEaseOut()
{
    return GetConVarFloat( g_CVOofTimeEaseOut );
}

int Oof_GetOofJonId()
{
    return GetConVarInt( g_CVOofJonId );
}

void Oof_OnMapStart()
{
    if ( !Oof_IsEnabled() )
    {
        return;
    }

    char buffer[64];
    char soundPath[64];

    int stringTable = FindStringTable( "soundprecache" );

    for ( int i = 0; i < view_as<int>(OOF_SOUND_COUNT); ++i )
    {
        Oof_GetSoundPath( view_as<OofSound>(i), soundPath, sizeof(soundPath) );

        Format( buffer, sizeof(buffer), "sound/%s", soundPath );
        AddFileToDownloadsTable( buffer );
        PrecacheSound( soundPath );

        Format( buffer, sizeof(buffer), "*%s", soundPath );
        AddToStringTable( stringTable, buffer );
    }

    for ( int client = 1; client <= MaxClients; ++client )
    {
        g_LastOof[client] = 0.0;
    }
}

void Oof_StartOofTime()
{
    g_OofTime = GetGameTime();
}

void Oof_OnGameFrame()
{
    if ( !Oof_IsEnabled() ) return;

    float duration = Oof_GetOofTimeDuration();

    if ( g_OofTime == -1 || duration <= 0 ) return;

    float gameTime = GetGameTime();
    float t = gameTime - g_OofTime;

    if ( t < 0 ) return;

    float easeIn = Oof_GetOofTimeEaseIn();
    float easeOut = Oof_GetOofTimeEaseOut();

    float timeScale = 0.5;

    if ( t < easeIn )
    {
        UpdateTimescale( 1.0 - (t / easeIn) * (1.0 - timeScale) );
        return;
    }

    t -= easeIn;

    if ( t < duration )
    {
        UpdateTimescale( timeScale );
        return;
    }

    t -= duration;

    if ( t > easeOut )
    {
        UpdateTimescale( 1.0 );
        return;
    }

    UpdateTimescale( timeScale + (t / easeOut) * (1.0 - timeScale) );
}

void UpdateTimescale( float value )
{
    if ( value != value ) return;
    if ( value == g_CurTimescale ) return;

    if ( g_CurTimescale == 1.0 )
    {
        ServerCommand( "sv_cheats 1" );
    }

    g_CurTimescale = value;

    char buffer[16];
    FloatToString( value, buffer, sizeof(buffer) );

    ServerCommand( "host_timescale \"%s\"", buffer );

    if ( value == 1.0 )
    {
        ServerCommand( "sv_cheats 0" );
    }
}

void Oof_PlayerDeath( Event event )
{
    if ( !Oof_IsEnabled() ) return;

    int victim = GetClientOfUserId( event.GetInt( "userid" ) );
    if ( !IsClientValidAndInGame( victim ) ) return;

    g_LastOof[victim] = 0.0;
}

public Action Cmd_Oof( int client, int args )
{
    if ( !Oof_IsEnabled() ) return Plugin_Handled;

    if ( !IsClientValidAndInGame( client ) )
    {
        return Plugin_Handled;
    }

    float lastOof = g_LastOof[client];
    float waitTime = lastOof + Oof_GetOofCooldown() - GetGameTime();

    if ( waitTime > 0 )
    {
        Retakes_Message( client, "You must wait {LIGHT_RED}%.1f{NORMAL} seconds to oof!", waitTime );
        return Plugin_Handled;
    }

    g_LastOof[client] = GetGameTime();

    float min = 0.0;
    float max = 0.0;

    char buffer[32];

    if ( args >= 1 )
    {
        GetCmdArg( 1, buffer, sizeof(buffer) );
        min = max = StringToFloat( buffer );
    }

    if ( args >= 2 )
    {
        GetCmdArg( 2, buffer, sizeof(buffer) );
        max = StringToFloat( buffer );
    }

    if ( max < min )
    {
        float temp = min;
        min = max;
        max = temp;
    }

    Oof( client, GetRandomFloat( min, max ) );
    return Plugin_Handled;
}

Action Oof_OnClientSayCommand( int client, const char[] command, const char[] args )
{
    if ( !Oof_IsEnabled() ) return Plugin_Continue;

    if ( strcmp( args[0], "oof", false ) == 0 )
    {
        ClientCommand( client, "sm_oof 0 0.2" );
    }
    else if ( strcmp( args[0], "big oof", false ) == 0 )
    {
        ClientCommand( client, "sm_oof 0.4 0.6" );
    }
    else if ( strcmp( args[0], "o o f", false ) == 0 )
    {
        ClientCommand( client, "sm_oof 0.8 1.0" );
    }

    return Plugin_Continue;
}

Action Timer_Oof( Handle timer, DataPack pack )
{
    pack.Reset();

    int client = pack.ReadCell();
    float oofness = pack.ReadFloat();
    int attacker = pack.ReadCell();
    bool doneThis = pack.ReadCell() > 0;

    Oof( client, oofness, 0.0, attacker, doneThis );

    CloseHandle( pack );
}

void Oof_EmitSound( OofSound sound, float pos[3], int client, float volume, int pitch )
{
    char buffer[64];
    char soundPath[64];

    Oof_GetSoundPath( sound, soundPath, sizeof(soundPath) );
    Format( buffer, sizeof(buffer), "*%s", soundPath );

    EmitAmbientSound( soundPath, pos, client, SNDLEVEL_GUNFIRE, SND_CHANGEVOL | SND_CHANGEPITCH, volume, pitch );
}

void Oof( int client, float oofness, float delay = 0.0, int attacker = 0, bool doneThis = false )
{
    if ( !Oof_IsEnabled() ) return;

    if ( oofness < 0.0 )
    {
        oofness = 0.0;
    }
    else if ( oofness > 1.0 )
    {
        oofness = 1.0;
    }

    if ( delay >= 0.05 )
    {
        DataPack pack = new DataPack();

        pack.WriteCell( client );
        pack.WriteFloat( oofness );
        pack.WriteCell( attacker );
        pack.WriteCell( doneThis ? 1 : 0 );

        CreateTimer( delay, Timer_Oof, pack );
        
        Oof_StartOofTime();
        return;
    }

    float volume = 0.5 + oofness * 0.5;
    int pitch = RoundFloat( 100.0 / (0.75 + oofness * 1.25) );

    float pos[3];
    if ( IsClientValidAndInGame( client ) )
    {
        GetClientEyePosition( client, pos );
    }

    if ( IsClientValidAndInGame( attacker ) && GetSteamAccountID(attacker) == Oof_GetOofJonId() )
    {
        Oof_EmitSound( OOF_SOUND_JON, pos, client, volume, pitch );
    }
    else if ( doneThis )
    {
        Oof_EmitSound( OOF_SOUND_DONETHIS, pos, client, volume, pitch );
    }
    else
    {
        Oof_EmitSound( OOF_SOUND_OOF, pos, client, volume, pitch );
    }
}
