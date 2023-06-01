use integer::u256;
use integer::u256_from_felt252;
use starknet::ContractAddress;
use starknet::contract_address_const;

use demo_test::ERC20::ERC20;
use starknet::testing::set_caller_address;


fn setup() -> (ContractAddress, u256) {
    //call the constructor.
        let initial_supply: u256 = u256_from_felt252(2000);
        let account: ContractAddress = contract_address_const::<1>();
        let decimals: u8 = 18_u8; //need to do this currently, but the compiler will improve soon.

        let name: felt252 = 'Basecamp 04'; //note single quotes.
        let symbol: felt252 = 'BSC04';

        set_caller_address(account);

        ERC20::constructor(name, symbol, decimals, initial_supply, account);

        (account, initial_supply)
}

#[test]
#[available_gas(20000000)]
fn test_transfer(){
    let (sender, supply) = setup();

    let recipient: ContractAddress = contract_address_const::<2>();
    let amount: u256 = u256_from_felt252(12);

    let balance_recipient = ERC20::balance_of(recipient);
    let balance_sender = ERC20::balance_of(sender);

    ERC20::transfer(recipient, amount);

    assert(ERC20::balance_of(recipient) == u256_from_felt252(12) + balance_recipient, 'Transfer failed');
    assert(ERC20::balance_of(sender) == balance_sender - u256_from_felt252(12), 'Transfer failed');

    assert(ERC20::get_total_supply() == supply, 'Not same total supply');
}

#[test]
#[available_gas(20000000)]
#[should_panic]
fn test_transfer_to_zero() {
    let (sender, supply) = setup();

    let recipient: ContractAddress = contract_address_const::<0>();
    let amount: u256 = u256_from_felt252(12);

    let balance_recipient = ERC20::balance_of(recipient);
    let balance_sender = ERC20::balance_of(sender);

    ERC20::transfer(recipient, amount);

}

#[test]
#[available_gas(20000000)]
fn test_transfer_from() {
    let (sender, supply) = setup();

    let recipient: ContractAddress = contract_address_const::<2>(); //recipient is the spender, sender is the owner of the coins.
    //let amount: u256 = u256_from_felt252(12);

    assert(ERC20::allowance(sender, recipient) == u256_from_felt252(0), 'Wrong allowance initially set');

    ERC20::increase_allowance(recipient, u256_from_felt252(50));

    assert(ERC20::allowance(sender, recipient) == u256_from_felt252(50), 'Wrong allowance');

    let recipient2: ContractAddress = contract_address_const::<5>();

    set_caller_address(recipient);

    ERC20::transfer_from(sender, recipient2, u256_from_felt252(25));

    assert(ERC20::allowance(sender, recipient) == u256_from_felt252(25), 'wrong allowance');

    assert(ERC20::balance_of(recipient2) == u256_from_felt252(25), 'Wrong amount transferred');

    //Test for test_transfer_from is done.
}