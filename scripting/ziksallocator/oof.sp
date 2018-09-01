
void Oof_OnPluginStart()
{
    RegConsoleCmd( "sm_oof", Cmd_Oof );
}

void Oof_OnMapStart()
{
    AddFileToDownloadsTable( "sound/ziks/test.mp3" );
    PrecacheSound( "ziks/test.mp3", true );
    AddToStringTable( FindStringTable( "soundprecache" ), "*ziks/test.mp3" );
}

public Action Cmd_Oof( int client, int args )
{
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

void Oof_OnClientSayCommand( int client, const char[] command, const char[] args )
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

        return;
    }

    float volume = 0.75 + oofness * 0.25;
    int pitch = RoundFloat( 100 / (1.0 + oofness) );

    float pos[3];
    if ( IsClientValidAndInGame( client ) )
    {
        GetClientEyePosition( client, pos );
    }

    EmitAmbientSound( "*ziks/test.mp3", pos, client, SNDLEVEL_GUNFIRE, SND_CHANGEVOL | SND_CHANGEPITCH, volume, pitch );
}
