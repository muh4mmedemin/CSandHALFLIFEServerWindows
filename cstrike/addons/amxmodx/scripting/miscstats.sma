/* AMX Mod X
*   Misc. Stats Plugin
*
* by the AMX Mod X Development Team
*  originally developed by OLO
*
* This file is part of AMX Mod X.
*
*
*  This program is free software; you can redistribute it and/or modify it
*  under the terms of the GNU General Public License as published by the
*  Free Software Foundation; either version 2 of the License, or (at
*  your option) any later version.
*
*  This program is distributed in the hope that it will be useful, but
*  WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*  General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software Foundation,
*  Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
*  In addition, as a special exception, the author gives permission to
*  link the code of this program with the Half-Life Game Engine ("HL
*  Engine") and Modified Game Libraries ("MODs") developed by Valve,
*  L.L.C ("Valve"). You must obey the GNU General Public License in all
*  respects for all of the code used other than the HL Engine and MODs
*  from Valve. If you modify this file, you may extend this exception
*  to your version of the file, but you are not obligated to do so. If
*  you do not wish to do so, delete this exception statement from your
*  version.
*/

#include <amxmodx>
#include <csx>

public MultiKill
public MultiKillSound
public BombPlanting
public BombDefusing
public BombPlanted
public BombDefused
public BombFailed
public BombPickUp
public BombDrop
public BombCountVoice
public BombCountDef
public BombReached
public ItalyBonusKill
public EnemyRemaining
public LastMan
public KnifeKill
public KnifeKillSound
public GrenadeKill
public GrenadeSuicide
public HeadShotKill
public HeadShotKillSound
public RoundCounterSound
public RoundCounter
public KillingStreak
public KillingStreakSound
public DoubleKill
public DoubleKillSound
public PlayerName
public FirstBloodSound

new g_streakKills[33][2]
new g_multiKills[33][2]
new g_C4Timer
new g_Defusing
new g_Planter 
new Float:g_LastOmg
new g_LastAnnounce
new g_roundCount
new Float:g_doubleKill
new g_doubleKillId
new g_friend[33]
new g_firstBlood

new g_MultiKillMsg[7][] = {
  "Multi-Kill! %s^n%L %d %L (%d %L)",
  "Ultra-Kill!!! %s^n%L %d %L (%d %L)",
  "%s IS ON A KILLING SPREE!!!^n%L %d %L (%d %L)",
  "RAMPAGE!!! %s^n%L %d %L (%d hs)" ,
  "%s IS UNSTOPPABLE!!!^n%L %d %L (%d %L)",
  "%s IS A MONSTER!^n%L %d %L (%d %L)",
  "%s IS GODLIKE!!!!^n%L %d %L (%d %L)"
}
new g_Sounds[7][] = {
  "multikill",
  "ultrakill",
  "killingspree",
  "rampage",
  "unstoppable",
  "monsterkill",
  "godlike"
}
new g_KillingMsg[7][] = {
  "%s: Multi-Kill!",
  "%s: Ultra-Kill!!!",
  "%s IS ON A KILLING SPREE!!!",
  "%s: RAMPAGE!!!",
  "%s IS UNSTOPPABLE!!!",
  "%s IS A MONSTER!",
  "%s IS GODLIKE!!!"
}
new g_KinfeMsg[4][] = {
  "KNIFE_MSG_1",
  "KNIFE_MSG_2",
  "KNIFE_MSG_3",
  "KNIFE_MSG_4"
}
new g_LastMessages[4][] = {
  "LAST_MSG_1",
  "LAST_MSG_2",
  "LAST_MSG_3",
  "LAST_MSG_4"
}
new g_HeMessages[4][] = {
  "HE_MSG_1",
  "HE_MSG_2",
  "HE_MSG_3",
  "HE_MSG_4"
}
new g_SHeMessages[4][] = {
  "SHE_MSG_1",
  "SHE_MSG_2",
  "SHE_MSG_3",
  "SHE_MSG_4"
}
new g_HeadShots[7][] = { 
  "HS_MSG_1",
  "HS_MSG_2",
  "HS_MSG_3",
  "HS_MSG_4",
  "HS_MSG_5",
  "HS_MSG_6",
  "HS_MSG_7"
}

new g_teamsNames[4][] = {
  "TERRORIST",
  "CT",
  "TERRORISTS",
  "CTS"
}

public plugin_init() {
  register_plugin("CS Misc. Stats",AMXX_VERSION_STR,"AMXX Dev Team") 
  register_dictionary("miscstats.txt")
  register_event("TextMsg","eRestart","a","2&#Game_C","2&#Game_w")
  register_event("SendAudio", "eEndRound", "a", "2&%!MRAD_terwin","2&%!MRAD_ctwin","2&%!MRAD_rounddraw") 
  register_event("RoundTime", "eNewRound", "bc") 
  register_event("StatusValue","setTeam","be","1=1") 
  register_event("StatusValue","showStatus","be","1=2","2!0")
  register_event("StatusValue","hideStatus","be","1=1","2=0")  
  new mapname[32]
  get_mapname(mapname,31)
  if (equali(mapname,"de_",3)||equali(mapname,"csde_",5)) {
    register_event("StatusIcon", "eGotBomb", "be", "1=1", "1=2", "2=c4")
    register_event("TextMsg", "eBombPickUp", "bc", "2&#Got_bomb")
    register_event("TextMsg", "eBombDrop", "bc", "2&#Game_bomb_d")
  }
  else if ( equali( mapname ,  "cs_italy"  ) ) {
    register_event( "23" , "chickenKill", "a" , "1=108" , /*"12=106",*/ "15=4" )
    register_event( "23" , "radioKill", "a" , "1=108" , /*"12=294",*/ "15=2" )
  }
}

public plugin_cfg() {
  new g_addStast[] = "amx_statscfg add ^"%s^" %s"
  server_cmd(g_addStast,"MultiKill","MultiKill")
  server_cmd(g_addStast,"MultiKillSound","MultiKillSound")
  server_cmd(g_addStast,"Bomb Planting","BombPlanting")
  server_cmd(g_addStast,"Bomb Defusing","BombDefusing")
  server_cmd(g_addStast,"Bomb Planted","BombPlanted")
  server_cmd(g_addStast,"Bomb Defuse Succ.","BombDefused")
  server_cmd(g_addStast,"Bomb Def. Failure","BombFailed")
  server_cmd(g_addStast,"Bomb PickUp","BombPickUp")
  server_cmd(g_addStast,"Bomb Drop","BombDrop")
  server_cmd(g_addStast,"Bomb Count Down","BombCountVoice")
  server_cmd(g_addStast,"Bomb Count Down (def)","BombCountDef")
  server_cmd(g_addStast,"Bomb Site Reached","BombReached")
  server_cmd(g_addStast,"Italy Bonus Kill","ItalyBonusKill")
  server_cmd(g_addStast,"Last Man","LastMan")
  server_cmd(g_addStast,"Knife Kill","KnifeKill")
  server_cmd(g_addStast,"Knife Kill Sound","KnifeKillSound")
  server_cmd(g_addStast,"Grenade Kill","GrenadeKill")
  server_cmd(g_addStast,"Grenade Suicide","GrenadeSuicide")
  server_cmd(g_addStast,"HeadShot Kill","HeadShotKill")
  server_cmd(g_addStast,"HeadShot Kill Sound","HeadShotKillSound")
  server_cmd(g_addStast,"Round Counter","RoundCounter")
  server_cmd(g_addStast,"Round Counter Sound","RoundCounterSound")
  server_cmd(g_addStast,"Killing Streak","KillingStreak")
  server_cmd(g_addStast,"Killing Streak Sound","KillingStreakSound")
  server_cmd(g_addStast,"Enemy Remaining","EnemyRemaining")
  server_cmd(g_addStast,"Double Kill","DoubleKill")
  server_cmd(g_addStast,"Double Kill Sound","DoubleKillSound")
  server_cmd(g_addStast,"Player Name","PlayerName")
  server_cmd(g_addStast,"First Blood Sound","FirstBloodSound")
}

public client_putinserver(id)
{
  g_multiKills[id] = { 0 , 0 }
  g_streakKills[ id ] = { 0 , 0 }
}

public client_death(killer,victim,wpnindex,hitplace,TK) {

  if ( wpnindex == CSW_C4 )
    return


  new headshot = ( hitplace == HIT_HEAD ) ? 1:0
  new selfkill = ( killer == victim ) ? 1:0

  if ( g_firstBlood ) {
  	g_firstBlood = 0
  	if ( FirstBloodSound ) play_sound("misc/firstblood")
  }
  if ( (KillingStreak || KillingStreakSound) && !TK ) { 
    g_streakKills[ victim ][ 1 ]++
    g_streakKills[ victim ][ 0 ] = 0
    if (!selfkill){  
      g_streakKills[ killer ][ 0 ]++
      g_streakKills[ killer ][ 1 ] = 0
      new a = g_streakKills[ killer ][ 0 ] - 3
      if ( (a > -1) && !( a % 2 ) ) {
        new name[32]
        get_user_name( killer , name , 31 )
        if ( (a >>= 1) > 6 ) a = 6
        if ( KillingStreak ){
          set_hudmessage(0, 100, 255, 0.05, 0.55, 2, 0.02, 6.0, 0.01, 0.1, 3)
          show_hudmessage(0,g_KillingMsg[ a ], name )        
        }
        if (  KillingStreakSound ) {
		new file[32]
		format(file, 32, "misc/%s", g_Sounds[a])
		play_sound(file)
	}
      }
    }
  }
  if ( MultiKill || MultiKillSound ) {
    if (!selfkill && !TK ) { 
      g_multiKills[killer][0]++ 
      g_multiKills[killer][1] += headshot
      new param[2]
      param[0] = killer 
      param[1] = g_multiKills[killer][0] 
      set_task( 4.0 + float( param[1] ) ,"checkKills",0,param,2)
    }
  }
  if ( EnemyRemaining ) {
    new ppl[32], pplnum = 0
    new team = get_user_team( victim ) - 1
    if ( team >= 0 && team < 4 )
      get_players(ppl,pplnum,"e", g_teamsNames[1 - team] ) 
    if (pplnum) {
      new eppl[32], epplnum 
      get_players(eppl,epplnum,"ae",g_teamsNames[team]) 
      if (epplnum) { 
        new message[128],team_name[32]
        set_hudmessage(255,255,255,0.02,0.85,2, 0.05, 0.1, 0.02, 3.0, 3)
        for(new a=0; a<pplnum; ++a){
           format(team_name,31,"%L",ppl[a],(epplnum==1)?g_teamsNames[team]:g_teamsNames[team+2])
           format(message,127,"%L",ppl[a],"REMAINING",epplnum,team_name)
           show_hudmessage(ppl[a],message)
        }
      }
    }
  }
  if ( LastMan ) {
    new cts[32], ts[32], ctsnum, tsnum 
    get_players(cts,ctsnum,"ae", g_teamsNames[1] )    
    get_players(ts,tsnum,"ae", g_teamsNames[0] ) 
    if ( ctsnum == 1 && tsnum == 1 ) { 
        new ctname[32], tname[32] 
        get_user_name(cts[0],ctname,31) 
        get_user_name(ts[0],tname,31) 
        set_hudmessage(0, 255, 255, -1.0, 0.35, 0, 6.0, 6.0, 0.5, 0.15, 3) 
        show_hudmessage(0,"%s vs. %s",ctname,tname) 
        play_sound("misc/maytheforce") 
    }
    else if ( !g_LastAnnounce  ) {
      new oposite = 0, team = 0
      if ( ctsnum == 1 && tsnum > 1 ) {
        g_LastAnnounce = cts[0] 
        oposite = tsnum
        team = 0
      }
      else if ( tsnum == 1 && ctsnum > 1 ) {
        g_LastAnnounce = ts[0]
        oposite = ctsnum
        team = 1
      }
      if (g_LastAnnounce) { 
        new name[32] 
        get_user_name(g_LastAnnounce,name,31) 
        set_hudmessage(0, 255, 255, -1.0, 0.35, 0, 6.0, 6.0, 0.5, 0.15, 3) 
        show_hudmessage(0,"%s (%d HP) vs. %d %s%s: %L",name, 
          get_user_health(g_LastAnnounce),oposite, 
          g_teamsNames[team],(oposite==1)?"":"S",LANG_PLAYER,g_LastMessages[ random_num(0,3) ] )     
	if (!is_user_connecting(g_LastAnnounce))
	        client_cmd(g_LastAnnounce,"spk misc/oneandonly") 
      }
    }
  }

  if ( wpnindex == CSW_KNIFE && ( KnifeKill || KnifeKillSound ) ) {
    if ( KnifeKill ) {
      new killer_name[32],victim_name[32] 
      get_user_name(killer,killer_name,31) 
      get_user_name(victim,victim_name,31) 
      set_hudmessage(255, 100, 100, -1.0, 0.25, 1, 6.0, 6.0, 0.5, 0.15, 1) 
      show_hudmessage(0,"%L",LANG_PLAYER,g_KinfeMsg[ random_num(0,3) ],killer_name,victim_name) 
    }
    if ( KnifeKillSound ) play_sound("misc/humiliation") 
  }

  if ( wpnindex == CSW_HEGRENADE && (GrenadeKill || GrenadeSuicide) ) {
    new killer_name[32],victim_name[32] 
    get_user_name(killer,killer_name,32) 
    get_user_name(victim,victim_name,32) 
    set_hudmessage(255, 100, 100, -1.0, 0.25, 1, 6.0, 6.0, 0.5, 0.15, 1)    
    if ( !selfkill ) {
      if ( GrenadeKill ) show_hudmessage(0,"%L",LANG_PLAYER,g_HeMessages[ random_num(0,3)],killer_name,victim_name) 
    }
    else if ( GrenadeSuicide ) show_hudmessage(0,"%L",LANG_PLAYER,g_SHeMessages[ random_num(0,3) ],victim_name) 
  }
  if ( headshot && (HeadShotKill || HeadShotKillSound) ) {
    if ( HeadShotKill && wpnindex ) {
      new killer_name[32], victim_name[32], weapon_name[32], message[128], players[32], pnum
      xmod_get_wpnname(wpnindex,weapon_name,31)
      get_user_name(killer,killer_name,31) 
      get_user_name(victim,victim_name,31)

      get_players(players,pnum,"c")
      for (new i=0;i<pnum;i++) {
        format( message, 127, "%L",players[i],g_HeadShots[ random_num(0,6) ] )
        replace( message, 127 , "$vn", victim_name )
        replace( message, 127 , "$wn", weapon_name )    
        replace( message, 127 , "$kn", killer_name )
        set_hudmessage(100, 100, 255, -1.0, 0.29, 0, 6.0, 6.0, 0.5, 0.15, 1)    
        show_hudmessage(players[i],message ) 
      }
    }
    if ( HeadShotKillSound ) {
    	client_cmd(killer,"spk misc/headshot") 
    	client_cmd(victim,"spk misc/headshot")
   	}
  }
  if ( (DoubleKill || DoubleKillSound) && !selfkill ) {
    new Float:nowtime = get_gametime()
    if ( g_doubleKill == nowtime && g_doubleKillId == killer ) {
      if ( DoubleKill ) {
        new name[32]
        get_user_name( killer , name , 31  )
        set_hudmessage(255, 0, 255, -1.0, 0.35, 0, 6.0, 6.0, 0.5, 0.15, 3)
        show_hudmessage(0,"%L",LANG_PLAYER,"DOUBLE_KILL",name )
      }
      if ( DoubleKillSound ) play_sound("misc/doublekill") 
    }
    g_doubleKill = nowtime
    g_doubleKillId = killer
  }
} 

public hideStatus(id) {
  if ( PlayerName ) {
    set_hudmessage(0,0,0,0.0,0.0,0, 0.0, 0.01, 0.0, 0.0, 4) 
    show_hudmessage(id,"")
  }
}

public setTeam(id) 
  g_friend[id] = read_data(2)

public showStatus(id) {
  if ( PlayerName ) {
    new name[32],pid = read_data(2) 
    get_user_name(pid,name,31)
    new color1 = 0,color2 = 0
    if ( get_user_team(pid)==1 )
      color1 = 255
    else
      color2 = 255
    if (g_friend[id]==1) { // friend
      new clip, ammo, wpnid = get_user_weapon(pid,clip,ammo) 
      new wpnname[32] 
      if ( wpnid )
        xmod_get_wpnname(wpnid,wpnname,31) 
      set_hudmessage(color1,50,color2,-1.0,0.60,1, 0.01, 3.0, 0.01, 0.01, 4)
      show_hudmessage(id,"%s -- %d HP / %d AP / %s",name, 
        get_user_health(pid),get_user_armor(pid),wpnname)
    } 
    else { 
      set_hudmessage(color1,50,color2,-1.0,0.60,1, 0.01, 3.0, 0.01, 0.01, 4) 
      show_hudmessage(id,name) 
    } 
  }
}

public eNewRound()
  if ( read_data(1) == floatround(get_cvar_float("mp_roundtime") * 60.0) ) {
    g_firstBlood = 1
    g_C4Timer = 0
    ++g_roundCount
    if ( RoundCounter ) {
      set_hudmessage(200, 0, 0, -1.0, 0.30, 0, 6.0, 6.0, 0.5, 0.15, 1) 
      show_hudmessage(0,  "%L", LANG_PLAYER, "PREPARE_FIGHT", g_roundCount )
    }
    if ( RoundCounterSound )  play_sound("misc/prepare")
    if ( KillingStreak ) {
      new appl[32],ppl, i
      get_players(appl,ppl, "ac" )
      for (new a = 0; a < ppl; ++a) {
        i = appl[ a ]
        if ( g_streakKills[ i ][ 0 ] >= 2 )
          client_print( i , print_chat , "* %L", i, "KILLED_ROW", g_streakKills[ i ][ 0 ] )
        else if ( g_streakKills[ i ][ 1 ] >= 2 )
          client_print( i , print_chat , "* %L", i, "DIED_ROUNDS", g_streakKills[ i ][ 1 ] )     
      }
    }
  }

public eRestart() {
  eEndRound()
  g_roundCount = 0
  g_firstBlood = 1
}

public eEndRound() {
  g_C4Timer = -2
  g_LastOmg = 0.0
  remove_task(8038)
  g_LastAnnounce = 0
}

public checkKills(param[]) { 
  new id = param[0]
  new a = param[1]
  if (a == g_multiKills[id][0]) {
    a -= 3 
    if ( a > -1 ) {
      if ( MultiKill ) {
        new name[32]
        get_user_name(id,name,31)
        set_hudmessage(255, 0, 100, 0.05, 0.65, 2, 0.02, 6.0, 0.01, 0.1, 2)
        if ( a > 6 ) a = 6
        show_hudmessage(0,g_MultiKillMsg[a],name,LANG_PLAYER,"WITH",g_multiKills[id][0],LANG_PLAYER,"KILLS",g_multiKills[id][1],LANG_PLAYER,"HS")          
      }
      if ( MultiKillSound )
      {
      	new sound[24]
	format(sound, 23, "misc/%s", g_Sounds[a])
	play_sound(sound)
      }
    }
    g_multiKills[id] = { 0,0 }
  }
}

public chickenKill()
  if ( ItalyBonusKill ) announceEvent( 0 , "KILLED_CHICKEN"  )

public radioKill() {
  if ( ItalyBonusKill ) announceEvent( 0 , "BLEW_RADIO" )
}

announceEvent( id, message[] ) {
  new name[32]
  get_user_name(id, name , 31) 
  set_hudmessage(255, 100, 50, -1.0, 0.30, 0, 6.0, 6.0, 0.5, 0.15, 1)
  show_hudmessage(0,"%L",LANG_PLAYER,message,name)
}

public eBombPickUp(id)
	if (BombPickUp) announceEvent(id , "PICKED_BOMB")

public eBombDrop()
	if (BombDrop) announceEvent(g_Planter , "DROPPED_BOMB")

public eGotBomb(id) {
  g_Planter = id  
  if ( BombReached && read_data(1)==2 && g_LastOmg<get_gametime()) { 
    g_LastOmg = get_gametime() + 15.0
    announceEvent(g_Planter, "REACHED_TARGET" )
  } 
} 

public bombTimer() { 
  if (--g_C4Timer > 0) { 
    if (BombCountVoice) { 
      if (g_C4Timer == 30 || g_C4Timer == 20) { 
        new temp[64] 
        num_to_word(g_C4Timer,temp,63) 
	format(temp, 63, "^"vox/%s seconds until explosion^"", temp)
	play_sound(temp)
      } 
      else if (g_C4Timer < 11) { 
        new temp[64] 
        num_to_word(g_C4Timer,temp,63) 
	format(temp, 63, "^"vox/%s^"", temp)
	play_sound(temp)
      } 
    } 
    if (BombCountDef && g_Defusing) client_print(g_Defusing,print_center,"%d",g_C4Timer)
  } 
  else remove_task(8038)
}

public bomb_planted(planter){
  g_Defusing = 0
  if (BombPlanted) announceEvent(planter, "SET_UP_BOMB" )
  g_C4Timer = get_cvar_num("mp_c4timer") 
  set_task(1.0,"bombTimer",8038,"",0,"b") 

}

public bomb_planting(planter)
	if (BombPlanting)	announceEvent(planter, "PLANT_BOMB" )

public bomb_defusing(defuser){
	if (BombDefusing) announceEvent(defuser, "DEFUSING_BOMB" )
	g_Defusing = defuser
}

public bomb_defused(defuser)
	if (BombDefused) announceEvent(defuser, "DEFUSED_BOMB" )

public bomb_explode(planter,defuser)
	if (BombFailed && defuser) announceEvent(defuser ,  "FAILED_DEFU" )

public plugin_modules()
{
	require_module("csx")
}

public play_sound(sound[])
{
	new players[32], pnum
	get_players(players, pnum, "c")
	new i
	for (i=0; i<pnum; i++)
	{
		if (is_user_connecting(players[i]))
			continue
		client_cmd(players[i], "spk %s", sound)
	}
}
