// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Dappazon {

    address public owner;

    struct Item {

        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock;

    }

    struct Order {

        uint256 time;
        Item item;

    }

    // Mapping
    mapping( uint256 => Item ) public items;
    mapping( address => uint256 ) public orderCount;
    mapping( address => mapping(uint256 => Order) ) public orders;

    // Event
    event Buy(address buyer, uint256 orderId, uint256 itemId);
    event List(string name, uint256 cost, uint256 stock);

    modifier onlyOwner() {

        require( msg.sender == owner );
        _;

    }

    constructor() {
        
        owner = msg.sender;

    }

    // List Product Function
    function list(
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock
    ) public onlyOwner {

        // Only Owner can list the item
        require( msg.sender == owner );

        // Creating Item Struct
        Item memory item = Item( 
            _id, 
            _name, 
            _category, 
            _image,
            _cost,
            _rating,
            _stock 
        );

        // Saving Item Struct to Blockchain
        items[_id] = item; 

        // Emit an event
        emit List( _name, _cost, _stock );

    }

    // Buy Product
    function buy(uint256 _id) public payable {

        // Fetch Item
        Item memory item = items[_id];

        // Check Ether
        require(msg.value >= item.cost);

        // Stock Availability
        require(item.stock > 0);

        // Create an Avatar
        Order memory order = Order( block.timestamp, item);

        // Saving Order to chain
        orderCount[msg.sender]++;
        orders[msg.sender][orderCount[msg.sender]] = order;

        // Update Stock
        items[_id].stock = item.stock - 1;

        // Emit Event
        emit Buy(msg.sender, orderCount[msg.sender], item.id);

    }

    // Withdraw Funds
    function withdraw() public onlyOwner {

        ( bool success, ) = owner.call{value: address(this).balance}("");
        require(success);

    }

}
