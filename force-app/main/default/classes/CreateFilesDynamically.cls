public class CreateFilesDynamically {
    /** This method will support creation of files in BULK */
    public static void createFilesinBulk(string recordId, string lstFilesData){
        List<FileDataWrap> files = (List<FileDataWrap>) JSON.deserialize(lstFilesData, List<FileDataWrap>.class);
        List<ContentVersion> cvList = new List<ContentVersion>();
        for(FileDataWrap file : files) {
            system.debug('file'+file.fileContent);
            ContentVersion conVer = new ContentVersion();
            conVer.VersionData = EncodingUtil.base64Decode(file.fileContent);
            conVer.Title = file.fileName;
            conVer.PathOnClient = file.fileName;
            cvList.add(conVer);
        }
        Insert cvList;

        List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
        for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cvList]) {
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = recordId;
            conDocLink.ContentDocumentId = cv.ContentDocumentId;
            conDocLink.Visibility = 'AllUsers';
            conDocLink.shareType = 'V';
            cdList.add(conDocLink);
        }
        Insert cdList;    
    }

    /** This method will support creation of a single file - Start*/
    public static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    @TestVisible 
    public static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
        SELECT ContentDocumentId 
        FROM ContentVersion 
        WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    /** This method will support creation of a single file - End*/

    public class FileDataWrap {
        public String fileName;
        public String fileContent;
    }
}