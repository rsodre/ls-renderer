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
fn gold() -> ByteArray {"#ffb000"}
#[inline(always)]
fn silver() -> ByteArray {"#AAA9AD"}
#[inline(always)]
fn bronze() -> ByteArray {"#A97142"}
#[inline(always)]
fn black() -> ByteArray {"#000"}
#[inline(always)]
fn white() -> ByteArray {"#ddd"}

// @notice Generates a rect element
// @return The generated rect element
fn create_border(rank_at_death: u8, current_rank: u8) -> ByteArray {
    "<rect x='0.5' y='0.5' width='599' height='899' rx='25' fill='black' stroke='" + rank_color(rank_at_death, current_rank) + "'/>"
}

fn create_item_element(x: ByteArray, y: ByteArray, item: ByteArray) -> ByteArray {
    "<g transform='translate(" + x + "," + y + ") scale(1.5)' style='fill:" + gold() + ";'>" + item + "</g>"
}

fn rank_color(rank_at_death: u8, current_rank: u8) -> ByteArray {
    let rank = if (current_rank > rank_at_death) {current_rank} else {rank_at_death};
    if (rank == 0) {
        green()
    } else if (rank == 1) {
        gold()
    } else if (rank == 2) {
        silver()
    } else {
        bronze()
    }
}

fn generate_logo(rank_at_death: u8, current_rank: u8) -> ByteArray {
    if (rank_at_death == 0 || current_rank > 0) {
        "<g transform='scale(4)'>" + v0::logo() + "</g>"
    } else {
        "<g transform='scale(4)' style='fill:" + rank_color(rank_at_death, current_rank) + ";'>" + v0::logo() + "</g>"
    }
}

fn generate_crown(current_rank: u8) -> ByteArray {
    if (current_rank == 0) {
        ""
    } else {
        "<g transform='translate(0,-10) scale(2.68)' style='fill:" + rank_color(current_rank, 0) + ";'>" + v0::crown() + "</g>"
    }
}

fn create_skull(rank_at_death: u8, current_rank: u8) -> ByteArray {
    (
        "<g transform='translate(80,80) scale(4)'>" +
        generate_logo(rank_at_death, current_rank) +
        generate_crown(current_rank) +
        "</g>"
    )
}


//--------------------------------
// SKULLER
//

fn health() -> ByteArray {
    "<path transform='translate(-5,-2) scale(1.3)' fill-rule='evenodd' d='M14.5 2.157v-1h-1v-1h-3v1h-1v1h-1v1h-1v-1h-1v-1h-1v-1h-3v1h-1v1h-1v4h1v2h1v1h1v1h1v1h1v1h1v1h1v1h1v-1h1v-1h1v-1h1v-1h1v-1h1v-1h1v-2h1v-4h-1Z' clip-rule='evenodd'/>"
}

fn coin() -> ByteArray {
    "<path transform='translate(-5,-2) scale(0.035)' d='m586.96 215.35v-64.566h-21.609v-21.559h-21.504v-43.062h-21.566v-21.504h-43.07v-21.559h-64.566v-21.504h-129.31v21.504h-64.566v21.559h-43.062v21.504h-21.559v43.062h-21.504v21.559h-21.559v64.566h-21.504v129.31h21.504v64.574h21.559v21.559h21.504v43.062h21.559v21.508h43.062v21.559h64.566v21.508h129.31v-21.508h64.566v-21.559h43.07v-21.508h21.566v-43.062h21.504v-21.559h21.609v-64.574h21.449v-129.31zm0 43.062v64.68'/>"
}

fn trophy() -> ByteArray {
    "<path transform='translate(-2,-1) scale(1)' d='M3 3V2h2V0h7v2h2v1h-1v2h-1v2h-2v1H7V7H5V5H4V3zm4 0v1h1v2h2V1H9v1H8v1zM3 2H1v2h1v1h1v1h1v1h1v2h1v2H5v1H3v-1h2V9H4V8H3V7H2V6H1V5H0V2h1V1h2zm11 10h-2v-1h2zm-2-1h-1V9h1zm1-3v1h-1V7h1V6h1V5h1V4h1V2h1v3h-1v1h-1v1h-1v1zm3-7v1h-2V1zm-5 10v2H6v-2h1V9h3v2zm1 3v2H5v-2z'/>"
}

#[inline(always)]
fn space() -> ByteArray {
    "&#160;"
}

fn format_rank(rank: u8) -> ByteArray {
    let r: u8 = (rank % 10);
    if (r == 1) {
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
    "<rect x='" + x + "' y='" + y + "' width='" + w + "' height='" + h + "' fill='" + fill + "'/>"
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
        if (level == 1) {"#7b1e1c"}
        else if (value <= 2) {"#247b15"}
        else if (value <= 4) {"#237c16"}
        else if (value < 10) {"#48f525"}
        else {gold()};
    let text_color: ByteArray =
        if (value <= 4) {green()}
        else {black()};
    (
        "<rect x='" + format!("{}", x) + "' y='" + format!("{}", y) + "' width='" + format!("{}", w) + "' height='" + format!("{}", h) + "' fill='" + fill + "' shape-rendering='crispEdges' />"
        + create_text_color(name, format!("{}", x + w / 2), format!("{}", y + h / 3), "30", text_color.clone(), "middle", "")
        + create_text_color(number, format!("{}", x + w / 2), format!("{}", y + (h / 3) * 2), "35", text_color.clone(), "middle", "")
    )
}

fn create_text_color(
    text: ByteArray,
    x: ByteArray,
    y: ByteArray,
    fontsize: ByteArray,
    color: ByteArray,
    text_anchor: ByteArray, // start, middle, end
    add: ByteArray,
) -> ByteArray {
    "<text x='"
        + x
        + "' y='"
        + y
        + "' font-size='"
        + fontsize
        + "' style='fill:"
        + color
        + ";' text-anchor='"
        + text_anchor
        + "' dominant-baseline='middle' "
        + add
        + ">"
        + text
        + "</text>"
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
    let rect = create_border(rank_at_death, current_rank);

    let mut _name = Default::default();
    _name
        .append_word(
            adventurer_name, U256BytesUsedTraitImpl::bytes_used(adventurer_name.into()).into()
        );

    let _adventurer_id = format!("{}", adventurer_id);
    let _xp = format!("{}", adventurer.xp);
    let _level = format!("{}", adventurer.get_level());

    let _health = format!("{}", adventurer.health);

    let _max_health = format!("{}", adventurer.stats.get_max_health());

    let _rank_at_death = format!("{}", rank_at_death);
    let _current_rank = format!("{}", current_rank);

    let level: u8 = adventurer.get_level();
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
    let _luck = format!("{}", adventurer.stats.luck);

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
        create_skull(rank_at_death, current_rank),

        create_text_color("#" + _adventurer_id.clone(), "570", "60", "40", white(), "end", ""),
        create_text_color(format_rank(current_rank), "570", "105", "40", white(), "end", ""),

        create_xp(0, "XP", _xp.clone()),
        create_xp(1, "LVL", _level.clone()),
        create_xp_item(2, health(), _health.clone() + "/" + _max_health.clone()),
        create_xp_item(3, coin(), _gold.clone()),
        create_xp_item(4, trophy(), format_rank(rank_at_death)),

        create_text_color(_name.clone(), "300", "410", "40", white(), "middle", "textLength='540'"),

        create_stats(0, "STR", _str.clone(), adventurer.stats.strength, level),
        create_stats(1, "DEX", _dex.clone(), adventurer.stats.dexterity, level),
        create_stats(2, "INT", _int.clone(), adventurer.stats.intelligence, level),
        create_stats(3, "VIT", _vit.clone(), adventurer.stats.vitality, level),
        create_stats(4, "WIS", _wis.clone(), adventurer.stats.wisdom, level),
        create_stats(5, "CHA", _cha.clone(), adventurer.stats.charisma, level),
        create_stats(6, "LUCK", _luck.clone(), adventurer.stats.luck, level),
        
        // v0::create_text("LOOT SURVIVOR", "300", "872", "50", "middle", "middle"),
        // create_text_color("Adventurer #" + _adventurer_id.clone(), "300", "875", "30", green(), ""),
        create_text_color("LOOT SURVIVOR", "300", "875", "40", green(), "middle", "textLength='540'"),

        // equipped items
        create_item(0, _equiped_weapon.clone(), v0::weapon()),
        create_item(1, _equiped_chest.clone(), v0::chest()),
        create_item(2, _equiped_head.clone(), v0::head()),
        create_item(3, _equiped_waist.clone(), v0::waist()),
        create_item(4, _equiped_foot.clone(), v0::foot()),
        create_item(5, _equiped_hand.clone(), v0::hand()),
        create_item(6, _equiped_neck.clone(), v0::neck()),
        create_item(7, _equiped_ring.clone(), v0::ring()),
    ]
        .span();

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
    ]
        .span();

    let metadata = metadata.add_array("attributes", attributes).build();

    format!("data:application/json;base64,{}", bytes_base64_encode(metadata))
}

