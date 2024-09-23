// 2024-09-17, from:
// https://github.com/Provable-Games/loot-survivor/blob/598ab8b7184bac6c7d486e884e879606909d4e33/contracts/game/src/game/renderer.cairo

use core::{array::{SpanTrait, ArrayTrait}, traits::Into, clone::Clone,};
use adventurer::{
    adventurer::{Adventurer, ImplAdventurer},
    adventurer_meta::{AdventurerMetadata, ImplAdventurerMetadata}, equipment::ImplEquipment,
    bag::Bag, item::{Item, ImplItem},
};
use loot::{loot::ImplLoot, constants::{ImplItemNaming, ItemSuffix}};
use skuller::utils::encoding::{bytes_base64_encode, U256BytesUsedTraitImpl};
use skuller::renderers::{v0};
use graffiti::json::JsonImpl;

//--------------------------------
// reference
//
// green:  #3DEC00
// gold:   #D3AF37 > #ffb000
// silver: #AAA9AD
// bronze: #A97142
// white:  #DDDDDD
//
//--------------------------------

#[inline(always)]
fn green() -> ByteArray {"#3DEC00"}
#[inline(always)]
fn bronze() -> ByteArray {"#A97142"}
#[inline(always)]
fn silver() -> ByteArray {"#AAA9AD"}
#[inline(always)]
fn gold() -> ByteArray {"#ffb000"}
#[inline(always)]
fn dead_gray() -> ByteArray {"#475569"}
#[inline(always)]
fn black() -> ByteArray {"#000"}
#[inline(always)]
fn white() -> ByteArray {"#ddd"}

// @notice Generates a rect element
// @return The generated rect element
fn create_border(rank_at_death: u8, current_rank: u8, level: u8) -> ByteArray {
    "<rect x='0.5' y='0.5' width='599' height='899' rx='25' fill='black' stroke='" + rank_color(rank_at_death, current_rank, level) + "'/>"
}

fn create_item_element(x: ByteArray, y: ByteArray, item: ByteArray) -> ByteArray {
    "<g transform='translate(" + x + "," + y + ") scale(1.5)' style='fill:" + gold() + ";'>" + item + "</g>"
}

fn rank_color(rank_at_death: u8, current_rank: u8, level: u8) -> ByteArray {
    let rank = if (current_rank > rank_at_death) {current_rank} else {rank_at_death};
    if (level == 1) {
        dead_gray()
    } else if (rank == 0) {
        green()
    } else if (rank == 1) {
        gold()
    } else if (rank == 2) {
        silver()
    } else {
        bronze()
    }
}

fn generate_logo(rank_at_death: u8, current_rank: u8, level: u8) -> ByteArray {
    if (current_rank > 0) { // current top ranking are always green (+crown)
        "<g transform='scale(4)'>" + v0::logo() + "</g>"
    } else {
        "<g transform='scale(4)' style='fill:" + rank_color(rank_at_death, 0, level) + ";'>" + v0::logo() + "</g>"
    }
}

fn generate_crown(rank_at_death: u8, current_rank: u8, level: u8) -> ByteArray {
    if (level == 1 || current_rank == 0) {
        ""
    } else {
        "<g transform='translate(0,-10) scale(2.68)' style='fill:" + rank_color(rank_at_death, current_rank, level) + ";'>" + v0::crown() + "</g>"
    }
}

fn create_skull(rank_at_death: u8, current_rank: u8, level: u8) -> ByteArray {
    (
        "<g transform='translate(120,80) scale(4)'>" +
        generate_logo(rank_at_death, current_rank, level) +
        generate_crown(rank_at_death, current_rank, level) +
        "</g>"
    )
}


//--------------------------------
// SKULLER
//

#[inline(always)]
fn health() -> ByteArray {
    "<path transform='translate(-5,-2) scale(1.3)' fill-rule='evenodd' d='M14.5 2.157v-1h-1v-1h-3v1h-1v1h-1v1h-1v-1h-1v-1h-1v-1h-3v1h-1v1h-1v4h1v2h1v1h1v1h1v1h1v1h1v1h1v1h1v-1h1v-1h1v-1h1v-1h1v-1h1v-1h1v-2h1v-4h-1Z' clip-rule='evenodd'/>"
}

#[inline(always)]
fn coin() -> ByteArray {
    "<path transform='translate(-6,-2) scale(0.035)' d='m586.96 215.35v-64.566h-21.609v-21.559h-21.504v-43.062h-21.566v-21.504h-43.07v-21.559h-64.566v-21.504h-129.31v21.504h-64.566v21.559h-43.062v21.504h-21.559v43.062h-21.504v21.559h-21.559v64.566h-21.504v129.31h21.504v64.574h21.559v21.559h21.504v43.062h21.559v21.508h43.062v21.559h64.566v21.508h129.31v-21.508h64.566v-21.559h43.07v-21.508h21.566v-43.062h21.504v-21.559h21.609v-64.574h21.449v-129.31zm0 43.062v64.68'/>"
    // "<circle cx='8' cy='8' r='8'/>"
}

#[inline(always)]
fn trophy() -> ByteArray {
    "<path transform='translate(-2,-2) scale(1)' d='M3 3V2h2V0h7v2h2v1h-1v2h-1v2h-2v1H7V7H5V5H4V3zm4 0v1h1v2h2V1H9v1H8v1zM3 2H1v2h1v1h1v1h1v1h1v2h1v2H5v1H3v-1h2V9H4V8H3V7H2V6H1V5H0V2h1V1h2zm11 10h-2v-1h2zm-2-1h-1V9h1zm1-3v1h-1V7h1V6h1V5h1V4h1V2h1v3h-1v1h-1v1h-1v1zm3-7v1h-2V1zm-5 10v2H6v-2h1V9h3v2zm1 3v2H5v-2z'/>"
}

#[inline(always)]
fn space() -> ByteArray {
    "&#160;"
}

fn format_rank(rank: u8) -> ByteArray {
    let r: u8 = (rank % 10);
    if (r == 0) {
        ""
    } else if (r == 1) {
        format!("{}st", rank)
    } else if (r == 2) {
        format!("{}nd", rank)
    } else if (r == 3) {
        format!("{}rd", rank)
    } else {
        format!("{}th", rank)
    }
}

fn create_rect(x: ByteArray, y: ByteArray, w: ByteArray, h: ByteArray, fill: ByteArray) -> ByteArray {
    format!("<rect x='{}' y='{}' width='{}' height='{}' fill='{}'/>", x, y, w, h, fill)
}

fn create_stats(
    index: u16,
    name: ByteArray,
    number: ByteArray,
    value: u8,
    level: u8,
) -> ByteArray {
    let w: u16 = if (index < 6) {85} else {88};
    let h: u16 = 150;
    let x: u16 = 1 + index * 85;
    let y: u16 = 900 - 50 - h;
    let fill: ByteArray =
        if (level == 1 || value == 0) {"#7b1e1c"} // red
        else if (value <= 2) {"#805801"} // dark orange
        else if (value <= 4) {"#247b15"} // dark green
        else if (value < 10) {green()}
        else if (value < 100) {gold()}
        else {gold()};
    let text_color: ByteArray =
        if (level == 1 || value <= 4) {green()}
        else {black()};
    (
        format!("<rect x='{}' y='{}' width='{}' height='{}' fill='{}' shape-rendering='crispEdges'/>", x, y, w, h, fill)
        + create_text_color(name, (x + w / 2), (y + h / 3), 30, text_color.clone(), "middle", "")
        + create_text_color(number, (x + w / 2), (y + (h / 3) * 2), 35, text_color.clone(), "middle", "")
    )
}

fn create_item(
    index: u16,
    name: ByteArray,
    item: ByteArray,
) -> ByteArray {
    let y: u16 = 450 + index * 30;
    (
        create_item_element("25", format!("{}", y), item) +
        v0::create_text(name, "60", format!("{}", y + 16), "16", "middle", "start")
    )
}

fn create_xp(
    index: u16,
    name: ByteArray,
    value: ByteArray,
) -> ByteArray {
    let y: u16 = 150 + index * 38;
    (
        v0::create_text(value + " <tspan style='fill:" + gold() + "'>" + name + "</tspan>", "570", format!("{}", y + 16), "30", "right", "end")
    )
}

fn create_xp_item(
    index: u16,
    item: ByteArray,
    value: ByteArray,
) -> ByteArray {
    let y: u16 = 150 + index * 38;
    (
        create_item_element("550", format!("{}", y), item) +
        create_xp(index, space(), value)
    )
}

fn create_text_color(
    text: ByteArray,
    x: u16,
    y: u16,
    fontsize: u16,
    color: ByteArray,
    text_anchor: ByteArray, // start, middle, end
    add: ByteArray,
) -> ByteArray {
    format!("<text x='{}' y='{}' font-size='{}' style='fill:{}' text-anchor='{}' dominant-baseline='middle' {}>{}</text>",
        x, y, fontsize, color, text_anchor, add, text)
}


// @notice Generates adventurer metadata for the adventurer token uri
// @param adventurer_id The adventurer's ID
// @param adventurer The adventurer
// @param adventurer_name The adventurer's name
// @param adventurerMetadata The adventurer's metadata
// @param bag The adventurer's bag
// @param item_specials_seed The seed used to generate item specials
// @return The generated adventurer metadata
fn create_metadata(
    adventurer_id: felt252,
    adventurer: Adventurer,
    adventurer_name: felt252,
    adventurerMetadata: AdventurerMetadata,
    bag: Bag,
    item_specials_seed: u16,
    rank_at_death: u8,
    current_rank: u8,
) -> ByteArray {
    let level: u8 = adventurer.get_level();

    let rect = create_border(rank_at_death, current_rank, level);

    let mut _name = Default::default();
    _name.append_word(adventurer_name, U256BytesUsedTraitImpl::bytes_used(adventurer_name.into()).into());

    let _adventurer_id = format!("{}", adventurer_id);
    let _xp = format!("{}", adventurer.xp);
    let _level = format!("{}", adventurer.get_level());

    let _health = format!("{}", adventurer.health);

    let _max_health = format!("{}", adventurer.stats.get_max_health());

    let _rank_at_death = format!("{}", rank_at_death);
    let _current_rank = format!("{}", current_rank);

    let _gold = format!("{}", adventurer.gold);
    let _str = if level == 1 {"?"} else {
        format!("{}", adventurer.stats.strength)
    };
    let _dex = if level == 1 {"?"} else {
        format!("{}", adventurer.stats.dexterity)
    };
    let _int = if level == 1 {"?"} else {
        format!("{}", adventurer.stats.intelligence)
    };
    let _vit = if level == 1 {"?"} else {
        format!("{}", adventurer.stats.vitality)
    };
    let _wis = if level == 1 {"?"} else {
        format!("{}", adventurer.stats.wisdom)
    };
    let _cha = if level == 1 {"?"} else {
        format!("{}", adventurer.stats.charisma)
    };
    let _luck = if level == 1 {"?"} else {
        format!("{}", adventurer.stats.luck)
    };

    let _timestamp = starknet::get_block_info().unbox().block_timestamp;
    let _game_expiry_days: u8 = 10;
    let _seconds_in_day: u32 = 86400;
    let _game_expiry_seconds = adventurerMetadata.birth_date
        + (_game_expiry_days.into() * _seconds_in_day.into());
    let _seconds_left = if _timestamp > _game_expiry_seconds {
        0
    } else {
        _game_expiry_seconds - _timestamp
    };
    let _hours_left = format!("{}", _seconds_left / 3600);

    // Equipped items
    let _equiped_weapon = v0::generate_item(adventurer.equipment.weapon, false, item_specials_seed);
    let _equiped_chest = v0::generate_item(adventurer.equipment.chest, false, item_specials_seed);
    let _equiped_head = v0::generate_item(adventurer.equipment.head, false, item_specials_seed);
    let _equiped_waist = v0::generate_item(adventurer.equipment.waist, false, item_specials_seed);
    let _equiped_foot = v0::generate_item(adventurer.equipment.foot, false, item_specials_seed);
    let _equiped_hand = v0::generate_item(adventurer.equipment.hand, false, item_specials_seed);
    let _equiped_neck = v0::generate_item(adventurer.equipment.neck, false, item_specials_seed);
    let _equiped_ring = v0::generate_item(adventurer.equipment.ring, false, item_specials_seed);

    // Combine all elements
    let mut elements = array![
        rect,
        create_skull(rank_at_death, current_rank, level),

        if (current_rank == 0) {
            create_text_color("#" + _adventurer_id.clone(), 570, 105, 40, white(), "end", "")
        } else {
            create_text_color("#" + _adventurer_id.clone(), 570, 60, 40, white(), "end", "") +
            create_text_color(format_rank(current_rank), 570, 105, 40, white(), "end", "")
        },

        create_xp(0, "XP", _xp.clone()),
        create_xp(1, "LVL", _level.clone()),
        create_xp_item(2, health(), _health.clone() + "/" + _max_health.clone()),
        create_xp_item(3, coin(), _gold.clone()),
        if (rank_at_death > 0) {
            create_xp_item(4, trophy(), format_rank(rank_at_death))
        } else {""},

        create_text_color(_name.clone(), 300, 410, 40, white(), "middle", "textLength='540'"),

        create_stats(0, "STR", _str.clone(), adventurer.stats.strength, level),
        create_stats(1, "DEX", _dex.clone(), adventurer.stats.dexterity, level),
        create_stats(2, "INT", _int.clone(), adventurer.stats.intelligence, level),
        create_stats(3, "VIT", _vit.clone(), adventurer.stats.vitality, level),
        create_stats(4, "WIS", _wis.clone(), adventurer.stats.wisdom, level),
        create_stats(5, "CHA", _cha.clone(), adventurer.stats.charisma, level),
        create_stats(6, "LUCK", _luck.clone(), adventurer.stats.luck, level),
        
        // v0::create_text("LOOT SURVIVOR", 300, 872, 50, "middle", "middle"),
        // create_text_color("Adventurer #" + _adventurer_id.clone(), 300, 875, 30, green(), ""),
        create_text_color("LOOT SURVIVOR", 300, 875, 40, green(), "middle", "textLength='540'"),

        // equipped items
        create_item(0, _equiped_weapon.clone(), v0::weapon()),
        create_item(1, _equiped_chest.clone(), v0::chest()),
        create_item(2, _equiped_head.clone(), v0::head()),
        create_item(3, _equiped_waist.clone(), v0::waist()),
        create_item(4, _equiped_foot.clone(), v0::foot()),
        create_item(5, _equiped_hand.clone(), v0::hand()),
        create_item(6, _equiped_neck.clone(), v0::neck()),
        create_item(7, _equiped_ring.clone(), v0::ring()),
    ].span();

    let image = v0::create_svg(v0::combine_elements(ref elements));

    let base64_image = format!("data:image/svg+xml;base64,{}", bytes_base64_encode(image));

    let mut metadata = JsonImpl::new()
        .add("name", "Adventurer" + " #" + _adventurer_id)
        .add(
            "description",
            "An NFT representing ownership of a game of Loot Survivor. This NFT also serves as a fully onchain viewer for Adventurer stats. Please be mindful that games of Loot Survivor expire after 10 days and the NFT renderer can be permissionlessly updated by the token owner to change the displayed image. The purpose of this feature is to allow the community to permissionlessly improve the NFT but this feature can be abused by a malicious actor to misrepresent the state of the Adventurer. The contract includes a uses_custom_renderer(adventurer_id) function that can be used to determine if the adventurer is using a custom renderer. When purchasing one of these NFTs, consider using this function to ensure the displayed stats are consistent with the game contract."
        )
        .add("image", base64_image);

    let name: ByteArray = JsonImpl::new().add("trait", "Name").add("value", _name).build();
    let xp: ByteArray = JsonImpl::new().add("trait", "XP").add("value", _xp).build();
    let level: ByteArray = JsonImpl::new().add("trait", "Level").add("value", _level).build();
    let health: ByteArray = JsonImpl::new().add("trait", "Health").add("value", _health).build();
    let gold: ByteArray = JsonImpl::new().add("trait", "Gold").add("value", _gold).build();
    let str: ByteArray = JsonImpl::new().add("trait", "Strength").add("value", _str).build();
    let dex: ByteArray = JsonImpl::new().add("trait", "Dexterity").add("value", _dex).build();
    let int: ByteArray = JsonImpl::new().add("trait", "Intelligence").add("value", _int).build();
    let vit: ByteArray = JsonImpl::new().add("trait", "Vitality").add("value", _vit).build();
    let wis: ByteArray = JsonImpl::new().add("trait", "Wisdom").add("value", _wis).build();
    let cha: ByteArray = JsonImpl::new().add("trait", "Charisma").add("value", _cha).build();
    let luck: ByteArray = JsonImpl::new().add("trait", "Luck").add("value", _luck).build();
    let hours_left: ByteArray = JsonImpl::new()
        .add("trait", "Hours Left")
        .add("value", _hours_left)
        .build();
    let equipped_weapon: ByteArray = JsonImpl::new()
        .add("trait", "Weapon")
        .add("value", _equiped_weapon)
        .build();
    let equipped_chest: ByteArray = JsonImpl::new()
        .add("trait", "Chest Armor")
        .add("value", _equiped_chest)
        .build();
    let equipped_head: ByteArray = JsonImpl::new()
        .add("trait", "Head Armor")
        .add("value", _equiped_head)
        .build();
    let equipped_waist: ByteArray = JsonImpl::new()
        .add("trait", "Waist Armor")
        .add("value", _equiped_waist)
        .build();
    let equipped_foot: ByteArray = JsonImpl::new()
        .add("trait", "Foot Armor")
        .add("value", _equiped_foot)
        .build();
    let equipped_hand: ByteArray = JsonImpl::new()
        .add("trait", "Hand Armor")
        .add("value", _equiped_hand)
        .build();
    let equipped_neck: ByteArray = JsonImpl::new()
        .add("trait", "Necklace")
        .add("value", _equiped_neck)
        .build();
    let equipped_ring: ByteArray = JsonImpl::new()
        .add("trait", "Ring")
        .add("value", _equiped_ring)
        .build();
    let rank_at_death_trait: ByteArray = JsonImpl::new()
        .add("trait", "Rank at Death")
        .add("value", _rank_at_death)
        .build();
    let current_rank_trait: ByteArray = JsonImpl::new()
        .add("trait", "Current Rank")
        .add("value", _current_rank)
        .build();

    // Skuller
    let renderer_trait: ByteArray = JsonImpl::new()
        .add("trait", "Renderer")
        .add("value", "Skuller")
        .build();

    let attributes = array![
        name,
        xp,
        level,
        health,
        gold,
        str,
        dex,
        int,
        vit,
        wis,
        cha,
        luck,
        hours_left,
        equipped_weapon,
        equipped_chest,
        equipped_head,
        equipped_waist,
        equipped_foot,
        equipped_hand,
        equipped_neck,
        equipped_ring,
        rank_at_death_trait,
        current_rank_trait,
        renderer_trait,
    ].span();

    let metadata = metadata.add_array("attributes", attributes).build();

    // format!("data:application/json;base64,{}", bytes_base64_encode(metadata))
    format!("data:application/json,{}", metadata)
}







#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use core::array::ArrayTrait;
    use super::{create_metadata};
    use adventurer::{
        adventurer::{Adventurer, ImplAdventurer, IAdventurer}, stats::{Stats, ImplStats},
        adventurer_meta::{AdventurerMetadata, ImplAdventurerMetadata},
        equipment::{Equipment, EquipmentPacking}, bag::{Bag, IBag, ImplBag}, item::{ImplItem, Item},
    };
    use beasts::{constants::BeastSettings};


    #[test]
    fn test_metadata() {
        let adventurer = Adventurer {
            health: 1023,
            xp: 10000,
            stats: Stats {
                strength: 10,
                dexterity: 50,
                vitality: 50,
                intelligence: 50,
                wisdom: 50,
                charisma: 50,
                luck: 100
            },
            gold: 1023,
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
            beast_health: BeastSettings::STARTER_BEAST_HEALTH.into(),
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

        starknet::testing::set_block_timestamp(1721860860);

        let _current_1 = create_metadata(
            1000000,
            adventurer,
            'thisisareallyreallyreallongname',
            adventurer_metadata,
            bag,
            10,
            1,
            1
        );

        let _current_2 = create_metadata(
            1000000,
            adventurer,
            'thisisareallyreallyreallongname',
            adventurer_metadata,
            bag,
            10,
            2,
            2
        );

        let _current_3 = create_metadata(
            1000000,
            adventurer,
            'thisisareallyreallyreallongname',
            adventurer_metadata,
            bag,
            10,
            3,
            3
        );

        let _historical_1 = create_metadata(
            1000000,
            adventurer,
            'thisisareallyreallyreallongname',
            adventurer_metadata,
            bag,
            10,
            1,
            0
        );

        let _historical_2 = create_metadata(
            1000000,
            adventurer,
            'thisisareallyreallyreallongname',
            adventurer_metadata,
            bag,
            10,
            2,
            0
        );

        let _historical_3 = create_metadata(
            1000000,
            adventurer,
            'thisisareallyreallyreallongname',
            adventurer_metadata,
            bag,
            10,
            3,
            0
        );

        let _plain = create_metadata(
            1000000,
            adventurer,
            'thisisareallyreallyreallongname',
            adventurer_metadata,
            bag,
            10,
            0,
            0
        );

        // println!("Current 1: {}", current_1);
        // println!("Current 2: {}", current_2);
        // println!("Current 3: {}", current_3);
        // println!("Historical 1: {}", historical_1);
        // println!("Historical 2: {}", historical_2);
        // println!("Historical 3: {}", historical_3);
        // println!("Plain: {}", plain);
    }
}

