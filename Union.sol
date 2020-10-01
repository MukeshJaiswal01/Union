pragma solidity 0.6.0;

contract Union{
    address payable public Leader;  // person who will be leader of the community
                        
    address  _contract;            // address of the deployed contract
    
    address payable token ;       // address of the token that has to be distributed 
    
    address payable [] public participants;  // array of  community members 
    
    uint time;                               // Time alloted for the deposit into the pot
    uint length = 0;
    
    struct  Details {           
                                  // it will keep the Details of member whether they have 
                                  // been benefitted or not 
                                  // it also record the time of transaction
        
        bool benfitted;
        uint time;
    }
    
    mapping(address => Details) Member_detail;
                        
                         // map the addres of community member to the Details so that 
                         // we can keep up with Details of particular member
    
    
    constructor (uint _time,  address payable _token, address payable [] memory _participants ) public {
        time = _time;
        _contract = address(this);
        Leader = msg.sender;
        token = _token;
        participants = _participants;
    }
    
    modifier onlyLeader(){
        
                            // only leader  can call particular function like withdrawal()
        
        require(msg.sender == Leader, "caller is not a Leader");
        _;
    }
    
    
    modifier onlyParticipants(){
        
        
                              // only participants are allowed to do specific task 
                              // like adding the participants
                              
                              
        for(uint i = 0; i < participants.length; i++){
             
              if(msg.sender != participants[i] ){
                  revert("participants is not part of union");
              }
        }
        
        _;
    }
    
    fallback () payable external {
        
        
               // if sender is not in participants list it will be added in list as a member
               // of the community
               
        
        for(uint i = 0; i < participants.length; i++){
            
            if(msg.sender == participants[i]){
                return;
            }
            
            else{
                
                participants.push(msg.sender);
                
            }
        }
        
        
       
    }
    
    function addParticipants(address payable _member)public onlyParticipants{
        
                                 // only Participants  can add the other Member
                                
                                 
        participants.push( _member);
        
    }
    
    function changeLeader(address payable _NewLeader)public onlyParticipants{
        
                                 // Member can change the Leader if something happen
                                 // to current leader
        
         Leader = _NewLeader;
    }
    
    
    function selection (address _address) view private {
        
                        // checking wether the given address already benfitted or not
        
          if(Member_detail[_address].benfitted == true){
              
              revert("already benefitted");
          }
        
    }
    

    
      function  withdrawal() onlyLeader  public{
          
                     // only leader can can can call this function
          
          
          require(time >=  100);
                              
                              // community member can choose  their  time span like 30 days, here i
                              // have taken 100s 
          
           address selected_member =  participants[length];
           selection(selected_member);
           
                           // first we need to get approval before transfer of token
          
           (bool _success, bytes memory _data) = token.call(
                  abi.encodeWithSignature(
                    "approve(address,uint256)",
                      _contract,
                      3
                  )
              );
              
              require(_success);
              
              
                           // after approval is done we have transfer the token from this
                           // contract to its participants
          
          (bool success, bytes memory data) = token.call(
                  abi.encodeWithSignature(
                      "transferFrom(address,address,uint256)",
                      _contract,
                      participants[length],
                      3
                  )
              );
              
                           // updating the Member_detail who got benfitted
                           
              Member_detail[selected_member].benfitted = true;
              Member_detail[selected_member].time = now;
              
              length++;
              
              
                           // if all the Member got benfitted we can reiterate the whole process
                           // by updating  their Details
                           
              if(length == (participants.length - 1)){
                  
                   length = 0;
                   
                   for(uint i = 0; i < participants.length; i++){
                       
                        Member_detail[participants[i]].benfitted = false;
                        Member_detail[participants[i]].time = 0;
                   }
              }
             
          
          
      }



    
    
        
    
        
    
}
