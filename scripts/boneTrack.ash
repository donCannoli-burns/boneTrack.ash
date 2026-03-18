script "boneTrack.ash"
notify "donCannoli"

// color thresholds
int trigger_MallPrice_High    = 15000000;
int trigger_MallPrice_Low     =  3000000;
int trigger_MeatPerBone_High  =    10000;
int trigger_MeatPerBone_Low   =     1000;
int trigger_ValuePerBone_High =       15;
int trigger_ValuePerBone_Low  =        7;

boolean OwnDailySpecial(item x) {
	print(`> Testing ownership of [{x}]`, "navy");
	return (0 < available_amount(x) + closet_amount(x) + storage_amount(x) + display_amount(x));
}

// ask once if wiki should auto-launch, store as pref
void initWikiSetting() {
	if (get_property(`boneTrackEnableWiki`) != "")
		return;
	string prompt = `Enable auto-launch of KoL Wiki\'s SoCP Daily Special page?\n` +
				`Note: after inital setup, reset this with CLI:\n` +
				`"set boneTrackEnableWiki = [false|true]"`;
	set_property("boneTrackEnableWiki", user_confirm(prompt));
	if (get_property(`boneTrackEnableWiki`) == "true") {
		print(`Setting AutoLaunch [ON]`, `green`);
		print(`"set boneTrackEnableWiki=false" to turn off wiki autolaunch.`, `navy`);
	}
	else {
		print(`Setting AutoLaunch [OFF]`, `orange`);
		print(`"set boneTrackEnableWiki=true" to turn on wiki autolaunch.`, `navy`);
	}
}

// raw and computed values
record BoneStats {
	item    dailySpecial;
	boolean tradable;
	boolean yesBuy_Special;
	int     lifeNum;
	int     buy_special;
	int     item_number;
	int     specialMallPrice;
	int     specialBonePrice;
	int     DSowned;
	int     currentTotalBones;
	int     collectedBones;
	int     collectedRestBones;
	int     totalBonesCollected; // adv bones only
	int     allBonesCollected; // adv + rest
	float   meatPerBone;
	float   DS_Value;
	string  leg_num;
	string  daily_Special;
};

BoneStats gatherStats() {
	BoneStats s;
	item kb = $item[knucklebone];
	s.dailySpecial      = get_property("_crimboPastDailySpecialItem").to_item();
	s.tradable          = is_tradeable(s.dailySpecial);
	s.yesBuy_Special    = get_property("_crimboPastDailySpecial").to_boolean();
	s.lifeNum           = get_property("ascensionsToday").to_int();
	s.buy_special       = s.yesBuy_Special.to_int();
	s.item_number       = get_property("_crimboPastDailySpecialItem").to_int();
	s.specialMallPrice  = mall_price(s.dailySpecial).to_int();
	s.specialBonePrice  = get_property("_crimboPastDailySpecialPrice").to_int();
	s.DSowned           = item_amount(s.dailySpecial).to_int();
	s.currentTotalBones = available_amount(kb) + closet_amount(kb) + storage_amount(kb) + display_amount(kb);
	s.collectedBones     = get_property("_knuckleboneDrops").to_int();
	s.collectedRestBones = get_property("_knuckleboneRests").to_int();
	s.totalBonesCollected = s.collectedBones - s.collectedRestBones;
	s.allBonesCollected   = s.collectedBones;
	s.meatPerBone       = to_int(s.specialMallPrice / s.specialBonePrice);
	float xy            = modifier_eval(s.specialMallPrice / (s.meatPerBone + 1));
	s.DS_Value          = modifier_eval(xy / 100);
	s.leg_num           = "Leg" + (s.lifeNum + 1);
	s.daily_Special     = s.item_number.to_item();
	return s;
}

// file logging daily-special snapshot and rolling MPB/VPB
void logDailyData(BoneStats s) {
	string base = "/boneTrack/" + my_name();
	string[string] boneData;
	boneData["1. " + s.dailySpecial + " Bone Price:"]  = s.specialBonePrice;
	boneData["2. " + s.dailySpecial + " Mall Price:"]  = s.specialMallPrice;
	boneData["3. Total Inventory Knucklebones:"]       = s.currentTotalBones;
	boneData["4. Meat/Per/Knucklebone:"]               = s.meatPerBone;
	boneData["5. Value/Per/Knucklebone:"]              = s.DS_Value;
	boneData["6. Daily Collected Knucklebone:"]        = s.allBonesCollected;
	boneData["7. #/of Daily-Special Owned:"]           = s.DSowned;
	boneData["8. #/of Daily-Special Buy w/Bones:"]     = s.buy_special;
	map_to_file(boneData, `{base}/DailySpecial Tracking/{s.daily_Special}_{s.item_number}/{today_to_string()}_{s.leg_num}.txt`);

	// purchase log (only when we actually bought with bones today)
	if (s.yesBuy_Special) {
		string buyPath = base + "/BoneValue Tracking/BUY.txt";
		string[string] boneBuyData;
		file_to_map(buyPath, boneBuyData);
		boneBuyData[today_to_string() + "_" + s.item_number + " Purchased: Qty[" + s.buy_special + "] For"] = s.specialBonePrice + " Knucklebones.";
		boneBuyData[today_to_string() + "_" + s.item_number + " Owned: Qty[" + s.DSowned + "] Mall Price:"] = s.specialMallPrice;
		map_to_file(boneBuyData, buyPath);
	}

	// rolling meat-per-bone / value-per-bone logs
	string mpbPath = base + "/BoneValue Tracking/MPB.txt";
	string[string] boneMData;
	file_to_map(mpbPath, boneMData);
	boneMData[today_to_string() + "_" + s.item_number + " MPB:"] = s.meatPerBone;
	map_to_file(boneMData, mpbPath);
	string vpbPath = base + "/BoneValue Tracking/VPB.txt";
	string[string] boneVData;
	file_to_map(vpbPath, boneVData);
	boneVData[today_to_string() + "_" + s.item_number + " VPB:"] = s.DS_Value;
	map_to_file(boneVData, vpbPath);
}


// compute historical averages
record Averages {
	float vpb;
	float mpb;
};

Averages computeAverages() {
	string base = "/boneTrack/" + my_name() + "/BoneValue Tracking/";
	Averages avg;

	// Average Value-Per-Bone
	float total_vpb = 0;
	int   vpb_count = 0;
	float[string] boneVPBData;
	file_to_map(base + "VPB.txt", boneVPBData);
	foreach it, data in boneVPBData {
		total_vpb += data.to_float();
		vpb_count++;
	}
	if (vpb_count == 0) { print("No VPB data found."); }
	avg.vpb = (vpb_count > 0) ? (total_vpb / vpb_count) : 0;
	string[string] AvgVPB;
	map_to_file(AvgVPB, base + "AvgVPB.txt");
	file_to_map(base + "AvgVPB.txt", AvgVPB);

	// Average Meat-Per-Bone
	float total_mpb = 0;
	int   mpb_count = 0;
	float[string] boneMPBData;
	file_to_map(base + "MPB.txt", boneMPBData);
	foreach it, data in boneMPBData {
		total_mpb += data.to_float();
		mpb_count++;
	}
	if (mpb_count == 0) { print("No MPB data found."); }
	avg.mpb = (mpb_count > 0) ? (total_mpb / mpb_count) : 0;
	string[string] AvgMPB;
	map_to_file(AvgMPB, base + "AvgMPB.txt");
	file_to_map(base + "AvgMPB.txt", AvgMPB);

	return avg;
}

// print colorful CLI
void printReport(BoneStats s, float averageVPB, float averageMPB) {
	string bar  = `|= == == == == == == = | > KNUCKLEBONE DAILY BREAKDOWN < |= == == == == == == |`;
	string div  = `-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --`;
	string foot = `|= == == == == == == == == == == == == == == == == == == == == == == == == == == = |`;
	// header
	print(bar, 'navy');
	print(div, 'orange');
	// bone inventory & daily collection
	print(`> Total Knucklebones in Inventory: [{s.currentTotalBones}]`, 'navy');
	print(`> Daily Knucklebone Collection:`, 'navy');
	print(`>   "Adv-Bones"  : [{s.totalBonesCollected - 5}/ 95]`, 'navy');
	print(`>   "Rest-Bones" : [{s.collectedRestBones}/ 5]`,  'navy');
	string collectedMsg = `> [{s.allBonesCollected}/ 100] Knucklebones Collected For The Day.`;
	print(collectedMsg, (s.allBonesCollected == 100) ? 'green' : 'red');
	print(div, 'orange');
	// affordability
	print(`> The Daily Special Is: [{s.daily_Special}].`, 'navy');
	print(`> Knucklebone Price Of: [{s.specialBonePrice}] Knucklebones.`, 'navy');
	string affordMsg = `> You [CAN{(s.currentTotalBones > s.specialBonePrice) ? "" : "NOT"}] Afford The Daily Special: ${s.daily_Special}!`;
	print(affordMsg, (s.currentTotalBones > s.specialBonePrice) ? 'green' : 'red');
	print(div, 'orange');
	// value metrics
	if (s.tradable) {
		string mallMsg = `> Mall Price Of: [{s.specialMallPrice}] Meat.`;
		string mpbMsg = `> That\'s A Return Of: [{s.meatPerBone}] Meat/Per/Knucklebone!`;
		string vpbMsg = `> A Value Of [{to_string(s.DS_Value, "%.3f")}%] Per/Knucklebone.` +
						`(SpecialMallPrice / MeatPerBone) / 100`;
		// mall price colour
		if (s.specialMallPrice > trigger_MallPrice_High)
			print(mallMsg, 'green');
		else if (s.specialMallPrice < trigger_MallPrice_Low)
			print(mallMsg, 'red');
		else
			print(mallMsg, 'navy');
		// meat-per-bone colour
		if (s.meatPerBone > trigger_MeatPerBone_High)
			print(mpbMsg, 'green');
		else if (s.meatPerBone < trigger_MeatPerBone_Low)
			print(mpbMsg, 'red');
		else
			print(mpbMsg, 'navy');
		// value-per-bone colour
		if (s.DS_Value > trigger_ValuePerBone_High)
			print(vpbMsg, 'green');
		else if (s.DS_Value < trigger_ValuePerBone_Low)
			print(vpbMsg, 'red');
		else
			print(vpbMsg, 'navy');
	}
	else
		print(`> {s.daily_Special} is Not Tradable.`, 'navy');
	print(div, 'orange');
	// ownership & purchase
	string ownMsg = `> We Own [{s.DSowned}] {s.daily_Special}`;
	print(ownMsg, OwnDailySpecial(s.dailySpecial) ? 'green' : 'red');
	print(`> We {(s.yesBuy_Special) ? "[HAVE]" : "[HAVE NOT]"} Purchased {s.daily_Special} With Knucklebones.`, 'green');
	print(div, 'orange');
	// historical averages
	print(`> As of: [{today_to_string()}]`, 'navy');
	print(`> Average "Daily Special" Meat / Per / Knucklebone : [{to_string(averageMPB, "%.3f")}]`, 'navy');
	print(`> Average "Daily Special" Value / Per / Knucklebone: [{to_string(averageVPB, "%.3f")}]`, 'navy');
	print(div, 'orange');
	print(foot, 'navy');
}

// optional wiki launcher
void maybeOpenWiki(string daily_Special) {
	if (get_property(`boneTrackEnableWiki`).to_string() == `true`)
		cli_execute(`lookup ` + daily_Special);
}

void main() {
	initWikiSetting();
	BoneStats s = gatherStats();
	logDailyData(s);
	Averages avg = computeAverages();
	printReport(s, avg.vpb, avg.mpb);
	maybeOpenWiki(s.daily_Special);
}
