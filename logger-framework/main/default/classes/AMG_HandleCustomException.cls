/****************************************************************************************************
@author : Accenture UK
@date   : 04-Oct-2022
@description: Logger Framework class that can be called from other apex classes to log(create)
              an exception record the AMG_Exception_Logger__c object. All users will have read/
              create permission permission for this object. On creation the record owner is 
              the logged in user. The sharing model for the object will be set to public 
              read-only and will be made available by a tab only to the support user.
               
Version History
---------------
04-Oct-2022 - Rohit - Initial version
****************************************************************************************************/
public with sharing class AMG_HandleCustomException extends Exception {
    
    /* 
    @description: Method that will recieve a exception and loads onto the custom object.
    @param1: Exception - he exception instance itself
    @param2: String - any string for which the exception might be related to
    @return: null    
    */
    public static void logException(Exception e, 
                                    String relatedToId) {
        //Details from the error itself
        String stackTrace = e.getStackTraceString().substringBefore('\n');
		String className = stackTrace.substringAfter('.').substringBefore('.');	
        String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
        
        //Governer Limit of executingQuery 
        String queryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
        String dmlLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
        String dmlStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();   
        String cpuTIme = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
        
        //Log information in object
        AMG_Exception_Logger__c exc = new AMG_Exception_Logger__c();
        exc.Related_To_Number__c=relatedToId;
        exc.Govt_Limit_in_Executing_Code__c = String.format('{0}\n{1}\n{2}\n{3}',new List<string>{queryLimit, dmlLimit,dmlStat,cpuTIme});
        exc.Exception_Message__c = e.getMessage();
        exc.Exception_Type__c = e.getTypeName();
        exc.Line_Number__c = e.getLineNumber();
        exc.StackTrace__c = e.getStackTraceString();
        exc.MethodName__c=methodName;
        exc.ClassName__c=className;
        //Enforcing Object permission for the user.
        if (Schema.sObjectType.AMG_Exception_Logger__c.isCreateable()) {
            Database.insert(exc);            
        }
    } 
}