public class Masker {
    
    private static Map<String,String[]> maskLists = new Map<String,String[]>();//{'mylist' => new String[]{'hello','world','from','suraj'}, 'listtwo' => new String[]{'bye','universe'}};
   	
  	private static Integer counter=0;
    public void resetCounter(){
        counter=0;
    }
    
    private void initMaskLists(){
        
        for(Mask_List_Value__c maskListVal: [Select Name,Mask_Value__c from Mask_List_Value__c]){
            if(maskLists.containsKey(maskListVal.Name)){
                maskLists.get(maskListVal.Name).add(maskListVal.Mask_Value__c);
            }else{
                maskLists.put(maskListVal.Name,new String[]{maskListVal.Mask_Value__c});
            }
        }
    }
	
    public static String doMask(String source,String theMask){
        
        if(theMask.indexOf('${')!=-1){
        	if(theMask.indexOf('${COUNTER}')>-1)
            	theMask = theMask.replaceAll('\\$\\{COUNTER\\}',String.valueOf(counter++));
            if(theMask.indexOf('${LIST')>-1){   // ${LIST:list_field_name__c}
                system.debug('in if');
                // Pattern listPattern = Pattern.compile('^.*\\$\\{LIST:([\\w_]+)\\}.*$');
                Matcher listMatcher = Pattern.compile('\\$\\{LIST:([\\w_]+)\\}').matcher(theMask);
                //system.assert(listMatcher.matches());
                
                while(listMatcher.find()){
                    String listName = listMatcher.group(1);
                     if(maskLists.containsKey(listName)){
                        String[] currList = maskLists.get(listName);
                        String currVal = currList.get(Integer.valueOf(Math.floor(Math.random()*currList.size())));
                         theMask = theMask.replaceAll('\\$\\{LIST:'+listName+'\\}',currVal);
                    }
            	}
            }

            if(theMask.indexOf('${INLINELIST')>-1){ // ${INLINELIST:mylist:<val1,val2,val3>}
                system.debug('in if');
                // Pattern listPattern = Pattern.compile('^.*\\$\\{LIST:([\\w_]+)\\}.*$');
                Matcher listMatcher = Pattern.compile('\\$\\{INLINELIST:(\\w+):<([\\w\\d,]+)>\\}').matcher(theMask);
                //system.assert(listMatcher.matches());
                
                while(listMatcher.find()){
                    String pattName = listMatcher.group(1);
                    String[] listvalues = listMatcher.group(2).split(',');
                    String currVal = listvalues.get(Integer.valueOf(Math.floor(Math.random()*listvalues.size())));
                    theMask = theMask.replaceAll('\\$\\{INLINELIST:'+pattName+':<[\\w\\d,]+>\\}',currVal);
            	}
            }

            if(theMask.indexOf('${NUMRANGE')>-1){   // ${NUMRANGE:myrange:50}
                system.debug('in if');
                // Pattern listPattern = Pattern.compile('^.*\\$\\{LIST:([\\w_]+)\\}.*$');
                Matcher listMatcher = Pattern.compile('\\$\\{NUMRANGE:(\\w+):([\\d]+)\\}').matcher(theMask);
                //system.assert(listMatcher.matches());
                
                while(listMatcher.find()){
                    String pattName = listMatcher.group(1);
                    Integer range = Integer.valueOf(listMatcher.group(2));
                    Integer randNum = Integer.valueOf(Math.Floor(Math.random()*range));
                    theMask = theMask.replaceAll('\\$\\{NUMRANGE:'+pattName+':[\\d]+\\}',String.valueOf(randNum));
            	}
            }
        }
        return theMask;
    }
}