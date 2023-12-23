# PersonHub Relationship Card Module

# Introduction

The **personhub::relationshipcard** module is designed to manage relationship cards within the PersonHub ecosystem. Relationship cards contain information about individuals, including their name, profession, past relationships, hobbies, interests, and contact details.

# Module Structure

## Constants:

* **NOT_THE_OWNER:** Error code indicating that the sender is not the owner of the card.
* **INSUFFICIENT_FUNDS:** Error code indicating insufficient funds for card creation.
* **MIN_CARD_COST:** Minimum cost required to create a card.

## Structures:

* **relationshipcard:** Information structure for a person's card.
* **PersonHub:** Manages a collection of cards and tracks ownership.
* **CardCreated:** Event structure for a created card.
* **ProfessionUpdated:** Event structure for an updated profession.

## Initialization:

* **init:** Initializes the PersonHub module.

# Usage

## Creating a New Card

To create a new relationship card, use the **create_card** function. This function requires various parameters such as name, profession, image URL, past relationships, hobbies, interests, contact details, and a payment in **Coin<SUI>**.

`// Example Usage
let payment = Coin<SUI>(10); // SUI coins used for payment
personhub::relationshipcard::create_card(
    "John Doe".as_bytes().to_vec(),
    "Software Engineer".as_bytes().to_vec(),
    "https://example.com/johndoe.jpg".as_bytes().to_vec(),
    2,
    "Reading, Traveling".as_bytes().to_vec(),
    "Technology, Science".as_bytes().to_vec(),
    "john@example.com".as_bytes().to_vec(),
    payment,
    &mut person_hub_instance,
    &mut tx_context_instance,
);`

## Updating Card Description

To update the description of a card, use the **update_card_description** function. This requires the PersonHub instance, new description, card ID, and transaction context.

rust
Copy code
`// Example Usage
personhub::relationshipcard::update_card_description(
    &mut person_hub_instance,
    "New description for John Doe".as_bytes().to_vec(),
    card_id,
    &mut tx_context_instance,
);`

## Deactivating a Card

To deactivate a card, use the **deactivate_card** function. This requires the PersonHub instance, card ID, and transaction context.

`// Example Usage
personhub::relationshipcard::deactivate_card(&mut person_hub_instance, card_id, &mut tx_context_instance);`

## Getting Card Information

To retrieve information about a card, use the **get_card_info** function. This requires the PersonHub instance and card ID.

`// Example Usage
let card_info = personhub::relationshipcard::get_card_info(&person_hub_instance, card_id);
println!("Card Info: {:?}", card_info);`

## Events

* CardCreated: Emits when a new card is successfully created.
* ProfessionUpdated: Emits when the profession of a card is updated.

## Testing

For testing purposes, use the **init_for_testing** function in the test environment.

`// Example Usage
personhub::relationshipcard::init_for_testing(&mut tx_context_instance);`

## Note

* Ensure that the sender has sufficient funds for card creation (**MIN_CARD_COST**).
* Verify ownership before updating or deactivating a card.