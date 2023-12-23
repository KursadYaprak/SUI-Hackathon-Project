module personhub_test {
    use std::option::{Option, Some, None};
    use std::string::String;
    use sui::coin::{Coin, SUI};
    use personhub::relationshipcard::{PersonHub, create_card, update_card_description, deactivate_card, get_card_info, CardCreated};

    const DEFAULT_NAME: &'static [u8] = b"Alice";
    const DEFAULT_PROFESSION: &'static [u8] = b"Software Engineer";
    const DEFAULT_IMG_URL: &'static [u8] = b"https://example.com/alice.jpg";
    const DEFAULT_HOBBIES: &'static [u8] = b"Reading, Hiking";
    const DEFAULT_INTERESTS: &'static [u8] = b"Technology, Travel";
    const DEFAULT_CONTACT: &'static [u8] = b"alice@example.com";
    const DEFAULT_DESCRIPTION: &'static [u8] = b"Description for Alice";

    // Test Case 1: Create a new card
    public fun test_create_card() {
        let mut person_hub = PersonHub {
            id: 1,  // You can set a specific ID for testing purposes
            owner: 0x0123456789ABCDEF,  // Replace with a valid address
            counter: 0,
            cards: ObjectTable::new(),
        };

        let mut ctx = TxContent::new();

        let payment = Coin::new(SUI, 1);  // Assuming the cost is 1 SUI

        create_card(
            DEFAULT_NAME,
            DEFAULT_PROFESSION,
            DEFAULT_IMG_URL,
            0,  // how_many_past_relationship
            DEFAULT_HOBBIES,
            DEFAULT_INTERESTS,
            DEFAULT_CONTACT,
            payment,
            &mut person_hub,
            &mut ctx,
        );

        // Check if a card is created
        assert!(person_hub.counter == 1);

        let card_info = get_card_info(&person_hub, 1);

        // Check if the card information is correct
        assert!(card_info.0 == String::from_utf8_lossy(DEFAULT_NAME));
        assert!(card_info.1 == person_hub.owner);
        assert!(card_info.2 == String::from_utf8_lossy(DEFAULT_PROFESSION));
        assert!(card_info.3 == Url::new_unsafe_from_bytes(DEFAULT_IMG_URL));
        assert!(card_info.4 == None);
        assert!(card_info.5 == 0);  // how_many_past_relationship
        assert!(card_info.6 == String::from_utf8_lossy(DEFAULT_HOBBIES));
        assert!(card_info.7 == String::from_utf8_lossy(DEFAULT_INTERESTS));
        assert!(card_info.8 == String::from_utf8_lossy(DEFAULT_CONTACT));
        assert!(card_info.9 == true);

        // Optionally, you can check if the CardCreated event is emitted
        match ctx.pop_event() {
            Some(event) => match event {
                CardCreated { id, name, owner, profession, contact } => {
                    assert!(id == 1);
                    assert!(name == String::from_utf8_lossy(DEFAULT_NAME));
                    assert!(owner == person_hub.owner);
                    assert!(profession == String::from_utf8_lossy(DEFAULT_PROFESSION));
                    assert!(contact == String::from_utf8_lossy(DEFAULT_CONTACT));
                }
                _ => panic!("Unexpected event type"),
            },
            None => panic!("No event emitted"),
        }
    }

    // Test Case 2: Update card description
    public fun test_update_card_description() {
        let mut person_hub = PersonHub {
            id: 1,
            owner: 0x0123456789ABCDEF,
            counter: 0,
            cards: ObjectTable::new(),
        };

        let mut ctx = TxContent::new();

        // Create a card first
        test_create_card();

        let new_description = b"Updated description for Alice";

        update_card_description(&mut person_hub, new_description, 1, &mut ctx);

        let card_info = get_card_info(&person_hub, 1);

        // Check if the card description is updated
        assert!(card_info.4 == Some(String::from_utf8_lossy(new_description)));

        // Optionally, you can check if the DescriptionUpdated event is emitted
        match ctx.pop_event() {
            Some(event) => match event {
                DescriptionUpdated { name, owner, new_description } => {
                    assert!(name == String::from_utf8_lossy(DEFAULT_NAME));
                    assert!(owner == person_hub.owner);
                    assert!(new_description == String::from_utf8_lossy(new_description));
                }
                _ => panic!("Unexpected event type"),
            },
            None => panic!("No event emitted"),
        }
    }

    // Test Case 3: Deactivate card
    public fun test_deactivate_card() {
        let mut person_hub = PersonHub {
            id: 1,
            owner: 0x0123456789ABCDEF,
            counter: 0,
            cards: ObjectTable::new(),
        };

        let mut ctx = TxContent::new();

        // Create a card first
        test_create_card();

        deactivate_card(&mut person_hub, 1, &mut ctx);

        let card_info = get_card_info(&person_hub, 1);

        // Check if the card is deactivated
        assert!(card_info.9 == false);
    }
}
