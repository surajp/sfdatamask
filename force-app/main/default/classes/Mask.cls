public with sharing class Mask {
	
    private string sObjName;
    private String[] validFields;
    Map<String,Schema.SObjectField> fieldsMap;
    Map<String,Mask_Config__c> validConfigMap = new Map<string,Mask_Config__c>();
    boolean insertNew = false;
    Schema.SObjectType theSObjectType = null;
    public Mask(String sObjectName,boolean insertNew){
        this.sObjName = sObjectName;
        this.insertNew = insertNew;
        initConfig();
    }
    
    private void initConfig(){
        
        Mask_Config__c[] configRecs = [Select Source_Field_Name__c,Mask__c from Mask_Config__c where Source_SObject__c=:sObjName];
        validFields = new String[]{};
        theSObjectType = Schema.getGlobalDescribe().get(sObjName.toLowerCase());
        fieldsMap = theSObjectType.getDescribe().fields.getMap();
        for(String fieldName: fieldsMap.keySet()){
            Schema.SObjectField theField = fieldsMap.get(fieldName);
            if(theField!=null && theField.getDescribe().isUpdateable() && theField.getDescribe().isCreateable()){
                validFields.add(fieldName);
            }
        }
        Set<String> validFieldSet = new Set<String>(validFields);
        for(Mask_Config__c config: configRecs){
            if(validFieldSet.contains(config.Source_Field_Name__c)){
                validConfigMap.put(config.Source_Field_Name__c,config);
            }
        }
    }
    
    public void execute(){
        SObject[] recordsToUpdate = new SObject[]{};
        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType>{theSObjectType});
        for(SObject myRecord : Database.query('Select '+String.join(validFields,',')+' from '+sObjName)){
            
            for(String fName:validFields){
                if(validConfigMap.containsKey(fName) && isMaskValid(validConfigMap.get(fName).Mask__c)){
                    String maskedVal = Masker.doMask(String.valueOf(myRecord.get(fName)),validConfigMap.get(fName).Mask__c);
                    switch on fieldsMap.get(fName).getDescribe().getType() {
                        when  Boolean{
                            myRecord.put(fName,Boolean.valueOf(maskedVal));
                        }
                        when  Date{
                            myRecord.put(fName,Date.valueOf(maskedVal));
                        }
                        when  Currency{
                            myRecord.put(fName,Decimal.valueOf(maskedVal));
                        }
                        when  Integer{
                            myRecord.put(fName,Integer.valueOf(maskedVal));
                        }
                        when  Long{
                            myRecord.put(fName,Long.valueOf(maskedVal));
                        }
                        when  Percent{
                            myRecord.put(fName,Decimal.valueOf(maskedVal));
                        }
                        when else {
                            myRecord.put(fName,maskedVal);
                        }
                    }
                }
            }
            if(insertNew){
                uow.registerNew(myRecord.clone(false,false,false,false));
            }else{
                uow.registerDirty(myRecord);
            }
        }
        uow.commitWork();
    }
    
    
    private boolean isMaskValid(String theMask){
        return true;
    }
}