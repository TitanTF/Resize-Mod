#include <sdktools>

ConVar
	cvMinSize,
	cvMaxSize;
	
float
	g_flMinSize,
	g_flMaxSize;
	
public Plugin myinfo = 
{
	name = "Resize Mod",
	author = "myst",
	description = "Change the size of any entity you are looking at.",
	version = "1.0",
	url = "https://titan.tf"
}

public void OnPluginStart()
{
	cvMinSize 		= CreateConVar("sm_resizemod_min", "0.1", "Change the minimum size.", _, true, 0.1, true, 1000.0);
	cvMaxSize 		= CreateConVar("sm_resizemod_max", "100.0", "Change the maximum size.", _, true, 0.1, true, 1000.0);
	
	g_flMinSize 	= cvMinSize.FloatValue;
	g_flMaxSize 	= cvMaxSize.FloatValue;
	
	cvMinSize.AddChangeHook(OnCvarChanged);
	cvMaxSize.AddChangeHook(OnCvarChanged);
	
	RegAdminCmd("sm_scale", Command_Resize, ADMFLAG_GENERIC);
}

public int OnCvarChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	if (cvar == cvMinSize) g_flMinSize = cvMinSize.FloatValue;
	if (cvar == cvMaxSize) g_flMaxSize = cvMaxSize.FloatValue;
}

public Action Command_Resize(int iClient, int iArgs)
{
	char sSize[16];
	GetCmdArg(1, sSize, sizeof(sSize));
	
	int iTarget = GetClientPointVisible(iClient);
	if (iTarget > 0)
	{
		if (StringToFloat(sSize) >= g_flMinSize && StringToFloat(sSize) <= g_flMaxSize)
		{
			SetEntPropFloat(iTarget, Prop_Send, "m_flModelScale", StringToFloat(sSize));
		}
	}
}

stock int GetClientPointVisible(int iClient)
{
	float vOrigin[3]; float vAngles[3]; float vEndOrigin[3];
	
	GetClientEyePosition(iClient, vOrigin);
	GetClientEyeAngles(iClient, vAngles);
	
	Handle hTrace = INVALID_HANDLE;
	hTrace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_ALL, RayType_Infinite, TraceDontHitEntity, iClient);
	TR_GetEndPosition(vEndOrigin, hTrace);
	
	int iReturn = -1;
	int iHit = TR_GetEntityIndex(hTrace);
	
	if (TR_DidHit(hTrace) && iHit != iClient)
	{
		iReturn = iHit;
	}
	
	CloseHandle(hTrace);
	return iReturn;
}

public bool TraceDontHitEntity(int iEntity, int iMask, any iData)
{
	if (iEntity == iData) return false;
	return true;
}