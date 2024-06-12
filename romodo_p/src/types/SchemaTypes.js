/** 
Passenger interface
@interface
@extends Document
*/


function Passenger() {
     /**
     * Passenger's email
     * @type {string}
     */
     this.email = '';
    
    /**
     * Username
     * @type {string}
     */
    this.username = '';

    /**
     * Password
     * @type {string}
     */
    this.password = '';
    
    /**
     * Passenger's first name
     * @type {string}
     */
    this.firstName = '';


    /**
     * Passenger's last name
     * @type {string}
     */
    this.lastName = '';

    /**
     * Passenger's NIC number
     * @type {string}
     */
    this.nicNo = '';

     /**
     *Gender    
        * @type {string}
        */
     this.gender = '';
     
        /**
         * Passenger's date of birth
         * @type {Date}
         */
        this.dateOfBirth = new Date();

        /**
         * Passenger's contact number
         * @type {string}
         */
        this.contactNo = '';

        /**
         * Passenger's service number
         * @type {string}
         */
        this.serviceNo = '';

        /**
         * company name
         * @type {string}
         */
        this.companyName = '';

        /**
        * Indicates whether the passenger is internal or external
        * @type {boolean}
        */
        this.isInternal = false;
         



}

module.exports = {Passenger: Passenger};