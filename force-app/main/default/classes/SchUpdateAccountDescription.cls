/**
 * @ Author: Fabrício Makino
 * @ CreatedDate: 2022-07-16
 * @ Description: Schedule Example
 */
public with sharing class SchUpdateAccountDescription implements Schedulable {

    public void execute(SchedulableContext sc) {
        BatchUpdateAccountDescription batch = new BatchUpdateAccountDescription(); 
        Database.executeBatch(batch);
    }

}