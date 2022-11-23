module lottery::random {
    use sui::object::{Self, UID};
    use std::vector;
    use sui::transfer;

    fun pseudoRandomNumGenerator(uid: &UID, upper_limit: u8):u8{

        // create random ID
        let random = object::uid_to_bytes(uid);

        // add 3 random numbers based on UID of next tx ID.
        let rnd = ((*vector::borrow(&random, 0) as u8) % upper_limit);

        rnd
    }

    #[test]
    public fun test_sword_create() {
        use sui::tx_context;

        // create a dummy TxContext for testing
        let ctx = tx_context::dummy();

        // check if accessor functions return correct values
        // let val = pseudoRandomNumGenerator(&mut object::new(&mut ctx), 1);
        assert!(pseudoRandomNumGenerator(&mut object::new(&mut ctx), 1) == 1, 2);

        // create a dummy address and transfer the sword
        // let dummy_address = @0xCAFE;
        // transfer::transfer(val, dummy_address);

    }

}