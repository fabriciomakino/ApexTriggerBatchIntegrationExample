public with sharing class AccountTriggerHandler extends TriggerHandler {

    private List<Account> lstAccountOld;
    private List<Account> lstAccountNew;
    private Map<Id, Account> mapAccountOld;
    private Map<Id, Account> mapAccountNew;

    public AccountTriggerHandler() {
        this.lstAccountOld = Trigger.old;
        this.lstAccountNew = Trigger.new;
        this.mapAccountOld = (Map<Id, Account>) Trigger.oldMap;
        this.mapAccountNew = (Map<Id, Account>) Trigger.newMap;
    }
    
    public override void beforeUpdate() {
        FillAccountSiteDefault.execute(mapAccountOld, lstAccountNew);
    }

}