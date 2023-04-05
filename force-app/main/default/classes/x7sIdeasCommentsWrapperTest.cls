/*
 * Copyright (c) 2021. 7Summits Inc.
 */


@IsTest
private class x7sIdeasCommentsWrapperTest {
	@IsTest
	static void testWrapper() {
		x7sIdeasCommentsWrapper.CommentsModel commentModel = new x7sIdeasCommentsWrapper.CommentsModel();
		commentModel.newStatus = '';
		commentModel.changedBy = '';
		commentModel.changedById = '';
		commentModel.changedDate = Date.today();
		commentModel.commentText = '';

		System.assertNotEquals(null, commentModel);
	}
}