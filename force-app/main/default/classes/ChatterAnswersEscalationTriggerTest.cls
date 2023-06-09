@isTest
private class ChatterAnswersEscalationTriggerTest {
	static testMethod void validateQuestionEscalation() {
		String questionTitle = 'questionTitle';
		String questionBody = 'questionBody';

		Community[] c = [SELECT Id from Community];

		// We cannot create a question without a community
		if (c.size() == 0) { return; }
		String communityId = c[0].Id;

		//Create Question
		Question q = new Question();
			q.Title = questionTitle;
			q.Body = questionBody;
			q.CommunityId = communityId;
		insert(q);

		//Update Question
		q.Priority = 'high';
		update(q);

		//Check created Question
		List<Case> caseList = [SELECT Origin, CommunityId, Subject, Description from Case where QuestionId =: q.Id];
		if(caseList.size() > 0) {
			Case ca = caseList[0];
			// Test that escaltion trigger correctly escalate the question to a case
			System.assertEquals(questionTitle, ca.Subject);
			System.assertEquals(questionBody, ca.Description);
			System.assertEquals('Chatter Answers', ca.Origin);
			System.assertEquals(communityId, ca.CommunityId);
		}
	}
}