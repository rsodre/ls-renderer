#[cfg(test)]
mod tests {
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    // import test utils
    use dojo::utils::test::{spawn_test_world, deploy_contract};
    // import test utils
    use lsrender::{
        systems::main::{main, IMainDispatcher, IMainDispatcherTrait},
        models::models::{Config}
    };

    #[test]
    fn test_move() {
        // deploy world with models
        let world = spawn_test_world(["lsrender"].span(), get_models_test_class_hashes!());

        // deploy systems contract
        let contract_address = world
            .deploy_contract('salt', main::TEST_CLASS_HASH.try_into().unwrap());
        let main_system = IMainDispatcher { contract_address };

        world.grant_writer(dojo::utils::bytearray_hash(@"lsrender"), contract_address);

        // call render()
        main_system.render();
    }
}
