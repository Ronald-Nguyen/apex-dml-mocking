@IsTest
private class SObjectRepositoryTest {
  @IsTest
  static void queriesWithGenericRepo() {
    Account acc = new Account(Name = SObjectRepositoryTest.class.getName() + System.now().getTime());
    insert acc;

    List<SObject> results = new SObjectRepository(
        Schema.Account.SObjectType,
        new List<Schema.SObjectField>(),
        new RepoFactory()
      )
      .getAll();

    Assert.areEqual(1, results.size());
    Assert.areEqual(acc.Id, results[0].Id);
  }

  @IsTest
  static void queriesWithSpecificFields() {
    Account acc = new Account(Name = 'TestAccount', Industry = 'Technology');
    insert acc;

    List<SObject> results = new SObjectRepository(
        Schema.Account.SObjectType,
        new List<Schema.SObjectField>{ Account.Name, Account.Industry },
        new RepoFactory()
      )
      .get(Query.equals(Account.Name, 'TestAccount'));

    Assert.areEqual(1, results.size());
    Assert.areEqual(acc.Id, results[0].Id);
  }

  @IsTest
  static void handlesEmptyResults() {
    List<SObject> results = new SObjectRepository(
        Schema.Account.SObjectType,
        new List<Schema.SObjectField>{ Account.Name },
        new RepoFactory()
      )
      .get(Query.equals(Account.Name, 'NonExistentAccount'));

    Assert.areEqual(0, results.size());
  }

  @IsTest
  static void supportsLimitOnQuery() {
    insert new List<Account>{
      new Account(Name = 'Test1'),
      new Account(Name = 'Test2'),
      new Account(Name = 'Test3')
    };

    List<SObject> results = new SObjectRepository(
        Schema.Account.SObjectType,
        new List<Schema.SObjectField>{ Account.Name },
        new RepoFactory()
      )
      .setLimit(2)
      .getAll();

    Assert.areEqual(2, results.size());
  }
}
