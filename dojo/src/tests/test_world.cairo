#[cfg(test)]
mod tests {
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    // import test utils
    use dojo::utils::test::{spawn_test_world, deploy_contract};
    // import test utils
    use skuller::{
        systems::main::{main, IMainDispatcher, IMainDispatcherTrait},
        models::models::{Config}
    };

    const SELECTOR_MAIN: felt252 = selector_from_tag!("skuller-main");

    #[test]
    fn test_move() {
        // deploy world with models
        let world = spawn_test_world(["skuller"].span(), get_models_test_class_hashes!());

        // deploy systems contract
        let contract_address = world.deploy_contract('salt', main::TEST_CLASS_HASH.try_into().unwrap());
        let main_system = IMainDispatcher { contract_address };

        world.grant_writer(dojo::utils::bytearray_hash(@"skuller"), contract_address);
        world.init_contract(SELECTOR_MAIN, [0x1234].span());

        // check config
        let config: Config = get!(world, (1), Config);
        assert(config.loot_survivor_address == starknet::contract_address_const::<0x1234>(), 'loot_survivor_address');

        let uri: ByteArray = main_system.simulate_token_uri(1);
        assert(uri.len() > 100, 'uri');
    }
}
