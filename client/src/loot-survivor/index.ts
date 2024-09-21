
// from: /loot-survivor/ui/src/app/hooks/useUIStore.ts
export type Network =
  | "mainnet"
  | "katana"
  | "sepolia"
  | "localKatana"
  | undefined;






// let renderer_address = _get_adventurer_renderer(self, adventurer_id);
// let adventurer = _load_adventurer(self, adventurer_id);
// let adventurer_name = _load_adventurer_name(self, adventurer_id);
// let adventurer_metadata = _load_adventurer_metadata(self, adventurer_id);
// let bag = _load_bag(self, adventurer_id);
// let item_specials_seed = _get_item_specials_seed(self, adventurer_id);
// let current_rank = _get_rank(self, adventurer_id);
//
//  IRenderContractDispatcher { contract_address: renderer_address }.token_uri(
//   token_id,
//   adventurer,
//   adventurer_name,
//   adventurer_metadata,
//   bag,
//   item_specials_seed,
//   adventurer_metadata.rank_at_death,
//   current_rank,
// )

// fn token_uri(
//   ref world: IWorldDispatcher,
//   adventurer_id: u256,
//   adventurer: Adventurer,
//   adventurer_name: felt252,
//   adventurerMetadata: AdventurerMetadata,
//   bag: Bag,
//   item_specials_seed: u16,
//   rank_at_death: u8,
//   current_rank: u8,
// ) -> ByteArray;


type cairo_Adventurer = {
  health: number
  xp: number
  gold: number
  beast_health: number
  stat_upgrades_available: number
  stats: cairo_Stats
  equipment: cairo_Equipment
  battle_action_count: number
  mutated: boolean
  awaiting_item_specials: boolean
}

type cairo_Stats = {
  strength: number
  dexterity: number
  vitality: number
  intelligence: number
  wisdom: number
  charisma: number
  luck: number
}

type cairo_Equipment = { // 128 bits
  weapon: cairo_Item
  chest: cairo_Item
  head: cairo_Item
  waist: cairo_Item
  foot: cairo_Item
  hand: cairo_Item
  neck: cairo_Item
  ring: cairo_Item
}

type cairo_Item = {
  id: number
  xp: number
}

type cairo_AdventurerMetadata = {
  birth_date: bigint
  death_date: bigint
  level_seed: bigint
  item_specials_seed: bigint
  rank_at_death: number
  delay_stat_reveal: boolean
  golden_token_id: number
  launch_tournament_winner_token_id: bigint
}

type cairo_Bag = {
  item_1: cairo_Item,
  item_2: cairo_Item,
  item_3: cairo_Item,
  item_4: cairo_Item,
  item_5: cairo_Item,
  item_6: cairo_Item,
  item_7: cairo_Item,
  item_8: cairo_Item,
  item_9: cairo_Item,
  item_10: cairo_Item,
  item_11: cairo_Item,
  item_12: cairo_Item,
  item_13: cairo_Item,
  item_14: cairo_Item,
  item_15: cairo_Item,
  mutated: boolean,
}

export type token_uri_params = {
  token_id: bigint
  adventurer: cairo_Adventurer
  adventurer_name: string
  adventurer_metadata: cairo_AdventurerMetadata
  bag: cairo_Bag
  item_specials_seed: bigint
  adventurer_metadata_rank_at_death: bigint
  current_rank: bigint
}

