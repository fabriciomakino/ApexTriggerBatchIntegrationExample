/**
 * @ Author: Fabrício Makino
 * @ CreatedDate: 2022-07-16
 * @ Description: Example class
 */
public with sharing class FillAccountSiteDefault {

    public static void execute(Map<Id, Account> mapAccountOld, List<Account> lstAccountNew) {
        for (Account iAcc : lstAccountNew) {
            if(String.isBlank(iAcc.Site)) {
                Account oldAccount = mapAccountOld.get(iAcc.Id);
                iAcc.Site = 'www.' + oldAccount.Name.replace(' ', '') + '.salesforce.com';
            }
        }
    }

}