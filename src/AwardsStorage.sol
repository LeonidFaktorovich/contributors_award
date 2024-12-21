// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CompanyProductRegistry {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct Company {
        address companyAddress;
        bytes publicKey;
        bool exists;
    }

    struct Product {
        string description;
    }

    address[] private addresses;

    mapping(address => Company) public companies;

    mapping(address => Product[]) private companyProducts;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyCompany() {
        require(companies[msg.sender].exists, "Only company can perform this action");
        _;
    }

    event CompanyAdded(address companyAddress, bytes publicKey);

    event ProductAdded(address companyAddress, string description);

    function addCompany(address _companyAddress, bytes memory _publicKey) public onlyOwner {
        require(_companyAddress != address(0), "Invalid company address");
        require(!companies[_companyAddress].exists, "Company already exists");

        companies[_companyAddress] = Company({
            companyAddress: _companyAddress,
            publicKey: _publicKey,
            exists: true
        });

        addresses.push(_companyAddress);

        emit CompanyAdded(_companyAddress, _publicKey);
    }

    function addProduct(string memory _description) public onlyCompany {
        require(bytes(_description).length > 0, "Description cannot be empty");

        Product[] storage products = companyProducts[msg.sender];

        products.push(Product({
            description: _description
        }));

        companyProducts[msg.sender] = products;

        emit ProductAdded(msg.sender, _description);
    }

    function getCompanies() public view returns (address[] memory) {
        uint256 companyCount = 0;

        for (uint256 i = 0; i < addresses.length; i++) {
            if (companies[addresses[i]].exists) {
                companyCount++;
            }
        }

        address[] memory companyAddresses = new address[](companyCount);
        uint256 index = 0;
        for (uint256 i = 0; i < addresses.length; i++) {
            if (companies[addresses[i]].exists) {
                companyAddresses[index] = addresses[i];
                index++;
            }
        }

        return companyAddresses;
    }

    function getProductsByCompany(address _companyAddress) public view returns (Product[] memory) {
        require(companies[_companyAddress].exists, "Company does not exist");
        return companyProducts[_companyAddress];
    }

    function getAllProducts() public view returns (Product[] memory) {
        uint256 totalProducts = 0;

        for (uint256 i = 0; i < addresses.length; i++) {
            if (companies[addresses[i]].exists) {
                totalProducts += companyProducts[addresses[i]].length;
            }
        }

        Product[] memory allProducts = new Product[](totalProducts);
        uint256 index = 0;
        for (uint256 i = 0; i < addresses.length; i++) {
            if (companies[addresses[i]].exists) {
                Product[] storage products = companyProducts[addresses[i]];
                for (uint256 j = 0; j < products.length; j++) {
                    allProducts[index] = products[j];
                    index++;
                }
            }
        }

        return allProducts;
    }
}
