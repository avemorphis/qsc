public class AskQuestion {
	
    @AuraEnabled
    public static List<Knowledge__kav> getKnowledgeInfo(String strMsg)
    {
        system.debug('strMsg '+strMsg);
        List<String> splitData = strMsg.split(':');
        List<String> splitData1 = splitData[1].split('"');
        system.debug('splitData[1]  '+splitData[1]);
        system.debug('splitData1  '+splitData1);
        //strMsg = splitData[1].replaceAll('[^a-zA-Z0-9\\s+]', '');
        String strSearch = splitData1[1];
        system.debug('strSearch  '+strSearch);
        Id rectype = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('FAQ').getRecordTypeId();
        String newSearchText = '%'+strSearch+'%';
        List<Knowledge__kav> knowledgeList = [SELECT Id, Title, RecordTypeId, LastPublishedDate FROM Knowledge__kav
                                             where RecordTypeId =: rectype AND Title LIKE: newSearchText ORDER BY createddate DESC LIMIT 6 ];
        return knowledgeList;
    }
}