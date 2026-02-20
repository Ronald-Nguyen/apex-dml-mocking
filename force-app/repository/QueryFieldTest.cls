@IsTest
private class QueryFieldTest {
  @IsTest
  static void parentFieldChainsConcatenatedProperly() {
    QueryField queryField = new QueryField(
      new List<Schema.SObjectField>{ Contact.AccountId, Account.OwnerId },
      new List<Schema.SObjectField>{ User.Email }
    );

    Assert.areEqual('Account.Owner.Email', queryField.toString());
  }

  @IsTest
  static void concatenatesFieldsProperly() {
    QueryField queryField = new QueryField(new List<Schema.SObjectField>{ Contact.AccountId, Contact.LastName });

    Assert.areEqual('AccountId,LastName', queryField.toString());
  }

  @IsTest
  static void handlesSingleField() {
    QueryField queryField = new QueryField(Contact.FirstName);
    
    Assert.areEqual('FirstName', queryField.toString());
  }

  @IsTest
  static void handlesMultipleLevelsOfParentFields() {
    QueryField queryField = new QueryField(
      new List<Schema.SObjectField>{ OpportunityLineItem.OpportunityId, Opportunity.AccountId, Account.OwnerId },
      new List<Schema.SObjectField>{ User.Username }
    );
    
    Assert.areEqual('Opportunity.Account.Owner.Username', queryField.toString());
  }

  @IsTest
  static void handlesMultipleChildFields() {
    QueryField queryField = new QueryField(new List<Schema.SObjectField>{ 
      Contact.FirstName, 
      Contact.LastName, 
      Contact.Email 
    });
    
    Assert.areEqual('FirstName,LastName,Email', queryField.toString());
  }
}
