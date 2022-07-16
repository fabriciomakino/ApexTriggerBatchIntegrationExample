/**
 * @ Author: Fabrício Makino
 * @ CreatedDate: 2022-07-16
 * @ Description: Callout Request Account Example

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
public with sharing class AccountRequestVO {

    public String ExternalId { get; set; }
    public String ExternalName { get; set; }
    public List<ExternalContact> ExternalContactArray { get; set; }

    public AccountRequestVO(Account account, List<Contact> lstContact) {
        this.ExternalId = account.Id;
        this.ExternalName = account.Name;
        this.ExternalContactArray = new List<ExternalContact>();
        for (Contact iContact : lstContact) {
            this.ExternalContactArray.add(new ExternalContact(iContact));
        }
    }

    public class ExternalContact {
        public String ExternalLastName { get; set; }

        public ExternalContact(Contact contact) {
            this.ExternalLastName = contact.LastName;
        }
    }

}