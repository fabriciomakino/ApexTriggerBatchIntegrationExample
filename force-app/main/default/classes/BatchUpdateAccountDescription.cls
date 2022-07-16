/**
 * @ Author: Fabrício Makino
 * @ CreatedDate: 2022-07-16
 * @ Description: Batch Example
 */
public with sharing class BatchUpdateAccountDescription implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String accountQuery = 'SELECT Id, Description FROM Account WHERE Name = \'Batch Test\' ';
        return Database.getQueryLocator(accountQuery);
    }

    public void execute(Database.BatchableContext bc, List<Account> lstAccount){
        for (Account iAccount : lstAccount) {
            iAccount.Description = String.valueOf(Datetime.now());
        }

        update lstAccount;
    }

    public void finish(Database.BatchableContext bc){

    }
}