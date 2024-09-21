use starknet::ContractAddress;

#[derive(Serde, Copy, Drop, Introspect)]
pub enum Version {
    V0,
    V1,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Config {
    #[key]
    pub key: u8,
    pub version: Version,
}
