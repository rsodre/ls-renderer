use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use adventurer::{adventurer::{Adventurer}, adventurer_meta::{AdventurerMetadata}, bag::{Bag}};

#[dojo::interface]
trait IMain {
    fn token_uri(
        ref world: IWorldDispatcher,
        adventurer_id: u256,
        adventurer: Adventurer,
        adventurer_name: felt252,
        adventurerMetadata: AdventurerMetadata,
        bag: Bag,
        item_specials_seed: u16,
        rank_at_death: u8,
        current_rank: u8,
    ) -> ByteArray;
}

#[dojo::contract]
mod main {
    use super::{IMain, WORLD};
    use starknet::{ContractAddress, get_caller_address};
    use adventurer::{adventurer::{Adventurer}, adventurer_meta::{AdventurerMetadata}, bag::{Bag}};
    use skuller::models::models::{Config};
    use skuller::renderers::v0;

    #[abi(embed_v0)]
    impl MainImpl of IMain<ContractState> {
        fn token_uri(
            ref world: IWorldDispatcher,
            adventurer_id: u256,
            adventurer: Adventurer,
            adventurer_name: felt252,
            adventurerMetadata: AdventurerMetadata,
            bag: Bag,
            item_specials_seed: u16,
            rank_at_death: u8,
            current_rank: u8,
        ) -> ByteArray {
            WORLD(world);
            v0::create_metadata(
                adventurer_id.try_into().unwrap(),
                adventurer,
                adventurer_name,
                adventurerMetadata,
                bag,
                item_specials_seed,
                rank_at_death,
                current_rank,
            )
        }
    }
}

// consumes an IWorldDispatcher to avoid unused variable warnings
#[inline(always)]
fn WORLD(_world: IWorldDispatcher) {}
