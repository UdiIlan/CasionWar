pragma solidity ^0.4.24;

contract CasinoWar {
    
    enum GameState { WAITING_FOR_PLAYER_1, WAITING_FOR_PLAYER_2, WAITING_FOR_HASHES,
                     WAITING_FOR_SEEDS, WINNER_CAN_WITHDRAW )
    
    GameState curr_state;
    address player1;
    address player2;
    
    uint player1_payment;
    
    bytes32 player1_hash;
    bytes32 player2_hash;

    bool player1_set_hash;
    bool player2_set_hash;
    
    function CasinoWar() public
    {
        curr_state = WAITING_FOR_PLAYER_1;
        player1_set_hash = false;
        player2_set_hash = false;
    }
    
    function StartGame() public payable
    {
        require(curr_state == WAITING_FOR_PLAYER_1);
        require(msg.value > 0);
        player1 = msg.sender;
        player1_payment = msg.value;
        curr_state = WAITING_FOR_PLAYER_2;
    }
    
    function JoinGame() public payable
    {
        require(curr_state == WAITING_FOR_PLAYER_2);
        require(msg.value == player1_payment);
        require(player1 != msg.sender)
        player2 = msg.sender;
        curr_state = WAITING_FOR_HASHES;
    }
    
    function SetHash(bytes32 player_hash)
    {
        require(curr_state == WAITING_FOR_HASHES && (msg.sender == player1 && 
                !player1_set_hash || msg.sender == player2 && 
                !player2_set_hash));
        if (msg.sender == player1)
        {
            player1_set_hash = true;
            player1_hash = player_hash;
        }
        else if (msg.sender == player2)
        {
            player2_set_hash = true;
            player2_hash = player_hash;
        }
        
        if (player1_set_hash && player2_set_hash)
        {
            curr_state = WAITING_FOR_SEEDS;
        }
    }
}
