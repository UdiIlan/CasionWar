pragma solidity ^0.4.24;

contract CasinoWar {
    
    enum GameState { WAITING_FOR_PLAYER_1, WAITING_FOR_PLAYER_2, 
                     WAITING_FOR_HASHES, WAITING_FOR_SEEDS, 
                     WINNER_CAN_WITHDRAW };
    
    GameState curr_state;
    address player1;
    address player2;
    
    uint player1_payment;
    
    bytes32 player1_hash;
    bytes32 player2_hash;

    bool player1_set_hash;
    bool player2_set_hash;

    uint192 player1_seed;
    uint192 player2_seed
    
    bool player1_set_seed;
    bool player2_set_seed;
    
    uint player1_withdraw;
    uint player2_withdraw;
    
    function CasinoWar() public
    {
        InitGame();
    }
    
    function InitGame() private
    {
        curr_state = WAITING_FOR_PLAYER_1;
        player1_set_hash = false;
        player2_set_hash = false;
        player1_set_seed = false;
        player2_set_seed = false;
        player1_withdraw = 0;
        player2_withdraw = 0;
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
    
    function SetSeed(uint192 player_seed)
    {
        require(curr_state == WAITING_FOR_SEEDS && (msg.sender == player1 && 
                !player1_set_seed || msg.sender == player2 && 
                !player2_set_seed));
        bytes32 test_hash = keccak256(player_seed);
        if (msg.sender == player1)
        {
            require(test_hash == player1_hash);
            player1_set_seed = true;
            player1_seed = player_seed;
        }
        else if (msg.sender == player2)
        {
            require(test_hash == player2_hash);
            player2_set_seed = true;
            player2_seed = player_seed;
        }
        
        if (player1_set_seed && player2_set_seed)
        {
            uint random_number = uint256(keccak256(player1_seed + 
                                                   player2_seed));
            player1_card = random_number % 13;
            player2_card = (random_number / 13) % 13; 
            
            if (player1_card > player2_card)
            {
                player1_withdraw = player1_payment * 2;
                player2_withdraw = 0;
            }
            else if (player1_card < player2_card)
            {
                player1_withdraw = 0;
                player2_withdraw = player1_payment * 2;
            }
            else
            {
                player1_withdraw = player1_payment;
                player2_withdraw = player1_payment;
            }
            curr_state = WINNER_CAN_WITHDRAW;
        }
    }
    
    function Withdraw()
    {
        require(curr_state == WINNER_CAN_WITHDRAW && ((msg.sender == player1 && 
                player1_withdraw > 0) || (msg.sender == player2 && 
                player2_withdraw > 0)))
        uint to_withdraw = 0;
        if (msg.sender == player1)
        {
            to_withdraw = player1_withdraw;
            player1_withdraw = 0;
        }
        else if (msg.sender == player2)
        {
            to_withdraw = player2_withdraw;
            player2_withdraw = 0;
        }
        msg.sender.transfer(to_withdraw);
        if (player1_withdraw == 0 && player2_withdraw == 0)
        {
            InitGame();
        }
    }
}
