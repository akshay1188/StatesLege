//
//  TexLegeLibrary.m
//  TexLege
//
//  Created by Gregory Combs on 2/4/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "TexLegeLibrary.h"

NSString *stringForChamber(NSInteger chamber, TLStringReturnType type) {
	NSString *chamberString = nil;
	
	if (type == TLReturnFull) {
		switch (chamber) {
			case HOUSE:
				chamberString = @"House";
				break;
			case SENATE:
				chamberString = @"Senate";
				break;
			case BOTH_CHAMBERS:
			case JOINT:
			default:
				chamberString = @"Joint";
				break;
		}
	}
	else if (type == TLReturnInitial) {
		switch (chamber) {
			case SENATE:
				chamberString = @"(S)";
				break;
			case HOUSE:
				chamberString = @"(H)";
				break;
			case BOTH_CHAMBERS:
			case JOINT:
			default:
				chamberString = @"(J)";
				break;
		}	
	}
	else if (type == TLReturnAbbrev) {
		if (type == TLReturnAbbrev) {
			switch (chamber) {
				case SENATE:
					chamberString = @"Sen.";
					break;
				case HOUSE:
					chamberString = @"Rep.";
					break;
				case BOTH_CHAMBERS:
				case JOINT:
				default:
					chamberString = @"Jnt.";
					break;
			}
		}		
	}
	
	return chamberString;
}


NSString *stringForParty(NSInteger party, TLStringReturnType type) {
	NSString *partyString = nil;
	
	if (type == TLReturnFull) {
		switch (party) {
			case DEMOCRAT:
				partyString = @"Democrat";
				break;
			case REPUBLICAN:
				partyString = @"Republican";
				break;
			default:
				partyString = @"Independent";
				break;
		}		
	}
	if (type == TLReturnInitial) {
		switch (party) {
			case DEMOCRAT:
				partyString = @"D";
				break;
			case REPUBLICAN:
				partyString = @"R";
				break;
			default:
				partyString = @"I";
				break;
		}
	}
	if (type == TLReturnAbbrev) {
		switch (party) {
			case DEMOCRAT:
				partyString = @"Dem.";
				break;
			case REPUBLICAN:
				partyString = @"Rep.";
				break;
			default:
				partyString = @"Ind.";
				break;
		}
	}
	return partyString;
}