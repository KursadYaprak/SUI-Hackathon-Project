// Importing necessary modules and types
module personhub::relationshipcard {
    use std::option::{Self, Option};
    use std::string::{Self, String};

    // Importing modules from sui (assumed external library) namespace
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::object_table::{Self, ObjectTable};
    use sui::event;

    // Constants for error codes
    const NOT_THE_OWNER: u64 = 0;
    const INSUFFICIENT_FUNDS: u64 = 1;
    const MIN_CARD_COST: u64 = 1;

    // Structure defining the information needed for a person's card
    struct relationshipcard has key, store {
        id: UID
        name: String,
        owner: address,
        profession: String,
        img_url: Url,
        description: Option<String>,
        how_many_past_relationship: u8,
        hobbies: String,
        interests: String,
        contact: String,
        open_to_relationship: bool,
    }

    // Structure representing the PersonHub, which manages a collection of cards
    struct PersonHub has key {
        id: UID,
        owner: address,
        counter: u64,
        cards: ObjectTable<u64, PersonCard>,
    }

    // Event structure for a created card
    struct CardCreated has copy, drop {
        id: ID,
        name: String,
        owner: address,
        profession: String,
        contact: String,
    }

    // Event structure for an updated profession
    struct ProfessionUpdated has copy, drop {
        name: String,
        owner: address,
        new_profession: String
    }

    // Initialization function for PersonHub
    fun init(ctx: &mut TxContent) {
        transfer::share_object(
            PersonHub {
                id: object::new(ctx),
                owner: tx_context::sender(ctx),
                counter: 0,
                cards: object_table::new(ctx),
            }
        );
    }

    // Entry function to create a new card
    public entry fun create_card(
        name: vector<u8>,
        profession: vector<u8>,
        img_url: vector<u8>,
        how_many_past_relationship: u8,
        hobbies: vector<u8>,
        interests: vector<u8>,
        contact: vector<u8>,
        payment: Coin<SUI>,
        personhub: &mut PersonHub,
        ctx: &mut TxContent
    )    {
        let value = coin::value(&payment);
        // Check if the payment value is sufficient
        assert!(value == MIN_CARD_COST, INSUFFICIENT_FUNDS);
        transfer::public_transfer(payment, personhub.owner);

        personhub.counter = personhub.counter + 1;

        let id = object::new(ctx);

        // Emit a CardCreated event
        event::emit(
            CardCreated {
                id: object::uid_to_inner(&id),
                name: string::utf8(name),
                owner: tx_context::sender(ctx),
                profession: string::utf8(profession),
                contact: string::utf8(contact)
            }
        );

        // Create a relationship card and add it to the PersonHub's cards
        let relationshipcard = PersonCard {
            id: id,
            name: string::utf8(name),
            owner: tx_context::sender(ctx),
            profession: string::utf8(profession),
            img_url: url::new_unsafe_from_bytes(img_url),
            description: option::none(),
            how_many_past_relationship,
            hobbies: string::utf8(hobbies),
            interests: string::utf8(interests),
            contact: string::utf8(contact),
            open_to_relationship: true,
        };

        object_table::add(&mut personhub.cards, personhub.counter, relationshipcard);
    }

    // Entry function to update the description of a card
    public entry fun update_card_description(personhub: &mut PersonHub, new_description: vector<u8>, id: u64, ctx: &mut TxContent) {
         let user_card = object_table::borrow_mut(&mut personhub.cards, id);
         // Ensure that the sender is the owner of the card
         assert!(tx_context::sender(ctx) == user_card.owner, NOT_THE_OWNER);
         // Swap or fill the description and emit a DescriptionUpdated event
         let old_value = option::swap_or_fill(&mut user_card.description, string::utf8(new_description));

         event::emit(DescriptionUpdated {
            name: user_card.name,
            owner: user_card.owner,
            new_description: string::utf8(new_description)
         });

         _ = old_value;
    }

    // Entry function to deactivate a card
    public entry fun deactivate_card(personhub: &mut PersonHub, id: u64, ctx: &mut TxContent) {
        let card = object_table::borrow_mut(&mut personhub.cards, id);
        // Ensure that the sender is the owner of the card
        assert!(card.owner == tx_context::sender(ctx), NOT_THE_OWNER);
        card.open_to_relationship = false;
    }

    // Function to get information about a card
    public fun get_card_info(personhub: &PersonHub, id: u64): (
        String,
        address,
        String,
        Url,
        Option<String>,
        u8,
        String,
        String,
        String,
        bool,
    ) {
        let card = object_table::borrow(&personhub.cards, id);
        // Return the information about the card
        (
            card.name,
            card.owner,
            card.profession,
            card.img_url,
            card.description,
            card.how_many_past_relationship,
            card.hobbies,
            card.interests,
            card.contact,
            card.open_to_relationship
        )
    }

    // Test initialization function for testing purposes
    #[test]
    // Not public by default
    public fun init_for_testing(ctx: &mut TxContext){
        init(ctx);
    }
}

import 0x1::personhub::relationshipcard;

module personhub::relationshipcard_test {
    use 0x1::personhub::relationshipcard;

    // Test the creation of multiple cards and updating description
    public fun test_create_multiple_cards_and_update_description() {
        // Initialize the context for testing
        let mut ctx = 0x1::sui::tx_context::create();

        // Initialize the PersonHub for testing
        relationshipcard::init_for_testing(&mut ctx);

        // Create three test cards
        create_test_card(b"Alice", b"Engineer", b"https://example.com/alice.jpg", 1, b"Music", b"Travel", b"alice@example.com", 2, &mut ctx);
        create_test_card(b"Bob", b"Designer", b"https://example.com/bob.jpg", 0, b"Art", b"Cooking", b"bob@example.com", 3, &mut ctx);
        create_test_card(b"Charlie", b"Doctor", b"https://example.com/charlie.jpg", 5, b"Reading", b"Sports", b"charlie@example.com", 1, &mut ctx);

        // Update the description of the second card
        let updated_description = b"Updated description for Bob";
        update_description(2, updated_description, &mut ctx);

        // Verify the updated description
        let updated_card_info = relationshipcard::get_card_info(&0x1::sui::tx_context::sender(&ctx), 2);
        assert!(updated_card_info.4 == Some("Updated description for Bob"));

        // Print a success message
        0x1::sui::event::emit({}) // Dummy event to print success
    }

    // Helper function to create a test card
    fun create_test_card(
        name: vector<u8>, profession: vector<u8>, img_url: vector<u8>,
        how_many_past_relationship: u8, hobbies: vector<u8>, interests: vector<u8>,
        contact: vector<u8>, coin_value: u64, ctx: &mut 0x1::sui::tx_context::TxContext
    ) {
        let coin = 0x1::sui::coin::create(coin_value);
        relationshipcard::create_card(
            name, profession, img_url, how_many_past_relationship,
            hobbies, interests, contact, coin, &mut ctx
        );
    }

    // Helper function to update the description of a card
    fun update_description(card_id: u64, new_description: vector<u8>, ctx: &mut 0x1::sui::tx_context::TxContext) {
        relationshipcard::update_card_description(&mut 0x1::sui::tx_context::sender(&ctx), new_description, card_id, &mut ctx);
    }
}

