use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[dojo::interface]
trait IMain {
    fn render(ref world: IWorldDispatcher);
}

#[dojo::contract]
mod main {
    use super::{IMain, WORLD};
    use starknet::{ContractAddress, get_caller_address};
    use lsrender::models::models::{Config};

    #[abi(embed_v0)]
    impl MainImpl of IMain<ContractState> {
        fn render(ref world: IWorldDispatcher) {
            WORLD(world);
        }
    }
}

// consumes an IWorldDispatcher to avoid unused variable warnings
#[inline(always)]
fn WORLD(_world: IWorldDispatcher) {}
