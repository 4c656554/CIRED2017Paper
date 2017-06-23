pragma solidity ^0.4.6;
contract Supplier {  
    
    event MarketPriceAgreed(int8 mprice); // Event
    event ImbalancetoSO(int Imbalance);
    event EstimatedNetUseWhAdjusts(int EstimatedNetUseWh);
    event addressregistered(address addy);
    
//******************************************************************************    
//Initialise members    
    
    address[] public MemberAddresses;        // list of all user addresses in this contract instance    
    mapping(address => int256) public EstimatedUseWh;            // list of Wh usage estimates    
    address[] public CriticalAddresses;        // list of critical user addresses in this contract instance - users that must remain connected and accept the market price    
    address[] public AcceptedOfferAddresses;        // list of critical user addresses in this contract instance - users that must remain connected and accept the market price  
	int256[] public AcceptedOfferVols;
    mapping(address => int256) public ActualUseWh;            // list of recorded Wh usages for member addresses (at same indexing as MemberAddresses)    
    mapping(address => int256) OfferedDemandWh;            // list of offered Wh usages for non-critical users - those that will be disconnected if market price under their offer    
    int256[] public OfferedDemandOffer;        // list of offers for Wh usages for non-critical users - those that will be disconnected if market price under their offer    
    address[] public DemandOfferAddresses;        // list of addresses of non-critical users - those that will be disconnected if market price under their offer    
    mapping(address => int256) public OfferedGenWh;            // list of offered Wh usages for non-critical users - those that will be disconnected if market price under their offer    
    int256[] public OfferedGenOffer;        // list of offers for Wh usages for non-critical users - those that will be disconnected if market price under their offer    
    address[] public GenOfferAddresses;        // list of addresses of non-critical users - those that will be disconnected if market price under their offer    
    int256[] public DiffEstActUseWh;        // list of differences between usage estimates and actual usage for member addresses    
    int256[] public UseValuePU;                //    
    int256[] public DiffValuePU;            //    
    int256 public ActualNetUseWh;    
    mapping(address => int256) public DifferenceWh;    
    mapping(int8 => int256[]) public OfferstoWhmapDemand;    
    mapping(int8 => int256[]) public OfferstoWhmapGen;    
    mapping(int8 => address[]) public GenOfferstoOfferAddressesMap;  
    mapping(int8 => address[]) public DemandOfferstoOfferAddressesMap;  
    address[] public RewardAccounts;    
    address[] public PenaltyAccounts;    
    address[] public RewardOfferAccounts;    
    address[] public PenaltyOfferAccounts;    
    int256 public Reward; 
	int256 public LossETHpu;
    int256 public Penalty; 
    int256 public Volume; 
	int256 public RewardSum=0;
    int256 public noNonCriticalUSers; 
    int public tempsumeth=0;
	int public tempsumvol=0;
	uint256 public b;
        
    int256 public UoSCharge =1;                    // Use of system cost to be set by network operator    
    int256 public LossesWh;                    // Losses for the section of public network associated with the     
    int256 public MarketPrice;                // the market price, set by the head contract    
    int256 public EstimatedNetUseWh;        // estimated net use - sent to the parent contract or , if head contract, used in determination of market price    
    int256 public NoSubContractOfferAddresses =0;    //     
    int256 public counter = 0;    
    uint public NoMembers;    
    int public totaldeposits;    
    mapping(address => int256) public balanceOf;    
    bool public ParentExists = false;    
    int256 public sendlevel = 20000000000000000000;    
    int256 public minDeposit =10000000000000000000;    
	int256 public noGenOffers =0;
	int256 public noDemOffers =0;
	int256 public noOffers = 0;
    bool public RewardAdditionalDemand;        // flag for reward of demand or gen.    
	int256 public A=0; 
	int256 public B=0;
	int256 public C=0;
	int256 public D=0;
      

function getAddresses() constant returns (address[]){
    return MemberAddresses;      
}
function getGenOffers() constant returns (int256[]){
    return OfferedGenOffer;      
}
function getGenOffersMap(int8 off) constant returns (address[],int256[]){
    return (GenOfferstoOfferAddressesMap[off],OfferstoWhmapGen[off]); 
    
}
function getAcceptedAddresses() constant returns (address[]){
    return AcceptedOfferAddresses; 
}
function getRewardAccounts() constant returns (address[]){
    return RewardAccounts; 
}
function getPenaltyAccounts() constant returns (address[]){
    return PenaltyAccounts; 
}
function getAcceptedVols() constant returns (int256[]){
    return AcceptedOfferVols; 
}

function getElementInMappedArray(int256[] inarray,uint loc) constant returns (int256){
    return inarray[loc]; 
}

function getLengthArray(int256[] inarray) constant returns (int256){
    return int(inarray.length);
}

function getEstimatedUseWhs(address a) constant returns (int256){
    return EstimatedUseWh[a]; 
}

function getActualUseWhs(address a) constant returns (int256){
    return ActualUseWh[a]; 
}

function getDifferencesWhs(address a) constant returns (int256){
    return DifferenceWh[a]; 
}

    function getOrderMag(int256 input) constant returns (int256){
        int counter=0;
		if (input<0){
		    input=input*-1;
        }
            while((input/10)>=1){
                input = input/10;
                counter++;
            }
        
        return counter;
    }

//******************************************************************************    
//Initialise Inter-contract Structure    
    
    function registerAddress(address regaddress) { // function by which list of member addresses is set    
        MemberAddresses.push(regaddress);    
        NoMembers = MemberAddresses.length;    
        }    
            
    
//******************************************************************************    
    
//******************************************************************************    
//Pre Time of Use     
    
    function () payable { // called when transaction sent to contract - this deposits Ether and registers user    
        //if (crowdsaleClosed) throw;    
        int amount = int(msg.value);    
        balanceOf[msg.sender] = amount;    
        totaldeposits += amount;   
        registerAddress(msg.sender);
        addressregistered(msg.sender);
    }    
        
    function submitEstimatedUseWh(int256 Wh) {    // users submit estimates,     
        CriticalAddresses.push(msg.sender);            // address of sender must be a critical user    
                                                    // to add check if msg.sender in MemberAddresses    
        EstimatedUseWh[msg.sender] =Wh;                    // estimated use has same indexing as CriticalAddresses    
        EstimatedNetUseWh += Wh;                    // running total    
   
    }    
        
        
        
    function submitOfferedDemandWh(int256 Wh, int8 offer1) {     // users offer usage and price    
        DemandOfferAddresses.push(msg.sender);        // list of non-critical user addresses    
        OfferedDemandWh[msg.sender]=Wh;                    // add Wh reading    
        //OfferedNetDemandWh += Wh;                    // running total of offered usage    
        OfferedDemandOffer.push(offer1);            // list of price offers same indexing as OfferAddresses 
        DemandOfferstoOfferAddressesMap[offer1].push(msg.sender);  
		noDemOffers++;
    }    
        
  
        
    function submitOfferedGenWh(int256 Wh, int8 offer1) {     // users offer usage and price    
        GenOfferAddresses.push(msg.sender);        // list of non-critical user addresses    
        OfferedGenWh[msg.sender]=Wh;                    // add Wh reading    
        //OfferedNetGenWh += Wh;                    // running total of offered usage    
        OfferedGenOffer.push(offer1);            // list of price offers same indexing as OfferAddresses    
        GenOfferstoOfferAddressesMap[offer1].push(msg.sender);
        OfferstoWhmapGen[offer1].push(Wh);
		noGenOffers++;
    }    
        
       
    //function that waits 3 blocks and then calls PasstoParent() if parent else does market    
 
  
    
    function setMarketPrice(){    
        int8 offer = 0;    
        //D=1;
		int k=0;
		uint loc=0;

		EstimatedNetUseWh=EstimatedNetUseWh+LossesWh;
        if (EstimatedNetUseWh > 0){//excess demand    
       // 
            // iterate OfferedDemandWh, stop when dmeand ~= gen. that is market price.    
                
               
            while(EstimatedNetUseWh > 0 && noOffers<noGenOffers){
				A=int(OfferstoWhmapGen[offer].length);
                for(k=0;k<A;k++){
					//B=1;
                    loc=uint(k);
					if((OfferstoWhmapGen[offer][loc])*-1<=(EstimatedNetUseWh)){ //if(getOrderMag(OfferstoWhmapGen[offer][loc])<=getOrderMag(EstimatedNetUseWh)){
						//C=1;
						EstimatedNetUseWh += OfferstoWhmapGen[offer][loc];  
						tempsumeth-=OfferstoWhmapGen[offer][loc]*offer;
						tempsumvol-=OfferstoWhmapGen[offer][loc];
						//EstimatedNetUseWhAdjusts(EstimatedNetUseWh);
						//noNonCriticalUSers += int(GenOfferstoOfferAddressesMap[offer].length);
						AcceptedOfferAddresses.push(GenOfferstoOfferAddressesMap[offer][loc]);
						AcceptedOfferVols.push(OfferstoWhmapGen[offer][loc]);
						
					}
                    noOffers++; 
                }
                
                offer++;    
            }
            MarketPrice = int256(tempsumeth*1000000000000000000)/(tempsumvol);//convert from ETH to WEI/1000 for Wh to kWh
            EstimatedNetUseWh=EstimatedNetUseWh;//-LossesWh;
			//offer = 0;
        }    
        //else    
       // {    
            // iterate OfferedUseWh, stop when dmeand ~= gen. that is market price.    
            
            //while(EstimatedNetUseWh < 0 && noOffers<noDemOffers){ 
             //   for(k=0;k<OfferstoWhmapDemand[offer].length;k++){
              //      noOffers++;
			//		if(getOrderMag(OfferstoWhmapDemand[offer][k])<=getOrderMag(EstimatedNetUseWh)){
				//		EstimatedNetUseWh += OfferstoWhmapDemand[offer][k]; 
			//			//EstimatedNetUseWhAdjusts(EstimatedNetUseWh);                
			//			//noNonCriticalUSers += int(DemandOfferstoOfferAddressesMap[offer].length);
			//			AcceptedOfferAddresses.push(DemandOfferstoOfferAddressesMap[offer][k]);
			//		}
                    
            //    }
                //offer++;    
            //}    
            //MarketPrice = offer;
            //offer = 0;
			//noOffers=0;
        //}    
        // send market price/accept offers at or below offer price
        //MarketPriceAgreed(MarketPrice);
    }
    
    function submitLosses(int256 LossesWhfromSO){
		LossesWh = LossesWhfromSO;
        ImbalancetoSO(EstimatedNetUseWh + LossesWhfromSO);
    }
        
        
//******************************************************************************    
//Settlement    
    
    
// Users submit actual usage    
// waits x time, if not submitted assumes charges penalty rate    
    
    function submitActualUseWh(int256 WhUsed) {    
        counter++;    
        ActualUseWh[msg.sender]= WhUsed;    
        ActualNetUseWh += WhUsed;
		if(WhUsed>0){
			Volume +=WhUsed;
		}
		else{
			Volume -=WhUsed;
		}
    }    
        
// difference between predicted use and actual use calculated    
    function CompareActualEstimated() {    
        ActualNetUseWh=ActualNetUseWh+LossesWh;//+LossesWh;
  
        for (uint i = 0; i < CriticalAddresses.length; i++){    
          DifferenceWh[CriticalAddresses[i]] = ActualUseWh[CriticalAddresses[i]] - EstimatedUseWh[CriticalAddresses[i]];    
          if (DifferenceWh[CriticalAddresses[i]] <0){    
            RewardAccounts.push(CriticalAddresses[i]);    
            }    
          else {    
            PenaltyAccounts.push(CriticalAddresses[i]);    
          }    
        }    
    
    }    
    
            
    function  setUoSCharge(int amount){    
    // UoSCharge set by NO    
        UoSCharge = amount;    
    }    
        
    
            
// Calculates and pays reward//charges for penalties     
    function PayReward() {    
        Reward = (MarketPrice*EstimatedNetUseWh)/(EstimatedNetUseWh+ActualNetUseWh); 
        LossETHpu = (MarketPrice*LossesWh)/((Volume));
        int R = 0;
		int D = 0;
		int actUse;
   
       for (uint i = 0; i < RewardAccounts.length; i++){    
                // get payment for losses    
                // pay reward account for help per Wh 
    		R = Reward*DifferenceWh[RewardAccounts[i]];
    		if(R<0){
                R = (-1*R);    
            }
    		if(ActualUseWh[RewardAccounts[i]]<0){
                actUse = (-1*ActualUseWh[RewardAccounts[i]]);    
            }
            else{
                actUse = (ActualUseWh[RewardAccounts[i]]);
            }
            balanceOf[RewardAccounts[i]] = balanceOf[RewardAccounts[i]] - MarketPrice*(ActualUseWh[RewardAccounts[i]])-UoSCharge+R-(LossETHpu*(actUse));    //+ MarketPrice*(ActualUseWh[RewardAccounts[i]]-UoSCharge)//
    		RewardSum += R;
             //   if (balanceOf[RewardAccounts[i]] > sendlevel){
             //       if(!RewardAccounts[i].send(uint(balanceOf[RewardAccounts[i]]) - uint(minDeposit))){
             //           throw;
             //       }
             //       }
        } // send profit back
		Penalty=RewardSum/(EstimatedNetUseWh-ActualNetUseWh);

        
        for (i = 0; i < PenaltyAccounts.length; i++){    
            // get payment form penalty accounts for misestimation and losses
            if(ActualUseWh[PenaltyAccounts[i]]<0){
                actUse = (-1*ActualUseWh[PenaltyAccounts[i]]);    
            }
            else{
                actUse = (ActualUseWh[PenaltyAccounts[i]]);
            }
			D=	Penalty*DifferenceWh[PenaltyAccounts[i]];
			if(D<0){
                D = (-1*D);    
            }

            balanceOf[PenaltyAccounts[i]] = balanceOf[PenaltyAccounts[i]]  - MarketPrice*(ActualUseWh[PenaltyAccounts[i]])-UoSCharge - D-(LossETHpu*(actUse));//Reward*DifferenceWh[RewardAccounts[i]];//Reward/int(PenaltyAccounts.length);    //)//
       } 			
       for (i = 0; i < AcceptedOfferAddresses.length; i++){    
            // get payment form penalty accounts for misestimation and losses                    
          balanceOf[AcceptedOfferAddresses[i]] = balanceOf[AcceptedOfferAddresses[i]] + MarketPrice*(ActualUseWh[AcceptedOfferAddresses[i]])+UoSCharge+LossETHpu*(ActualUseWh[AcceptedOfferAddresses[i]]);    
       }  

           
 
    }
	
	
    function getAbs(int256 a) {
        if(a<0){
            b = uint(-1*a);    
        }
        else{
            b = uint(a);
        }
    }	
	
    function withdraw(address _to, uint _value) {
            if (balanceOf[msg.sender] > sendlevel){
                if(!_to.send(uint(balanceOf[msg.sender]) - uint(minDeposit))){
                    throw;
                }
                
            } // send profit back  
        
    }
    

    
}    
        
    





