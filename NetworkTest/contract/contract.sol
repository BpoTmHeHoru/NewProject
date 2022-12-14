//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
pragma abicoder v2;


contract main {


    address Bank = 0x4Aac9023a4549268eEaaC6668C579234A3654A2b;
    address InsuranceCompany = 0xaCBDAC3A8F859eebeF878E4721ced4C34f4F1a2e;


    constructor() {
        uint timestamp = block.timestamp;       //data of create contract
        Users[address(0xB88ce9a1b9F3c12f91fA3D48fDE118D39976DDC6)] = User(["Petrov","Petr","Petrovich"], "login", "123", Users[msg.sender].Card = IdentifierCard(0,0, Kategory.None),  1600681058, 0, 0, 0, 50 ether, Roles.Sotrudnic, false);
        Balances[address(0xB88ce9a1b9F3c12f91fA3D48fDE118D39976DDC6)] = 50 ether;    // address Petra
        Users[address(0x9C4383d15FC1005155593A0A12D7eF23AeA13f8D)] = User(["Semen","Semenovich","Semenev"], "login", "123", Users[msg.sender].Card = IdentifierCard(0,0, Kategory.None),  1505986658, 0, 0, 0, 50 ether, Roles.user, false);
        Balances[address(0x9C4383d15FC1005155593A0A12D7eF23AeA13f8D)] = 50 ether;    // address semena
        Users[0x61E34cb2Af19992A372Be4CBddd15C616cc8b9ad] = User(["Ivanov","Ivan","Ivanovich"], "login", "123", Users[msg.sender].Card = IdentifierCard(0,0, Kategory.None),  1348220258, 3, 0, 0, 50 ether, Roles.user, false);
        Balances[address(0x61E34cb2Af19992A372Be4CBddd15C616cc8b9ad)] = 50 ether;    // address Ivana
    }

    enum Roles { guest, user, Sotrudnic, InsuranceComp }
    enum Kategory { None, A, B, C }
     
    
    struct TS {
        Kategory    _Kategory;
        uint128     MarketPrice;
        uint128     Lifetime;
    }

    struct IdentifierCard {
        uint256     Number;
        uint256     ValidLife;
        Kategory    _Kategory;
    }

    struct strahovka {
        uint256     InsuranceFee;
        uint128     amountPrice;
        uint128     Lifetime;
        uint64      AmountUnpayFine;
        uint64      AmountDTP;
        uint128     StartYear;
    }

    struct Request {
        bool        _bool;
        uint256     amount;
    }

    struct User {
        string[3]   FIO;
        string       Login;
        string       Password;
        IdentifierCard Card;
        uint128     StartYear;
        uint64      AmountDTP;
        uint64      AmountUnpayFine;
        uint256     InsuranceFee;
        uint256     Balances;
        Roles       Role;
        bool        Insurance;
    }

    struct Fine {
        address     to;     
        uint256     NumberCard;
        uint256     amount;
        string      massage;
        uint256     timestamp;
        
    }

    mapping (address => strahovka) Insurance;
    mapping (address => Fine[]) Fines;
    mapping (address => IdentifierCard) IdentifierCardM;
    mapping (address => TS)   RegistrationCar;
    mapping (address => uint) Balances;
    mapping (address => User) Users;

    modifier onlyUser {
        require(Users[msg.sender].Role == Roles.user, "No user!");
        _;
    }

    modifier onlySotrudnic {
        require(Users[msg.sender].Role == Roles.Sotrudnic, "No sotrudnic!");
        _;
    }
    
    modifier onlyINC {
        require(Users[msg.sender].Role == Roles.InsuranceComp, "No Company!");
        _;
    }

    /**
    * @dev ?????????????? ??????????????????????
    */
    function reg(string[3] calldata _FIO, string calldata _login, string calldata _password) external returns (User memory) {
        require(Users[msg.sender].Role != Roles.user, "You are registration!");
        Users[msg.sender] = User(_FIO, _login, _password, Users[msg.sender].Card = IdentifierCard(0,0, Kategory.None),  0, 0, 0, 0, 0, Roles.user, false);
        return Users[msg.sender];
    }

    /**
    * @dev ?????????????? ??????????????????????
    */
    function auth(string memory _login, string memory _password) external view onlyUser returns (User memory) {
        require(keccak256(bytes(Users[msg.sender].Login)) == keccak256(bytes(_login)), "Invalid Login" );
        require(keccak256(bytes(Users[msg.sender].Password)) == keccak256(bytes(_password)), "Invalid Password" );
        return Users[msg.sender];
    }

    /**
    * @dev ?????????????? ?????????????????? ???????????????? 
    *
    * ?????????????? ?????????????? ?????????????????? 
    */
    function calculateInsurance(address _to) internal onlyUser  returns(uint) {
        require(RegistrationCar[_to]._Kategory != Kategory.None, "Not Register car");
         require(_to != address(0), "zero address!");
        uint128 _price  = RegistrationCar[_to].MarketPrice;
        uint128   delitel = 10;
        uint256 strahovoiVznos = _price * (1 - RegistrationCar[_to].Lifetime) * 1/delitel + 2/delitel*Users[_to].AmountUnpayFine+Users[_to].AmountDTP-2/delitel*Insurance[_to].StartYear ;
        return strahovoiVznos;
    }

    /**
    * @dev ?????????????? ?????????????? ?????????????????? 
    */
    function payInsurance(address _to) payable public onlyUser  {
        uint256  amount =  Insurance[_to].InsuranceFee = msg.value * 10 ether; 
            address payable to = payable(_to);
            to.transfer(amount);
    }

    /**
    * @dev ?????????????? ???????????? ?????????????????? 
    */
    function takeOutInsurance(address _to) internal onlyUser  {
         require(_to != address(0), "zero address!");
        Insurance[_to] = strahovka(
            calculateInsurance(_to),
            RegistrationCar[_to].MarketPrice,   
            RegistrationCar[_to].Lifetime,
            Users[_to].AmountUnpayFine,
            Users[_to].AmountDTP,
            Users[_to].StartYear);
            Users[_to].Insurance = true;
        
    }

    /**
    * @dev ???????????????? ???????????????????? ???????????????????????? ???? ???????????????????? ??????????????????
    */
    function sendRequests(bool _bool, address _to) payable public onlyUser returns (Request memory) {
        require(_to != address(0), "zero address!");
        Request memory newRequest = Request ({
            _bool: _bool,
            amount: calculateInsurance(_to)

        });
        
        if (_bool == true) {
            takeOutInsurance(_to);
            address payable addr = payable(InsuranceCompany);
            uint256 amount = Insurance[_to].InsuranceFee = msg.value;
            addr.transfer(amount);
        }
        
        return newRequest;
    }

    /**
    * @dev ?????????????? ???????????????????? ?????????????????????????? 
    */
    function addCard(uint128 _number, Kategory _kategory) external onlyUser {
        uint256 _validLife = block.timestamp + 63113852;
        IdentifierCardM[msg.sender] = IdentifierCard(_number, _validLife, _kategory); 
        accessCard(msg.sender, _number, _kategory, _validLife );
    }

    /**
    * @dev ?????????????? ?????????????????????? ???? ???????????????? 
    */
    function requestRegCar(Kategory _kategory, uint128 _marketPrice, uint128 _lifetime) external onlyUser {
        RegistrationCar[msg.sender] = TS(_kategory,_marketPrice, _lifetime);
        accessRegCar(msg.sender, _kategory, _marketPrice, _lifetime);
    }

    /**
    * @dev ?????????????? ?????????????????? ???????????????? ??????????????????????????  
    */
    function requestLifeTime() external onlyUser returns(IdentifierCard memory)  {
        require(IdentifierCardM[msg.sender].ValidLife  < block.timestamp - 2592000, "Extension is possible only in the last month!");
        require(Users[msg.sender].AmountUnpayFine == 0, "You have Unpay Fine!");
        accessLifeTime(msg.sender);
        return IdentifierCardM[msg.sender];
    }

    /**
    * @dev ?????????????? ???????????????????? ?????????????????? 
    */
    function getInsurance() external onlyUser  returns (uint) {
        require(Users[msg.sender].Insurance == false, "You have Insurance!");
        uint256 amount = calculateInsurance(msg.sender);

        return amount;

    }

    /**
    * @dev ?????????????? ???????????? ????????????
    */
    function payFine(uint id) public payable onlyUser {
        address payable addr = payable(Bank);
        Fines[msg.sender][id -1].amount = msg.value;
        if (Fines[msg.sender][id - 1].timestamp - 25 <= block.timestamp) {
            addr.transfer(msg.value/2);
            Fines[msg.sender][id - 1];
            Fines[msg.sender].pop();
        } else {
            addr.transfer(msg.value);
            Fines[msg.sender][id - 1];
            Fines[msg.sender].pop();
        }
        
    } 

    /**
    * @dev ?????????????? ?????????????????????????? ?????????????????????????? (??????????????????????????) 
    */
    function accessCard(address sender, uint128 _number, Kategory _kategory, uint256 _validLife) internal onlyUser returns (IdentifierCard memory) {
        require(sender != address(0), "zero address!");
        require(_number > 99 && _number < 1000, "Enter correct number!");
        IdentifierCardM[sender].Number = _number;
        IdentifierCardM[sender]._Kategory = _kategory;
        IdentifierCardM[sender].ValidLife = _validLife;
        return IdentifierCardM[sender];
    }

    /**
    * @dev ?????????????? ?????????????????????????? ?????????????????????? ???? ???????????????? (??????????????????????????)
    */
    function accessRegCar(address sender, Kategory _kategory, uint128 _marketPrice, uint128 _lifetime) internal onlyUser returns (TS memory) {
        require(sender != address(0), "zero address!");
        require(IdentifierCardM[sender]._Kategory == _kategory, "Invalid Category!");
        require(_kategory != Kategory.None);
        RegistrationCar[sender]._Kategory = _kategory;
        RegistrationCar[sender].MarketPrice = _marketPrice;
        RegistrationCar[sender].Lifetime = _lifetime;
        return RegistrationCar[sender];

    }

    /**
    * @dev ?????????????? ?????????????????????????? ?????????????????? ?????????????????????????? (??????????????????????????) 
    */
    function accessLifeTime(address sender) internal onlyUser {
        require(sender != address(0), "zero address!");
        IdentifierCardM[sender].ValidLife = block.timestamp + 63113852;
    }

    /**
    * @dev ?????????????? ?????????????????????? ???????????? 
    */
    function setFine(address _to, uint256 _numberCard, string calldata _massage, uint128 amount) public onlySotrudnic {
        require(_to != address(0), "zero address!");
        Users[_to].AmountUnpayFine++;
        Fines[_to].push(Fine(_to, _numberCard, amount, _massage, block.timestamp ));

    }

    /**
    * @dev ?????????????? ?????????????? ?????? ?? ???????????????? ?????????????????? 
    */
    function setDTP(address _to) payable public onlySotrudnic {
        require(_to != address(0), "zero address!");
        Users[_to].AmountDTP++;
        if (Users[_to].Insurance == true) {
            payInsurance(_to); 
        }
    }






}






