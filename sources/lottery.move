module lottery::lottery {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID, ID};
    use std::string::{Self, String};
    use sui::url::{Self, Url};
    use sui::transfer;
    use sui::math;
    use sui::event::emit;
    use sui::dynamic_object_field as dof;
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};

    use std::option::{Self, Option};
    use std::vector as vec;
    use std::hash::sha3_256 as hash;

    use std::vector;

    const TicketPrice: u64 = 1;
    const MinimumPlayers: u64 = 3;

    // User does not have enough coins to play
    const ENotEnoughMoney: u64 = 1;

    // user did not provide the correct amount of ticket price
    const EIncorrectTicketPrice: u64 = 2;

    // we don't have the minimum amount of players
    const ENotEnoughPlayers: u64 = 3;

    // not lottery owner
    const ENotLotterryOwner: u64 = 4;

    // The Lottery object
    struct Lottery has key, store {
        id: UID,
        cost_per_game: u64,
        minimun_players: u64,
        player_wallet_references: vector<Coin<SUI>>,
        lottery_balance: Balance<SUI>,
    }

    // The ownership capability of the Lottery
    struct LotteryOwnerCap has key, store {
        id: UID
    }

    // struct PlayEvent has copy, drop {
    //     id: ID,
    //     winnings: u64,
    //     player: address,
    // }

    // struct Players has key{
    //     id: UID,
    //     player_id: ID
    // }

    // struct WinnerEvent has copy, drop{
    //     id: ID,
    //     amount: u64,
    //     winner: address
    // }

    /// Initialize the lottery 
    fun init(ctx: &mut TxContext){

        // Assign ownership to the lottery creator
        transfer::transfer(
            LotteryOwnerCap{id: object::new(ctx)}, 
            tx_context::sender(ctx)
        );

        // Initialize a Lottery object
        let lottery = Lottery {
            id: object::new(ctx),
            cost_per_game: TicketPrice,
            minimun_players: MinimumPlayers,
            player_wallet_references: vector::empty(),
            lottery_balance: balance::zero()
        };
        // Make Lottery's object shared
        transfer::share_object(lottery);
    }

    // returns the cose per game
    public fun cost_per_game(self: &Lottery): u64 {
        self.cost_per_game
    }

    // returns lottery's balance
    public fun lottery_balance(self:  &Lottery): u64{
       balance::value<SUI>(&self.lottery_balance)
    }

    // let's play a game
    public entry fun play(lottery: &mut Lottery, wallet: &mut Coin<SUI>, ctx: &mut TxContext){

        // make sure we have enough money to play a game!
        // FIXME NOT SURE IF NEEDED.
        assert!(coin::value(wallet) >= lottery.cost_per_game, ENotEnoughMoney);

        // get balance reference
        let wallet_balance = coin::balance_mut(wallet);

        // get money from balance
        let payment = balance::split(wallet_balance, lottery.cost_per_game);

        // add to lottery's balance.
        balance::join(&mut lottery.lottery_balance, payment);

        vector::push_back(&mut lottery.player_wallet_references, wallet);

        // Probably ends here.
    }

    /*
       A function for admins to get their profits.
    */
    public entry fun pick_winner(_: &LotteryOwnerCap, lottery: &mut Lottery, wallet: &mut Coin<SUI>){

        //Check that we have 3 players at least

        let availableCoins = lottery_balance(lottery);

        let balance = coin::balance_mut(wallet);

        // split money from casino's balance.
        let payment = balance::split(&mut casino.casino_balance, amount);

        balance::join(coin::balance_mut(wallet), payment); // add to user's wallet!

            winnings = casino.cost_per_game * (MaxWinningsMultiplier+1); // calculate winnings + the money the user spent.
            let payment = balance::split(&mut casino.casino_balance, winnings); // get from casino's balance.
            balance::join(coin::balance_mut(wallet), payment); // add to user's wallet!

    }

    /*
        *** This is not production ready code. Please use with care ***
       Pseudo-random generator. requires VRF in the future to verify randomness! Now it just relies on
       transaction ids.
    */

    fun pseudoRandomNumGenerator(uid: &UID):vector<u8>{

        // create random ID
        let random = object::uid_to_bytes(uid);
        let vec = vector::empty<u8>();

        // add 3 random numbers based on UID of next tx ID.
        vector::push_back(&mut vec, (*vector::borrow(&random, 0) as u8) % AmountOfCombinations);
        vector::push_back(&mut vec, (*vector::borrow(&random, 1) as u8) % AmountOfCombinations);
        vector::push_back(&mut vec, (*vector::borrow(&random, 2) as u8) % AmountOfCombinations);

        vec
    }

       // returns Lotterys ticket price
    public fun getTicketPrice(self: &Lottery): u64{
       self.ticket_price
    }

    public fun getMinimumPlayers(self: &Lottery): u64{
        self.minimun_players
    }

    // Entry function for users to register to the Lottery 
    public entry fun playLottery(lottery: &mut Lottery, player_wallet: &mut Coin<SUI>, _ctx: &mut TxContext){

        // Checks if players has the minimum amount to pay 
        assert!(coin::value(player_wallet) >= lottery.ticket_price, ENotEnoughMoneyToPlay);

         // Get players wallet balance
        let wallet_balance = coin::balance_mut(player_wallet);

        // if user has submitted the correct price to purchase ticket
       // assert!(coin::value(wallet)==lottery.getTicketPrice, EIncorrectTicketPrice);
        
        let ticket_payment = balance::split(wallet_balance, lottery.ticket_price);

        // add ticket_payment amount to lottery's balance
        balance::join(&mut lottery.lottery_balance,ticket_payment);

        // Create a new player Struct
       // let id = object::new(ctx);
       // let player_id = object::uid_to_inner(&id);

      //  let player = Player{id, player_id};

        // Increment total players count
        let total_players = lottery.registered_players;
        lottery.registered_players = total_players + 1;

    }

    public entry fun pickWinner(_: &LotteryOwnerCap, lottery: &mut Lottery, wallet: &mut Coin<SUI>){

        assert!(lottery.registered_players >=3, ENotEnoughPlayers);

         let lot_balance = getBalance(lottery);

         let user_balance = coin::balance_mut(wallet);

         let profits = balance::split(&mut lottery.lottery_balance, lot_balance);

         balance::join(user_balance, profits);
    }



}