/**
 * @ Author: Fabrício Makino
 * @ CreatedDate: 2022-07-16
 * @ Description: Callout Response Example
 */
public with sharing class AccountResponseVO {

    public String ExternalId;
    public String CreatedDateTime;
    public String IdSalesforceAccount;
    public String Status;
    public List<ContactResponse> ContactArray;
    public List<InboundErrorResult> ErrorResultArray;

    private class ContactResponse {
        public String IdSalesforceContact;
    }

    private class InboundErrorResult {
        public String Id;
        public List<String> ListErrorMessage;
    }    
}