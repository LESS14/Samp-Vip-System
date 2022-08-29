
// Includes
#include <a_samp>
#include <DOF2>
#include <sscanf2>
#include <Pawn.CMD>
#include <foreach>

// Pastas
#define PASTA_VIPS "/Vips/%s.ini"
#define PASTA_PREMIUM "/Premium/%s.ini"
#define PASTA_CONTAS "/Contas/%s.ini"

// Colors
#define Vermelho 0xFF0000AA
#define VerdeClaro 0x00FF00AA
#define Verde 0x2EFE2EAA

// Dialogs
#define Dialog 0


new vip[MAX_PLAYERS];
new godmod[MAX_PLAYERS];
new godcar[MAX_PLAYERS];

stock SetPlayerVIP(playerid, days)
{
	if(IsPlayerConnected(playerid))
	{
		new VIPS[128], ACCS[128], STRV[128];

		new year, month, day;
		getdate(year, month, day);

		format(VIPS, sizeof(VIPS), PASTA_VIPS, GetPlayerNameEx(playerid));
		if(!DOF2_FileExists(VIPS))
		{
			DOF2_CreateFile(VIPS);
		}
		DOF2_SetInt(VIPS, "Dias", DOF2_GetInt(VIPS, "Dias")+days);
		format(STRV, sizeof(STRV), "%d/%d/%d", day, month, year);
		DOF2_SetString(VIPS, "DataSet", STRV);

		format(ACCS, sizeof(ACCS), PASTA_CONTAS, GetPlayerNameEx(playerid));
		DOF2_SetInt(ACCS, "VIP", 1);
		vip[playerid] = 1;
	}
	return 1;
}

stock UnsetPlayerVIP(playerid) {
	new VIPS[64], ACCS[64];
	format(VIPS, sizeof(VIPS), PASTA_VIPS, GetPlayerNameEx(playerid));
	if(DOF2_FileExists(VIPS)) DOF2_RemoveFile(VIPS);

	format(ACCS, sizeof(ACCS), PASTA_CONTAS, GetPlayerNameEx(playerid));
	DOF2_SetInt(ACCS, "VIP", 0);
	vip[playerid] = 0;
	return 1;
}

stock CheckPlayerVIP(playerid) {
	new VIPS[128], ACCS[128], STRV[128];
	new year, month, day;
	getdate(year, month, day);
	format(ACCS, sizeof(ACCS), PASTA_CONTAS, GetPlayerNameEx(playerid));
	if(DOF2_FileExists(ACCS)) {
		format(VIPS, sizeof(VIPS), PASTA_VIPS, GetPlayerNameEx(playerid));
		if(DOF2_FileExists(VIPS)) {
			format(STRV, sizeof(STRV), "%d/%d/%d", day, month, year);
			if(strcmp(DOF2_GetString(VIPS, "DataSet"), STRV, true) != 0) {
				DOF2_SetString(VIPS, "DataSet", STRV);
				DOF2_SetInt(VIPS, "Dias", DOF2_GetInt(VIPS, "Dias")-1);
			} else if(DOF2_GetInt(VIPS, "Dias") > 0) {
				DOF2_SetInt(ACCS, "VIP", 1);
				vip[playerid] = 1;
	 			SendClientMessage(playerid, -1, "Você ganhou ou comprou VIP.");
			} else UnsetPlayerVIP(playerid);
		} else {
			DOF2_SetInt(ACCS, "VIP", 0);
			vip[playerid] = 0;
		}
	}
	return 1;
}

stock GetVIPDays(playerid) {
	new VIPS[64];
	format(VIPS, sizeof(VIPS), PASTA_VIPS, GetPlayerNameEx(playerid));
	if(DOF2_FileExists(VIPS)) return DOF2_GetInt(VIPS, "Dias");
	return 0;
}

IsPlayerVIP(playerid) return vip[playerid];

CMD:setarvip(playerid, params[]) {
	if(!IsPlayerAdmin(playerid)) return 1;
	new plid, dias;
	if(sscanf(params, "ud", plid, dias)) return SendClientMessage(playerid, 0x008040AA, "Use: /setarvip [id] [quantidade-de-dias]");
	if(!IsPlayerConnected(plid)) return SendClientMessage(playerid, Vermelho, "Valor inválido, tente novamente!");
	if(IsPlayerVIP(plid) == 2) return SendClientMessage(playerid, Vermelho, "Retire o VIP deste player primeiro!");
	UnsetPlayerVIP(plid);
	SetPlayerVIP(plid, dias);

	new string[128];
	format(string, sizeof(string), "O(A) Administrador %s[%d] te deu %d dia(s) de VIP!", GetPlayerNameEx(playerid), playerid, dias);
	SendClientMessage(plid, Verde, string);
	SendClientMessage(playerid, Verde, "VIP setado com sucesso!");
	return 1;
}

CMD:tirarvip(playerid,params[]) {
	if(!IsPlayerAdmin(playerid)) return 1;
	new plid;
	if(sscanf(params, "u", plid)) return SendClientMessage(playerid, 0x008040AA, "Use: /tirarvip [id]");
	if(!IsPlayerConnected(plid)) return SendClientMessage(playerid, Vermelho, "Valor inválido, tente novamente!");

	UnsetPlayerVIP(plid);

	new string[128];
	format(string, sizeof(string), "O(A) Administrador %s[%d] retirou seu VIP.", GetPlayerNameEx(playerid), playerid);
	SendClientMessage(plid, Verde, string);
	SendClientMessage(playerid, Verde, "VIP retirado com sucesso!");
	return 1;
}

CMD:vips(playerid)
{
	new str[1000], cont, string[90];
	foreach(Player, i)
	{
		if(vip[i] == 0) continue;
		format(string, sizeof(string), "{FFFFFF}%s  ", GetPlayerNameEx(i));

		if(vip[i] == 1) strcat(string, "{FFFF00}[VIP]\n");
		else if(vip[i] == 2) strcat(string, "{FF0000}[VIP PRO]\n");
		strcat(str, string);
		cont++;
	}
	if(!cont) ShowPlayerDialog(playerid, Dialog, DIALOG_STYLE_MSGBOX, "{FFFFFF}VIPS Online", "{FFFFFF}Nenhum VIP está online no momento.", "OK", "");
	else ShowPlayerDialog(playerid, Dialog, DIALOG_STYLE_MSGBOX, "{FF0000}Jogadores VIPS", str, "OK", "");
	return 1;
}

stock SetPlayerPremium(playerid, days) {
	new PREMIUM[64], ACCS[64], STRV[64];

	new year, month, day;
	getdate(year, month, day);

	format(PREMIUM, sizeof(PREMIUM), PASTA_PREMIUM, GetPlayerNameEx(playerid));
	if(!DOF2_FileExists(PREMIUM)) DOF2_CreateFile(PREMIUM);

	DOF2_SetInt(PREMIUM, "Dias", DOF2_GetInt(PREMIUM, "Dias")+days);
	format(STRV, sizeof(STRV), "%d/%d/%d", day, month, year);
	DOF2_SetString(PREMIUM, "DataSet", STRV);

	format(ACCS, sizeof(ACCS), PASTA_CONTAS, GetPlayerNameEx(playerid));
	DOF2_SetInt(ACCS, "UsouConce", 0);
	DOF2_SetInt(ACCS, "VIP", 2);
	vip[playerid] = 2;
	return 1;
}

stock UnsetPlayerPremium(playerid) {
	new PREMIUM[64], ACCS[64];
	format(PREMIUM, sizeof(PREMIUM), PASTA_PREMIUM, GetPlayerNameEx(playerid));
	if(DOF2_FileExists(PREMIUM)) DOF2_RemoveFile(PREMIUM);

	format(ACCS, sizeof(ACCS), PASTA_CONTAS, GetPlayerNameEx(playerid));
	DOF2_SetInt(ACCS, "VIP", 0);
	vip[playerid] = 0;
	return 1;
}

stock CheckPlayerPremium(playerid) {
	new PREMIUM[128], ACCS[128], STRV[128];
	new year, month, day;
	getdate(year, month, day);
	format(ACCS, sizeof(ACCS), PASTA_CONTAS, GetPlayerNameEx(playerid));
	if(DOF2_FileExists(ACCS)) {
		format(PREMIUM, sizeof(PREMIUM), PASTA_PREMIUM, GetPlayerNameEx(playerid));
		if(DOF2_FileExists(PREMIUM)) {
			format(STRV, sizeof(STRV), "%d/%d/%d", day, month, year);
			if(strcmp(DOF2_GetString(PREMIUM, "DataSet"), STRV, true) != 0) DOF2_SetString(PREMIUM, "DataSet", STRV), DOF2_SetInt(PREMIUM, "Dias", DOF2_GetInt(PREMIUM, "Dias")-1);
			if(DOF2_GetInt(PREMIUM, "Dias") > 0) DOF2_SetInt(ACCS, "VIP", 2), vip[playerid] = 2;
			else CheckPlayerVIP(playerid);
			SendClientMessage(playerid, -1, "{FFFFFF}Você ganhou ou comprou um VIP PRO{6A97AB}.");
			SendClientMessage(playerid, -1, "{FFFFFF}Veja os comandos em {6A97AB}/comandospro{FFFFFF}.");
		}
		else CheckPlayerVIP(playerid);
	}
	return 1;
}

stock GetPREMIUMDays(playerid) {
	new PREMIUM[64];
	format(PREMIUM, sizeof(PREMIUM), PASTA_PREMIUM, GetPlayerNameEx(playerid));
	if(DOF2_FileExists(PREMIUM)) return DOF2_GetInt(PREMIUM, "Dias");
	return 0;
}

CMD:setarpro(playerid, params[]) {
	if(!IsPlayerAdmin(playerid)) return 1;
	new plid, dias;
	if(sscanf(params, "ud", plid, dias)) return SendClientMessage(playerid, 0x008040AA, "Use: /setarpro [id] [quantidade-de-dias]");
	if(!IsPlayerConnected(plid)) return SendClientMessage(playerid, Vermelho, "Valor inválido, tente novamente!");
	if(IsPlayerVIP(plid) == 1) return SendClientMessage(playerid, Vermelho, "Retire o Vip Comum desse player antes de setar o VIP PRO.");
	UnsetPlayerPremium(plid);
	SetPlayerPremium(plid, dias);
	new string[128];
	format(string, sizeof(string), "%s[%d] foi promovido por %s[%d] para VIP PRO. Dias: %d.", GetPlayerNameEx(plid), plid, GetPlayerNameEx(playerid), playerid, dias);
	SendClientMessageToAll(VerdeClaro, string);
	SendClientMessage(playerid, Verde, "VIP PRO setado com sucesso!");
	return 1;
}


CMD:health(playerid) {
  if(!IsPlayerVIP(playerid)) return SendClientMessage(playerid, Vermelho, "Você não é um(a) jogador(a) VIP.");
  SetPlayerHealth(playerid, 100.0);
  SendClientMessage(playerid, VerdeClaro, "Comando efetuado com sucesso!");
  return 1;
}

CMD:armour(playerid) {
  if(!IsPlayerVIP(playerid)) return SendClientMessage(playerid, Vermelho, "Você não é um(a) jogador(a) VIP.");
  SetPlayerArmour(playerid, 100.0);
  SendClientMessage(playerid, VerdeClaro, "Comando efetuado com sucesso!");
  return 1;
}

CMD:godmod(playerid) {
if(IsPlayerVIP(playerid) != 2) return SendClientMessage(playerid, Vermelho, "Você não é um(a) jogador(a) VIP Premium.");
if(godmod[playerid] == 0) {
SetPlayerHealth(playerid, 9999999.0);
godmod[playerid] = 1;
SendClientMessage(playerid, VerdeClaro, "Godmod desativado com sucesso, digite /godmod novamente para desativar.");
}
else if(godmod[playerid] == 1) {
SetPlayerHealth(playerid, 100.0);
godmod[playerid] = 0;
SendClientMessage(playerid, VerdeClaro, "Godmod desativado com sucesso, digite /godmod novamente para re-ativar.");
}
return 1;
}

CMD:getguns(playerid) {
 if(IsPlayerVIP(playerid) != 2) return SendClientMessage(playerid, Vermelho, "Você não é um(a) jogador(a) VIP Premium.");
 GivePlayerWeapon(playerid, 24, 300);
 GivePlayerWeapon(playerid, 26, 300);
 GivePlayerWeapon(playerid, 28, 300);
 GivePlayerWeapon(playerid, 31, 300);
 GivePlayerWeapon(playerid, 34, 300);
 SendClientMessage(playerid, VerdeClaro, "Você equipou-se com sucesso!");
 return 1;
}

CMD:jetpack(playerid) {
 if(IsPlayerVIP(playerid) != 2) return SendClientMessage(playerid, Vermelho, "Você não é um(a) jogador(a) VIP Premium.");
 SetPlayerSpecialAction(playerid, 2);
 SendClientMessage(playerid, Verde, "Jetpack foi criada com sucesso.");
 return 1;
}

public OnPlayerConnect(playerid) {
 CheckPlayerVIP(playerid);
 CheckPlayerPremium(playerid);
 return 1;
}

CMD:repair(playerid) {
	if(!IsPlayerVIP(playerid)) return SendClientMessage(playerid, Vermelho, "Você não é um(a) jogador(a) VIP.");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, Vermelho, "Você não está em um veículo.");
	RepairVehicle(GetPlayerVehicleID(playerid));
	return 1;
}

stock GetPlayerNameEx(playerid) {
 static pNome[MAX_PLAYER_NAME];
 GetPlayerName(playerid, pNome, MAX_PLAYER_NAME);
 return pNome;
}

public OnGameModeExit() {
 DOF2_Exit();
 for(new playerid = 0; playerid < MAX_PLAYERS; playerid++) {
 CheckPlayerVIP(playerid);
 }
 return 1;
 }

CMD:godcar(playerid) {
 if(IsPlayerVIP(playerid) != 2) return SendClientMessage(playerid, Vermelho, "Você não é um(a) jogador(a) VIP Premium.");
 if(godcar[playerid] == 0) {
 godcar[playerid] = 1;
 SetVehicleHealth(GetPlayerVehicleID(playerid), 999999.0);
 SendClientMessage(playerid, VerdeClaro, "Godcar ativado com sucesso! digite /godcar novamente para desativar.");
 }
 else if(godcar[playerid] == 1) {
 godcar[playerid] = 0;
 SetVehicleHealth(GetPlayerVehicleID(playerid), 1000.0);
 SendClientMessage(playerid, VerdeClaro, "Godcar desativado com sucesso! digite /godcar novamente para re-ativar.");
 }
 return 1;
}
