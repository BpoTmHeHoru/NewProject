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
        bytes       Login;
        bytes       Password;
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
    * @dev Функция регистрации
    */
    function reg(string[3] calldata _FIO, bytes calldata _login, bytes calldata _password) external returns (User memory) {
        require(Users[msg.sender].Role != Roles.user);
        Users[msg.sender] = User(_FIO, _login, _password, Users[msg.sender].Card = IdentifierCard(0,0, Kategory.None),  0, 0, 0, 0, 0, Roles.user, false);
        return Users[msg.sender];
    }

    /**
    * @dev Функция авторизации
    */
    function auth(bytes memory _login, bytes memory _password) external view onlyUser returns (User memory) {
        require(keccak256(Users[msg.sender].Login) == keccak256(_login), "Invalid Login" );
        require(keccak256(Users[msg.sender].Password) == keccak256(_password), "Invalid Password" );
        return Users[msg.sender];
    }

    /**
    * @dev Функции страховой компании 
    *
    * Функция расчёта страховки 
    */
    function calculateInsurance(address _to) internal onlyUser onlyINC returns(uint) {
        uint128 _price  = RegistrationCar[_to].MarketPrice;
        uint128   delitel = 10;
        uint256 strahovoiVznos = _price * (1 - RegistrationCar[_to].Lifetime) * 1/delitel + 2/delitel*Users[_to].AmountUnpayFine+Users[_to].AmountDTP-2/delitel*Insurance[_to].StartYear ;
        return strahovoiVznos;
    }

    /**
    * @dev Функция выплаты страховки 
    */
    function payInsurance(address _to) payable public onlyINC {
        uint256  amount =  Insurance[_to].InsuranceFee = msg.value * 10 ether; 
            address payable to = payable(_to);
            to.transfer(amount);
    }

    /**
    * @dev Функция выдачи страховки 
    */
    function takeOutInsurance(address _to) internal onlyUser onlyINC {
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
    * @dev Отправка соглашения пользователя на оформление страховки
    */
    function sendRequests(bool _bool, address _to) payable public onlyUser returns (Request memory) {
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
    * @dev Функция добавления удостоверения 
    */
    function addCard(uint128 _number, Kategory _kategory) external onlyUser {
        uint256 _validLife = block.timestamp + 63113852;
        IdentifierCardM[msg.sender] = IdentifierCard(_number, _validLife, _kategory); 
        accessCard(msg.sender, _number, _kategory, _validLife );
    }

    /**
    * @dev Функция регистрации ТС водителя 
    */
    function requestRegCar(Kategory _kategory, uint128 _marketPrice, uint128 _lifetime) external onlyUser {
        RegistrationCar[msg.sender] = TS(_kategory,_marketPrice, _lifetime);
        accessRegCar(msg.sender, _kategory, _marketPrice, _lifetime);
    }

    /**
    * @dev Функция продления действия удостоверения  
    */
    function requestLifeTime() external onlyUser returns(IdentifierCard memory)  {
        require(IdentifierCardM[msg.sender].ValidLife  < block.timestamp - 2592000, "Extension is possible only in the last month!");
        require(Users[msg.sender].AmountUnpayFine == 0, "You have Unpay Fine!");
        accessLifeTime(msg.sender);
        return IdentifierCardM[msg.sender];
    }

    /**
    * @dev Функция оформления страховки 
    */
    function getInsurance() external onlyUser  returns (uint) {
        uint256 amount = calculateInsurance(msg.sender);

        return amount;

    }

    /**
    * @dev Функция оплаты штрафа
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
    * @dev Функция подтверждения удостоверения (автоматически) 
    */
    function accessCard(address sender, uint128 _number, Kategory _kategory, uint256 _validLife) internal onlyUser returns (IdentifierCard memory) {
        //require(_number == , "Number must have 3 characters!");
        IdentifierCardM[sender].Number = _number;
        IdentifierCardM[sender]._Kategory = _kategory;
        IdentifierCardM[sender].ValidLife = _validLife;
        return IdentifierCardM[sender];
    }

    /**
    * @dev Функция подтверждения регистрации ТС водителя (автоматически)
    */
    function accessRegCar(address sender, Kategory _kategory, uint128 _marketPrice, uint128 _lifetime) internal onlyUser returns (TS memory) {
        require(IdentifierCardM[sender]._Kategory == _kategory, "Invalid Category!");
        RegistrationCar[sender]._Kategory = _kategory;
        RegistrationCar[sender].MarketPrice = _marketPrice;
        RegistrationCar[sender].Lifetime = _lifetime;
        return RegistrationCar[sender];

    }

    /**
    * @dev Функция подтверждения продления удостоверения (автоматически) 
    */
    function accessLifeTime(address sender) internal onlyUser {
        IdentifierCardM[sender].ValidLife = block.timestamp + 63113852;
    }

    /**
    * @dev Функция выписывания штрафа 
    */
    function setFine(address _to, uint256 _numberCard, string calldata _massage, uint128 amount) public onlySotrudnic {
        Users[_to].AmountUnpayFine++;
        Fines[_to].push(Fine(_to, _numberCard, amount, _massage, block.timestamp ));

    }

    /**
    * @dev Функция отметки ДТП и покрытие страховки 
    */
    function setDTP(address _to) payable public onlySotrudnic {
        Users[_to].AmountDTP++;
        if (Users[_to].Insurance == true) {
            payInsurance(_to); 
        }
    }


}
