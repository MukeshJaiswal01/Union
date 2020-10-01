pragma solidity 0.6.0;

contract Union{
    address payable public Leader;
    address  _contract;
    address payable token ;
    address payable [] public participants;
    uint time;
    uint length = 0;
    struct  Details {
        
        bool benfitted;
        uint time;
    }
    
    mapping(address => Details) Member_detail;
    
    
    constructor (uint _time,  address payable _token, address payable [] memory _participants ) public {
        time = _time;
        _contract = address(this);
        Leader = msg.sender;
        token = _token;
        participants = _participants;
    }
    
    modifier onlyLeader(){
        
        require(msg.sender == Leader, "caller is not a Leader");
        _;
    }
    modifier onlyParticipants(){
        for(uint i = 0; i < participants.length; i++){
             
              if(msg.sender != participants[i] ){
                  revert("participants is not part of union");
              }
        }
        
        _;
    }
    
    fallback () payable external {
        
        for(uint i = 0; i < participants.length; i++){
            
            if(msg.sender == participants[i]){
                return;
            }
            
            else{
                
               participants[length - 1] = msg.sender;
                
            }
        }
        
        
       
    }
    
    function addParticipants(address payable _member)public onlyParticipants{
        participants[participants.length - 1] = _member;
        
    }
    
    
    function selection (address _address) private {
        
          if(Member_detail[_address].benfitted == true){
              
              revert("already benefitted");
          }
        
    }
    

    
      function  withdrawal() onlyLeader  public{
          require(time >=  100);
          
           address selected_member =  participants[length];
           selection(selected_member);
          
           (bool _success, bytes memory _data) = token.call(
                  abi.encodeWithSignature(
                    "approve(address,uint256)",
                      _contract,
                      3
                  )
              );
              
              require(_success);
              
              
          
          (bool success, bytes memory data) = token.call(
                  abi.encodeWithSignature(
                      "transferFrom(address,address,uint256)",
                      _contract,
                      participants[length],
                      3
                  )
              );
              
              Member_detail[selected_member].benfitted = true;
              Member_detail[selected_member].time = now;
              
              length++;
              
              if(length == (participants.length - 1)){
                  length = 0;
              }
             
          
          
      }



    
    
        
    
        
    
}
