use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use adventurer::{
    adventurer::{Adventurer, ImplAdventurer},
    adventurer_meta::{AdventurerMetadata, ImplAdventurerMetadata}, equipment::ImplEquipment,
    bag::Bag, item::{Item, ImplItem},
};

#[dojo::interface]
trait IMain {
    // called by Loot Survivor
    fn token_uri(
        world: @IWorldDispatcher,
        adventurer_id: u256,
        adventurer: Adventurer,
        adventurer_name: felt252,
        adventurerMetadata: AdventurerMetadata,
        bag: Bag,
        item_specials_seed: u16,
        rank_at_death: u8,
        current_rank: u8,
    ) -> ByteArray;

    //-----------------
    // simulators
    //

    // calls Loot Survivor contract to fetch adventurer data
    fn adventurer_token_uri(
        world: @IWorldDispatcher,
        adventurer_id: u256,
    ) -> ByteArray;

    // uses dummy random data for testing
    fn simulate_token_uri(
        world: @IWorldDispatcher,
        adventurer_id: u256,
    ) -> ByteArray;
}

#[dojo::contract]
mod main {
    use super::{IMain, WORLD};
    use starknet::{ContractAddress, get_caller_address};
    use skuller::models::models::{Config, Version};
    use skuller::renderers::{v0, v1};
    use skuller::ls::interfaces::{IGameDispatcher, IGameDispatcherTrait};

    use adventurer::{
        adventurer::{Adventurer, ImplAdventurer},
        adventurer_meta::{AdventurerMetadata, ImplAdventurerMetadata}, equipment::ImplEquipment,
        leaderboard::{Leaderboard},
        item::{Item, ImplItem},
        equipment::{Equipment},
        stats::{Stats},
        bag::{Bag},
    };

    fn dojo_init(
        ref world: IWorldDispatcher,
        loot_survivor_address: ContractAddress,
    ) {
        let config = Config {   
            key: 1,
            loot_survivor_address,
            version: Version::V1,
        };
        set!(world, (config));
    }

    #[abi(embed_v0)]
    impl MainImpl of IMain<ContractState> {
        fn token_uri(
            world: @IWorldDispatcher,
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
            self._token_uri(
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

        fn adventurer_token_uri(
            world: @IWorldDispatcher,
            adventurer_id: u256,
        ) -> ByteArray {
            let config = get!(world, (1), Config);
            let game = IGameDispatcher {
                contract_address: config.loot_survivor_address,
            };

            let id = adventurer_id.try_into().unwrap();
            let adventurer = game.get_adventurer(id);
            let adventurer_name = game.get_adventurer_name(id);
            let adventurer_metadata = game.get_adventurer_meta(id);
            let bag = game.get_bag(id);

            // let item_specials_seed = _get_item_specials_seed(id);
            let item_specials_seed = 1234;

            // let current_rank = _get_rank(id);
            let leaderboard: Leaderboard = game.get_leaderboard();
            let current_rank = 
                if (leaderboard.first.adventurer_id == id.try_into().unwrap()) {1}
                else if (leaderboard.second.adventurer_id == id.try_into().unwrap()) {2}
                else if (leaderboard.third.adventurer_id == id.try_into().unwrap()) {3}
                else {0};

            self._token_uri(
                adventurer_id,
                adventurer,
                adventurer_name,
                adventurerMetadata: adventurer_metadata,
                bag: bag,
                item_specials_seed: item_specials_seed,
                rank_at_death: adventurer_metadata.rank_at_death,
                current_rank: current_rank,
            )
        }
    
        fn simulate_token_uri(
            world: @IWorldDispatcher,
            adventurer_id: u256,
        ) -> ByteArray {
            WORLD(world);
            let adventurer = Adventurer {
                health: 600,
                // xp: 1, // level 1
                xp: 10000,
                stats: Stats {
                    strength: 0,
                    dexterity: 1,
                    intelligence: 2,
                    vitality: 4,
                    wisdom: 5,
                    charisma: 10,
                    luck: 100
                },
                gold: 333,
                equipment: Equipment {
                    weapon: Item { id: 42, xp: 400 },
                    chest: Item { id: 49, xp: 400 },
                    head: Item { id: 53, xp: 400 },
                    waist: Item { id: 59, xp: 400 },
                    foot: Item { id: 64, xp: 400 },
                    hand: Item { id: 69, xp: 400 },
                    neck: Item { id: 1, xp: 400 },
                    ring: Item { id: 7, xp: 400 }
                },
                beast_health: 3,
                stat_upgrades_available: 0,
                battle_action_count: 0,
                mutated: false,
                awaiting_item_specials: false
            };
            let bag = Bag {
                item_1: Item { id: 8, xp: 400 },
                item_2: Item { id: 40, xp: 400 },
                item_3: Item { id: 57, xp: 400 },
                item_4: Item { id: 83, xp: 400 },
                item_5: Item { id: 12, xp: 400 },
                item_6: Item { id: 77, xp: 400 },
                item_7: Item { id: 68, xp: 400 },
                item_8: Item { id: 100, xp: 400 },
                item_9: Item { id: 94, xp: 400 },
                item_10: Item { id: 54, xp: 400 },
                item_11: Item { id: 87, xp: 400 },
                item_12: Item { id: 81, xp: 400 },
                item_13: Item { id: 30, xp: 400 },
                item_14: Item { id: 11, xp: 400 },
                item_15: Item { id: 29, xp: 400 },
                mutated: false
            };
            let birth_date = 1421807737;
            let delay_stat_reveal = false;
            let adventurer_metadata = ImplAdventurerMetadata::new(birth_date, delay_stat_reveal, 0, 0);
            self._token_uri(
                adventurer_id.try_into().unwrap(),
                adventurer,
                adventurer_name: 'Blobert #1234',
                adventurerMetadata: adventurer_metadata,
                bag: bag,
                item_specials_seed: 492,
                rank_at_death: 1,
                current_rank: 1,
                // current_rank: 0,
            )
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _token_uri(
            self: @ContractState,
            adventurer_id: u256,
            adventurer: Adventurer,
            adventurer_name: felt252,
            adventurerMetadata: AdventurerMetadata,
            bag: Bag,
            item_specials_seed: u16,
            rank_at_death: u8,
            current_rank: u8,
        ) -> ByteArray {
            v1::create_metadata(
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
