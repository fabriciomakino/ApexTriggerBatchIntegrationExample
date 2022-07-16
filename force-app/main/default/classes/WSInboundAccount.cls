/**
 * @ Author: Fabrício Makino
 * @ CreatedDate: 2022-07-16
 * @ Description: Webservice Inbound Example
 */
@RestResource(urlMapping='/account/*')
global with sharing class WSInboundAccount {

    /* Endpoint: Org url /services/apexrest/account    
    
    JSON Response Example
    {
        "AccountArray": [
            {
                "IdSalesforce": "0018Z00002fWL5FQAW",
                "Name": "WSInboundAccount 1",
                "Phone": "(100) 000-0000"
            },
            {
                "IdSalesforce": "0018Z00002fWL5FQAZ",
                "Name": "WSInboundAccount 2",
                "Phone": "(100) 000-0000"
            }            
        ]
    }
   */
    @HttpGet
    global static RequestParameter getAccountList(){    

        RestRequest request = RestContext.request;
        /* REQUEST PARAMS
        externalReference: (100) 000-0000
        */        
        String phone = request.params.get('externalReference');

        List<Account> lstAccount = [SELECT Id, Name, Phone FROM Account WHERE Phone =: phone];

        RequestParameter parameterizedAccountList = new RequestParameter(lstAccount);

        return parameterizedAccountList;

    } 

    private class Parameters {
        public Id IdSalesforce;
        public String Name;
        public String Phone;

        Parameters(Account account) {
            this.IdSalesforce = account.Id;
            this.Name = account.Name;
            this.Phone = account.Phone;
        }
    }

    global class RequestParameter {

        public String GetDateTime {get; set;}
        public List<Parameters> AccountArray {get; set;}
  
        public RequestParameter(List<Account> lstAccount) {
            this.GetDateTime = String.valueOfGmt(Datetime.now());
            AccountArray = new List<Parameters>();
            for (Account iAcc : lstAccount) {
                AccountArray.add(new Parameters(iAcc));
            }
        }
    }   
    
    /* JSON Request Example
    {
        "ExternalId": "ExternalId",
        "ExternalName": "POST ACCOUNT EXAMPLE",
        "ExternalContactArray": [
            {
                "ExternalLastName": "last name 1"
            },
            {
                "ExternalLastName": "last name 2"
            }
        ] 
    }
   */    
    @HttpPost
    global static ResponseParameter postAccount(String ExternalId, String ExternalName, List<ContactInbound> ExternalContactArray) {

        List<InboundErrorResult> lstInboundErrorResult = new List<InboundErrorResult>();

        Account account = new Account();
        account.Name = ExternalName;
        Database.UpsertResult accountUpsertResult = Database.upsert(account, false);

        if (!accountUpsertResult.isSuccess()) {
            lstInboundErrorResult.add(new InboundErrorResult(accountUpsertResult));                
        }

        List<Contact> lstContact = new List<Contact>();
        for (ContactInbound iContactInbound : ExternalContactArray) {
            lstContact.add(convertContact(account, iContactInbound));
        }
        List<Database.UpsertResult> lstContactUpsertResult = Database.upsert(lstContact, false);

        for(Database.UpsertResult iUpsertResult : lstContactUpsertResult) {
            if (!iUpsertResult.isSuccess()) {
                lstInboundErrorResult.add(new InboundErrorResult(iUpsertResult));                
            }
        }

        /* Create your insert integration log method 
        insertIntegrationtLog();
        */ 

        return new ResponseParameter(ExternalId, account, lstContact, lstInboundErrorResult);

    }

    private static Contact convertContact(Account account, ContactInbound contactInbound) {
        return new Contact(
            AccountId = account.Id,
            LastName = contactInbound.ExternalLastName
        );
    }

    global class ContactResponse {
        public String IdSalesforceContact;

        public ContactResponse(Contact contact) {
            this.IdSalesforceContact = contact.Id;
        }
    }

    global class ContactInbound {
        public String ExternalLastName;
    }    

    private class InboundErrorResult {
        public List<String> ListErrorMessage;
        public String Id;

        public InboundErrorResult(Database.UpsertResult upsertResult) {
            this.ListErrorMessage = new List<String>();
            this.Id = upsertResult.getId();
            for (Database.Error iError : upsertResult.getErrors()) {
                this.ListErrorMessage.add(iError.getMessage());
            }
        }
    }

    global class ResponseParameter {
        String ExternalId;
        String CreatedDateTime;
        String IdSalesforceAccount;
        String Status;
        List<ContactResponse> ContactArray;
        List<InboundErrorResult> ErrorResultArray;

        public ResponseParameter(String externalId, Account account, List<Contact> lstContact, List<InboundErrorResult> lstInboundErrorResult) {
            this.ExternalId = externalId;
            this.CreatedDateTime = String.valueOfGmt(Datetime.now());
            this.IdSalesforceAccount = account.Id;
            this.Status = lstInboundErrorResult.isEmpty() ? 'Success' : 'Error';
            this.ContactArray = new List<ContactResponse>();
            for (Contact iContact : lstContact) {
                this.ContactArray.add(new ContactResponse(iContact));
            }
            this.ErrorResultArray = lstInboundErrorResult;
        }
    }

}