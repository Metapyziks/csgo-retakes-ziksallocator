
Handle g_CVOofCooldown = INVALID_HANDLE;
Handle g_CVOofTimeDuration = INVALID_HANDLE;

float g_LastOof[MAXPLAYERS+1];
float g_OofTime = -1.0;
float g_CurTimescale = 1.0;

void Oof_OnPluginStart()
{
    RegConsoleCmd( "sm_oof", Cmd_Oof );

    g_CVOofCooldown = CreateConVar( "sm_oof_cooldown", "10", "Time in seconds before a player can oof again.", FCVAR_NOTIFY );
    g_CVOofTimeDuration = CreateConVar( "sm_ooftime_duration", "2", "Time in seconds that OofTime should last.", FCVAR_NOTIFY );

    int flags = GetCommandFlags( "sv_cheats" );
    SetCommandFlags( "sv_cheats", flags & ~FCVAR_NOTIFY );
}

float Oof_GetOofCooldown()
{
    return GetConVarFloat( g_CVOofCooldown );
}

float Oof_GetOofTimeDuration()
{
    return GetConVarFloat( g_CVOofTimeDuration );
}

void Oof_OnMapStart()
{
    AddFileToDownloadsTable( "sound/ziks/test.mp3" );
    PrecacheSound( "ziks/test.mp3", true );
    AddToStringTable( FindStringTable( "soundprecache" ), "*ziks/test.mp3" );

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
    float ooftimeDuration = Oof_GetOofTimeDuration();

    if ( g_OofTime == -1 || ooftimeDuration <= 0 ) return;

    float gameTime = GetGameTime();
    float t = gameTime - g_OofTime;

    if ( t < 0 ) return;

    if ( t < ooftimeDuration )
    {
        UpdateTimescale( 0.5 );
        return;
    }

    t = (t - ooftimeDuration) / 0.25;

    if ( t > 1.0 )
    {
        t = 1.0;
    }

    UpdateTimescale( 0.5 + t * 0.5 );
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
    int victim = GetClientOfUserId( event.GetInt( "userid" ) );
    if ( !IsClientValidAndInGame( victim ) ) return;

    g_LastOof[victim] = 0.0;
}

public Action Cmd_Oof( int client, int args )
{
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

    Oof( client, oofness );

    CloseHandle( pack );
}

void Oof( int client, float oofness, float delay = 0.0 )
{
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

    EmitAmbientSound( "*ziks/test.mp3", pos, client, SNDLEVEL_GUNFIRE, SND_CHANGEVOL | SND_CHANGEPITCH, volume, pitch );
}
