
script: "boneTrack.ash"
notify "donCannoli";

import <Zlib.ash>
                      //Text in CLI is color coded  
                        int trigger_MallPrice_High = 15000000;    //Set Value To Trigger Message Green
                        int trigger_MallPrice_Low = 3000000;        //Set Value To Trigger Message Red
                        int trigger_MeatPerBone_High = 10000;     //Set Value To Trigger Message Green
                        int trigger_MeatPerBone_Low = 1000;         //Set Value To Trigger Message Red           
                        int trigger_ValuePerBone_High = 15;       //Set Value To Trigger Message Green
                        int trigger_ValuePerBone_Low = 7;           //Set Value To Trigger Message Red
//confirms wiki launch at first run.                                                                                              //Note To reset: "set boneTrackEnableWiki=" ";                                                       
  string WikiPrompt = `>  Set < true > To Enable Auto-Launch WIKI.KOL "Daily-Special" Page.\n >  Set < false > To Disable Auto-Launch.\n > *Note* After Inital Set-Up, Use: "set boneTrackEnableWiki=<false/true>".\n >  Set:  true |OR| false  `;  
if (get_property(`boneTrackEnableWiki`) == " ") {
      set_property("boneTrackEnableWiki", user_prompt(WikiPrompt));{
    if (get_property(`boneTrackEnableWiki`) == "true")    
        print(`Setting AutoLaunch [ON]`,`green`);
            print(`"set boneTrackEnableWiki=false" to turn off wiki autolaunch.`,`navy`); 
        }
    if (get_property(`boneTrackEnableWiki`) == "false") {        
                print(`Setting AutoLaunch [OFF]`,`orange`);
                    print(`"set boneTrackEnableWiki=true" to turn on wiki autolaunch.`,`navy`);
    } 
  }
//checks everywhere for ownership
boolean OwnDailySpecial(item x) { //done
        print(`> Testing ownership of [` + x +`]`,`navy`);
        return (available_amount(x) + closet_amount(x) + storage_amount(x) + display_amount(x) != 0);
}
  item kb = $item[knucklebone];
  item dailySpecial = get_property("_crimboPastDailySpecialItem").to_item();
  boolean tradable = is_tradeable(dailySpecial);
  boolean yesBuy_Special = get_property("_crimboPastDailySpecial").to_boolean();
      int lifeNum = get_property("ascensionsToday").to_int();
      int legNum = lifeNum + 1;
      int buy_special = yesBuy_Special.to_int();
      int item_number = get_property("_crimboPastDailySpecialItem").to_int(); 
      int specialMallPrice = mall_price(dailySpecial).to_int();
      int specialBonePrice = get_property("_crimboPastDailySpecialPrice").to_int();
      int DSowned = item_amount(dailySpecial).to_int();
      int currentTotalBones = (available_amount(kb) + closet_amount(kb) + storage_amount(kb) + display_amount(kb));
      int collectedBones = get_property("_knuckleboneDrops").to_int();
      int collectedRestBones = get_property(`_knuckleboneRests`).to_int();
      int totalBonesCollected = to_int(collectedBones - collectedRestBones);
      int allBonesCollected  = to_int(collectedBones);         
      float neededBones = to_int(95 - collectedBones);
      float neededRestBones = to_int(5 - collectedRestBones); 
      float totalBonesNeeded = to_int(neededBones + neededRestBones);
      float meatPerBone =to_int(specialMallPrice/specialBonePrice);
      float xy = modifier_eval(specialMallPrice/(meatPerBone+1));
      float DS_Value = modifier_eval(xy/100);  
  string leg_num = 'Leg'+legNum;
  string daily_Special = (item_number.to_item());
//Message strings
          string boneMessage1 = `|==============|> KNUCKLEBONE DAILY BREAKDOWN <|=============|`;
          string totalBonesMessage2  = `> Total Knucklebones in Inventory:  [`+currentTotalBones+`]`;     
          string dailyBonesMessage3a  = `> Daily Knucklebone Collection:`;  
          string dailyBonesMessage3b  = `> "Adv-Bones":  [`+totalBonesCollected+`/95]`;
          string dailyBonesMessage3c  = `> "Rest-Bones":  [`+collectedRestBones+`/5]`;
          string collectedBonesMessage4  = `> [`+allBonesCollected+`/100] Knucklebones Collected For The Day.`;
          string priceBoneMessage5  = `> The Daily Special Is: [`+(daily_Special)+`].`;
          string priceBoneMessage6 = `> Knucklebone Price Of: [`+specialBonePrice+`] Knucklebones.`;
          string priceMallMessage7 = `> Mall Price Of: [`+specialMallPrice+`] Meat.`;
          string canAffordMessage8  = `'> You [CAN] Afford The Daily Special: `+(daily_Special)+`!`;
          string cannotAffordMessage10  = `'> You [CANNOT] Afford The Daily Special: `+(daily_Special)+`!`;
          string boneMessage11  = `> That's A Return Of: [`+meatPerBone+`] Meat/Per/Pnucklebone!`;
          string boneMessage12  = `> A Value Of [`+rnum(DS_Value)+`%] Per/Knucklebone. (SpecialMallPrice/MeatPerBone)/(100)` ;
          string ownDSMessage13 = `> We Own [`+DSowned+`] `+(daily_Special);
          string yesBuyMessage14 = `> We [HAVE] Purchased `+(daily_Special)+` With Knucklebones.`;
          string noBuyMessage15 = `> We Have [NOT] Purchased `+(daily_Special)+` With Knucklebones.`;
          string notTradableMessage16 = `> `+(daily_Special)+` Is Not Tradable.`;
          string boneMessageBreak20 = `--------------------------------------------------------------------------------------------------------`;
          string boneMessageEnd = `|========================================================|`;
static {
//logs DSaily special info in KOL/data/Knucklebone Tracking
      string [string] boneData;
            boneData["1. "+dailySpecial+" Bone Price:"] = specialBonePrice;
            boneData["2. "+dailySpecial+" Mall Price:"] = specialMallPrice;
            boneData["3. Total Inventory Knucklebones:"] = (currentTotalBones);
            boneData["4. Meat/Per/Knucklebone:"] = meatPerBone;
            boneData["5. Value/Per/Knucklebone:"] = DS_Value;
            boneData["6. Daily Collected Knucklebone:"] = allBonesCollected;
            boneData["7. #/of Daily-Special Owned:"] = DSowned;
            boneData["8. #/of Daily-Special Buy w/Bones:"] = buy_special;
        map_to_file(boneData, "/boneTrack/"+my_name()+"/DailySpecial Tracking/"+(daily_Special)+"_"+item_number+"/"+today_to_string()+"_"+(leg_Num)+".txt");
//logs if we bought item in the data file  
  if (yesBuy_Special)  {
      string [string] boneBuyData;
        file_to_map("/boneTrack/"+my_name()+"/BoneValue Tracking/BUY.txt" , boneBuyData);
            boneBuyData[today_to_string()+"_"+item_number+" Purchased: Qty["+buy_special+"] For"] = specialBonePrice+" Knucklebones.";
            boneBuyData[today_to_string()+"_"+item_number+" Owned: Qty["+DSowned+"] Mall Price:"] = specialMallPrice;  
        map_to_file(boneBuyData, "/boneTrack/"+my_name()+"/BoneValue Tracking/BUY.txt");
//maps and logs MPB
  }   string [string] boneMData;
        file_to_map("/boneTrack/"+my_name()+"/BoneValue Tracking/MPB.txt" , boneMData);
            boneMData[today_to_string()+"_"+item_number+" MPB:"] = meatPerBone;
        map_to_file(boneMData, "/boneTrack/"+my_name()+"/BoneValue Tracking/MPB.txt");
//maps and logs MPB
      string [string] boneVData;
        file_to_map("/boneTrack/"+my_name()+"/BoneValue Tracking/VPB.txt", boneVData);
            boneVData[today_to_string()+"_"+item_number+" VPB:"] = DS_Value;
        map_to_file(boneVData, "/boneTrack/"+my_name()+"/BoneValue Tracking/VPB.txt");
}
//returns average VPB
      float total_vpb = 0;
      int count = 0;   
      float [string] boneVPBData;
    file_to_map("/boneTrack/"+my_name()+"/BoneValue Tracking/VPB.txt", boneVPBData);
                /*   //print for debugging
                foreach it, boneVPBData in boneVPBData
                  print( it  + boneVPBData);
                */
  foreach it, data in boneVPBData {
            total_vpb += data.to_float();
            count++;
    } if (count > 0) {
           //print for debug print("average: " + (total_vpb / count));
      } else {
            print("No data found.");  }
      float averageVPB = total_vpb / count;
  string [string] AvgVPB;
      map_to_file(AvgVPB, "/boneTrack/"+my_name()+"/BoneValue Tracking/AvgVPB.txt");
      file_to_map("/boneTrack/"+my_name()+"/BoneValue Tracking/AvgVPB.txt", AvgVPB); 
//returns average MPB   
      float total_mpb = 0;
      int count2 = 0;   
      float [string] boneMPBData;
    file_to_map("/boneTrack/"+my_name()+"/BoneValue Tracking/MPB.txt", boneMPBData);
                /*   //print for debugging
                foreach it, boneMPBData in boneMPBData
                  print( it  + boneMPBData);
                */
  foreach it, data in boneMPBData {
            total_mpb += data.to_float();
            count2++;
      } if (count2 > 0) {
                //print for debug print("average: " + (total_mpb / count2));
        } else {
                print("No data found.");
                }
      float averageMPB = total_mpb / count2;
  string [string] AvgMPB;
      map_to_file(AvgMPB, "/boneTrack/"+my_name()+"/BoneValue Tracking/AvgMPB.txt");
      file_to_map("/boneTrack/"+my_name()+"/BoneValue Tracking/AvgMPB.txt", AvgMPB); 
void main() {
                print(boneMessage1,'navy');
      print(boneMessageBreak20,'orange');
                print(totalBonesMessage2,'navy');
                print(dailyBonesMessage3a,'navy');
                print(dailyBonesMessage3b,'navy');
                print(dailyBonesMessage3c,'navy');
  if (allBonesCollected == 100) {   
                print(collectedBonesMessage4,'green');
         } else print(collectedBonesMessage4,'red'); 
      print(boneMessageBreak20,'orange'); 
                print(priceBoneMessage5,'navy');
                print(priceBoneMessage6,'navy');
  if (currentTotalBones > specialBonePrice) {
                print(canAffordMessage8, 'green');
        } else {  print(cannotAffordMessage10, 'red');  } 
                print(boneMessageBreak20,'orange');
    if (tradable) {
        if (specialMallPrice > trigger_MallPrice_High) {
                print(priceMallMessage7, 'green');
      } if (specialMallPrice < trigger_MallPrice_Low) {
                print(priceMallMessage7, 'red'); 
      } else if (specialMallPrice > trigger_MallPrice_Low) {
                print(priceMallMessage7,'navy'); }
    if (meatPerBone > trigger_MeatPerBone_High) {
                print(boneMessage11,'green');
      } else if (meatPerBone < trigger_MeatPerBone_Low) {
                print(boneMessage11,'red');
      } else if (meatPerBone > trigger_MeatPerBone_Low) {
                print(boneMessage11,'navy'); }
    if (DS_Value > trigger_ValuePerBone_High) {
                print(boneMessage12,'green');
      } else if (DS_Value < trigger_ValuePerBone_Low) {
                print(boneMessage12,'red');
      } else if (DS_Value > trigger_ValuePerBone_Low) {
                print(boneMessage12, 'navy');   }
      } else if (!tradable) {
                print(notTradableMessage16, 'navy');  }         
      print(boneMessageBreak20,'orange');
  if (OwnDailySpecial(dailySpecial)) {
                print(ownDSMessage13, 'green');
        } else {  print(ownDSMessage13, 'red');
      } if (yesBuy_Special) {
                print(yesBuyMessage14,'green');
        } else    print(noBuyMessage15,'navy');
      print(boneMessageBreak20,'orange');
                print(`> As of: [`+today_to_string()+`]`,`navy`); 
                print(`> Average "Daily Special" Meat/Per/Knucklebone: [` + rnum(averageMPB)+`]`,`navy`);
                print(`> Average "Daily Special" Value/Per/Knucklebone: [` + rnum(averageVPB)+`]`,`navy`);
      print(boneMessageBreak20,'orange');
    print(boneMessageEnd,'navy');
//auto-lauch wiki page
if ((get_property(`boneTrackEnableWiki`)).to_string() == `true`){
      cli_execute(`lookup {(daily_Special)}`);
         exit;  }
  else { exit; }

}




