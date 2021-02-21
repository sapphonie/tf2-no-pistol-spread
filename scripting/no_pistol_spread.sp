#include <sourcemod>
#include <tf2attributes>


public Plugin myinfo =
{
    name             =  "nospread pistol",
    author           =  "steph&nie",
    description      =  "remove spread from scouts pistols - uses tf2attributes",
    version          =  "0.0.1",
    url              =  "https://sappho.io"
}

ConVar sm_no_pistol_spread;
bool enabled;

public void OnPluginStart()
{
    sm_no_pistol_spread = CreateConVar(
        "sm_no_pistol_spread",
        "0",
        "disable random spread on Scout's pistols",
        FCVAR_NONE,
        true,
        0.0,
        true,
        1.0
    );
    HookConVarChange(sm_no_pistol_spread, PistolConVarChanged);

    doCvars();
}

void DoEntOnAllPistols()
{
    // loop thru all ents (exclude worldspawn = 0)
    for (int entity = 1; entity <= GetMaxEntities(); entity++)
    {
        // is entity valid? ignore if so
        if (!IsValidEntity(entity))
        {
            continue;
        }
        char className[128];
        // get name of this entity
        GetEntityClassname(entity, className, sizeof(className));
        // is this a pistol
        if (StrContains(className, "tf_weapon_pistol") != -1 || StrContains(className, "tf_weapon_handgun_scout_secondary") != -1)
        {
            if (enabled)
            {
                // get its ent ref
                int entref = EntIndexToEntRef(entity);
                // pass it to request frame
                RequestFrame(WaitAFrame_DoEnt, entref);
            }
            else
            {
                // reset custom attrib
                TF2Attrib_RemoveByName(entity, "weapon spread bonus");
            }
        }
    }
}

void PistolConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    doCvars();
}

void doCvars()
{
    if (!GetConVarBool(sm_no_pistol_spread))
    {
        PrintToServer("[NoPistolSpread] Disabled");
        enabled = false;
    }
    else
    {
        PrintToServer("[NoPistolSpread] Enabled");
        enabled = true;
    }
    DoEntOnAllPistols();
}

// fires whenever an entity is created
public void OnEntityCreated(int entity, const char[] className)
{
    // is this entity valid? ignore if so
    if (!IsValidEntity(entity) || !enabled)
    {
        return;
    }
    // is this a pistol? blah blah blah yeah repeated code i dont care twiikuu will prolly rewrite it anyway
    if (StrContains(className, "tf_weapon_pistol") != -1 || StrContains(className, "tf_weapon_handgun_scout_secondary") != -1)
    {
        int entref;
        // if "entity" fired by this func is below 0, its already an entref
        if (entity < 0)
        {
            entref = entity;
        }
        // otherwise get its entref
        else
        {
            entref = EntIndexToEntRef(entity);
        }
        // pass it to request frame
        RequestFrame(WaitAFrame_DoEnt, entref);
    }
}

// request frame do ent stuff
void WaitAFrame_DoEnt(int entref)
{
    // reconvert back to a valid ent id
    int entity = EntRefToEntIndex(entref);
    // if its fake, drop it
    if (!IsValidEntity(entity))
    {
        return;
    }
    // thanks tf2 wiki: https://wiki.teamfortress.com/wiki/List_of_item_attributes
    // attribid 106
    // "weapon spread bonus"
    // "%s1% more accurate"
    // "inverted_percentage"

    // set spread to 0
    TF2Attrib_SetByName(entity, "weapon spread bonus", 0.0);
}
