public without sharing class SAIDSearchController {
	@AuraEnabled
    public static Boolean validateId(String saIDString){
        try{
            Decimal yearStart = 00;
            Decimal yearEnd = 99;
            Decimal monthStart = 01;
            Decimal monthEnd = 12;
            Decimal dateStart = 01;
            Decimal dateEnd = 31;
            Decimal genderStart = 0000;
            Decimal genderEnd = 9999;
            Decimal valueOFA = 8;
            Boolean flag = false;
            System.debug('saIDString--'+saIDString);
            if(!String.isBlank(saIDString)){
            	//String saIDString = String.valueOf(saId);
                if(Integer.valueOF(saIDString.subString(0,2))>=yearStart && Integer.valueOF(saIDString.subString(0,2))<=yearEnd
                  && Integer.valueOF(saIDString.subString(2,4))>=monthStart && Integer.valueOF(saIDString.subString(2,4))<=monthEnd
                  && Integer.valueOF(saIDString.subString(4,6))>=dateStart && Integer.valueOF(saIDString.subString(4,6))<=dateEnd
                  && Integer.valueOF(saIDString.subString(6,10))>=genderStart && Integer.valueOF(saIDString.subString(6,10))<=genderEnd
                  && (Integer.valueOF(saIDString.subString(10,11))==0 || Integer.valueOF(saIDString.subString(10,11))==1)
                   && Integer.valueOF(saIDString.subString(11,12))==8){
                   	flag=true;    
                   }
           }
            return flag;
        }
        Catch(Exception ex){
            System.debug('Error Message---'+ex.getMessage()+'in Line--'+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    @AuraEnabled
    public Static Integer submitRecord(String saIDString){
        try{
            Decimal genderFStart = 0000;
            Decimal genderFEnd = 4999;
            Decimal genderMStart = 5000;
            Decimal genderMEnd = 9999;
            String dateString = getyear(Integer.valueOF(saIDString.subString(0,2)))+saIDString.subString(0,2)+'-'+saIDString.subString(2,4)+'-'+saIDString.subString(4,6);
            Date dob = Date.valueOf(dateString);
            if(!String.isBlank(saIDString)){
                List<SA_User_Records__c> existingRecord = [Select id,No_of_Search__c from SA_User_Records__c where SA_ID__c = :saIDString];
                if(!existingRecord.isEmpty()){
                    existingRecord[0].No_of_Search__c = existingRecord[0].No_of_Search__c+1;
                    update existingRecord[0];
                }
                else{
                    SA_User_Records__c records = new SA_User_Records__c (
                        No_of_Search__c = 1,
                        SA_ID__c = saIDString,
                        Gender__c = Integer.valueOF(saIDString.subString(6,10))>=genderFStart && Integer.valueOF(saIDString.subString(6,10))<=genderFEnd ? 'Female':Integer.valueOF(saIDString.subString(6,10))>=genderMStart && Integer.valueOF(saIDString.subString(6,10))<=genderMEnd ? 'Male':null,
                        Date_of_Birth__c = dob,
                        SA_Citizen__c = Integer.valueOF(saIDString.subString(10,11))==0?False:True
                    );
                    insert records;
                    
                }
            } 
            return Integer.valueOF(getyear(Integer.valueOF(saIDString.subString(0,2)))+saIDString.subString(0,2));
        }
        Catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        
        
    }
    public static String getyear(Integer year){
        String yearInitial = String.valueOF(Date.today().year()).SubString(0,2)=='20'?100-year>80?'20':'19':null;
        return yearInitial;
    }
    @AuraEnabled
    public static List<InnerClass> getHolidayList(Integer Year,String searchKey){
        List<InnerClass> wrapList = new List<InnerClass> ();
        String api_Key = System.label.calendarificApiKey;
        List<Holiday_List__c> recordsToInsert = new List<Holiday_List__c> ();
        List<SA_User_Records__c> existingRecord = [Select id,No_of_Search__c from SA_User_Records__c where SA_ID__c = :searchKey];
    	String endpoint ='https://calendarific.com/api/v2/holidays?api_Key='+api_Key+'&country=ZA&year='+Year;
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        res = h.send(req);
        if(res.getStatusCode() == 200){
            HolidayWrapper artWrap = (HolidayWrapper)System.JSON.deserialize(formatJSON(res.getBody()), HolidayWrapper.class);
            System.debug('result---'+artWrap.response.holidays);
            for(HolidayWrapper.cls_holidays holiday : artWrap.response.holidays){
                InnerClass wrap = new InnerClass();
                HolidayWrapper.cls_date dateOfHoliday = holiday.clsdate;
                wrap.holidayName = holiday.name;
                System.debug('holidayName--'+dateOfHoliday);
                wrap.holidayDate = dateOfHoliday.iso;
                wrapList.add(wrap);
                if(!existingRecord.isEmpty()){
                	recordsToInsert.add(new Holiday_List__c(SA_User_Record__c = existingRecord[0].id,Holiday_Name__c = holiday.name));    
                }
            }    
        }
        return wrapList;
        
    }
    public static String formatJSON(String data) {
    	String regexFormat = '(?m)^\\s*"{0}"\\s*:';
		String replacementFormat = '"{0}" :';
		Map<String, String> replacements = new Map<String, String> {
        'date' => 'clsdate',
        'datetime' => 'clsdatetime'    
    };
	String formattedJSON = JSON.serializePretty(JSON.deserializeUntyped(data));
	for (String key : replacements.keySet()) {
       String regex = String.format(
            regexFormat,
            new List<String> {key}
        );

        String replacement = String.format(
            replacementFormat,
            new List<String> {replacements.get(key)}
        );
        formattedJSON = formattedJSON.replaceAll(regex, replacement);
    }

    return formattedJSON;
}
    public class InnerClass{
        @AuraEnabled public String holidayName;
        @AuraEnabled public String holidayDate;
        
    }
}