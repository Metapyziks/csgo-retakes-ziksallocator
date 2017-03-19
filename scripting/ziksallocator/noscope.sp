bool g_WasNoScoped[MAXPLAYERS+1];

void NoScope_OnTakeDamage( int victim,
    int &attacker, int &inflictor,
    float &damage, int &damagetype, int &weapon,
    float damageForce[3], float damagePosition[3], int damagecustom )
{
    g_WasNoScoped[victim] = false;

    if ( attacker > MAXPLAYERS || !IsClientInGame( attacker ) ) return;

    char weaponClassName[64];
    GetClientWeapon( attacker, weaponClassName, sizeof(weaponClassName) );

    bool canNoScope = GetWeaponCanNoScope( weaponClassName );
    bool scoped = GetEntProp( attacker, Prop_Send, "m_bIsScoped" ) != 0;
    
    g_WasNoScoped[victim] = canNoScope && !scoped;
}

void NoScope_PlayerDeath( Event event )
{
    int victim = GetClientOfUserId( event.GetInt( "userid" ) );
    if ( victim > MAXPLAYERS || !IsClientInGame( victim ) ) return;

    if ( g_WasNoScoped[victim] )
    {
        int attacker = GetClientOfUserId( event.GetInt( "attacker" ) );
        DisplayNoScopeMessage( victim, attacker );
    }
}

void DisplayNoScopeMessage( int victim, int attacker )
{
    float victimPos[3];
    GetClientAbsOrigin( victim, victimPos );

    float posDiff[3];
    GetClientAbsOrigin( attacker, posDiff );

    posDiff[0] -= victimPos[0];
    posDiff[1] -= victimPos[1];
    posDiff[2] -= victimPos[2];

    float distance = SquareRoot(
        posDiff[0] * posDiff[0] +
        posDiff[1] * posDiff[1] +
        posDiff[2] * posDiff[2] ) * 0.01905;

    int distanceInt = RoundToFloor( distance );
    int distanceFrac = RoundFloat( (distance - distanceInt) * 10 );

    char attackerName[64];
    char victimName[64];

    GetClientName( attacker, attackerName, sizeof(attackerName) );
    GetClientName( victim, victimName, sizeof(victimName) );

    Retakes_MessageToAll( "{GREEN}%s{NORMAL} noscoped {GREEN}%s{NORMAL} from {LIGHT_RED}%i.%im{NORMAL} away!",
        attackerName, victimName, distanceInt, distanceFrac );
}
