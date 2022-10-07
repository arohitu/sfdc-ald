/****************************************************************************************************
@author : Accenture UK
@date   : 04-Oct-2022
@description: Logger Framework Test class that creates a nexception and check if an log record was
              created
               
Version History
---------------
04-Oct-2022 - Rohit - Initial version
****************************************************************************************************/
@isTest
public class AMG_HandleCustomExceptionTest {

    /* 
    @description: Insert an account without name and force an exception
    @params: null
    @return: null    
    */
    @isTest
    public static void createAccount() {
        String relatedId;
        try {
            Integer len = 10;
            Blob blobKey = crypto.generateAesKey(128);
            String key = EncodingUtil.convertToHex(blobKey);
            relatedId = key.substring(0,len);
            Account m = new Account();
            //insert account without the mandatry Name field to cause an exception
            insert m;
        } 
        catch (Exception e) {
            Test.StartTest();
            
            AMG_HandleCustomException.LogException(e,relatedId);
            
            Test.StopTest();
        }
        List<AMG_Exception_Logger__c> logRecs = [SELECT
                                                   Id
                                                 FROM AMG_Exception_Logger__c
                                                 WHERE Related_To_Number__c =: relatedId 
                                                 LIMIT 1
                                                ];
        System.assertEquals(1, logRecs.size(), 'Log record was not inserted.');
    } 
}