pragma solidity ^0.4.24;

contract CasinoWar {
    
    enum GameState { WAITING_FOR_PLAYER_1, WAITING_FOR_PLAYER_2, WAITING_FOR_HASHES,
                     WAITING_FOR_SEEDS, WINNER_CAN_WITHDRAW )
    
    GameState curr_state;
    address player1;
    address player2;
    
    
    function CasinoWar() public
    {
        curr_state = WAITING_FOR_PLAYER_1;
    }
}
