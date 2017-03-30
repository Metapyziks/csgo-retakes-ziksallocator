bool g_WasNoScoped[MAXPLAYERS+1];

bool GetWeaponCanNoScope( int weaponId )
{
    switch ( weaponId )
    {
        case CSWeapon_SSG08: return true;
        case CSWeapon_AWP: return true;
        case CSWeapon_G3SG1: return true;
        case CSWeapon_SCAR20: return true;
    }
    return false;
}

void NoScope_OnTakeDamage( int victim,
    int &attacker, int &inflictor,
    float &damage, int &damagetype, int &weapon,
    float damageForce[3], float damagePosition[3], int damagecustom )
{
    g_WasNoScoped[victim] = false;

    if ( !IsClientValidAndInGame( attacker ) ) return;

    bool canNoScope = GetWeaponCanNoScope( weapon );
    bool scoped = GetEntProp( attacker, Prop_Send, "m_bIsScoped" ) != 0;
    
    g_WasNoScoped[victim] = canNoScope && !scoped;
}

void NoScope_PlayerDeath( Event event )
{
    int victim = GetClientOfUserId( event.GetInt( "userid" ) );
    if ( !IsClientValidAndInGame( victim ) ) return;

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

    char distanceString[32];
    FloatToStringFixedPoint( distance, 1, distanceString, sizeof(distanceString) );

    char attackerName[64];
    char victimName[64];

    GetClientName( attacker, attackerName, sizeof(attackerName) );
    GetClientName( victim, victimName, sizeof(victimName) );

    Retakes_MessageToAll( "{GREEN}%s{NORMAL} noscoped {GREEN}%s{NORMAL} from {LIGHT_RED}%sm{NORMAL} away!",
        attackerName, victimName, distanceString );
}
