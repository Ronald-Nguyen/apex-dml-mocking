@IsTest
private class RepoFactoryMockTest {
  @IsTest
  static void addsChildrenInMemory() {
    Account acc = new Account();
    String expectedOppName = 'Hello';
    List<SObject> opps = new List<Opportunity>{ new Opportunity(Name = expectedOppName) };
    
    Assert.areEqual(0, acc.Opportunities.size(), 'Test has started under the wrong conditions');

    acc = (Account) RepoFactoryMock.addChildrenToRecord(acc, Opportunity.AccountId, opps);

    Assert.areEqual(1, acc.Opportunities.size());
    Assert.areEqual(expectedOppName, acc.Opportunities.get(0).Name);
  }

  @IsTest
  static void addsMockCursor() {
    Account acc = new Account(Id = TestingUtils.generateId(Schema.Account.SObjectType));
    Account secondAccount = new Account(Id = TestingUtils.generateId(Schema.Account.SObjectType));
    RepoFactoryMock.CursorResults.put(
      Account.SObjectType,
      new List<Cursor>{ new RepoFactoryMock.CursorMock(new List<Account>{ acc, secondAccount }) }
    );

    RepoFactoryMock.FacadeMock facade = new RepoFactoryMock.FacadeMock();
    IHistoryRepository repo = facade.getRepo(
      Account.SObjectType,
      new List<Schema.SObjectField>(),
      new RepoFactoryMock()
    );
    Cursor cursor = repo.getCursor(new List<Query>());

    Assert.areEqual(2, cursor.getNumRecords());
    Assert.areEqual(acc.Id, cursor.fetch(0, 1)[0].Id);
    
    Assert.areEqual(secondAccount.Id, cursor.fetch(1, 3)[0].Id);
  }

  @IsTest
  static void mocksFacadeGetRepo() {
    RepoFactoryMock.FacadeMock facade = new RepoFactoryMock.FacadeMock();
    
    IHistoryRepository repo = facade.getRepo(
      Account.SObjectType,
      new List<Schema.SObjectField>{ Account.Name },
      new RepoFactoryMock()
    );
    
    Assert.isNotNull(repo);
  }

  @IsTest
  static void mocksQueryResults() {
    Account acc = new Account(Id = TestingUtils.generateId(Account.SObjectType), Name = 'TestAcc');
    RepoFactoryMock.QueryResults.put(Account.SObjectType, new List<Account>{ acc });
    
    RepoFactoryMock.FacadeMock facade = new RepoFactoryMock.FacadeMock();
    IRepository repo = facade.getRepo(
      Account.SObjectType,
      new List<Schema.SObjectField>{ Account.Name },
      new RepoFactoryMock()
    );
    
    List<Account> results = repo.getAll();
    
    Assert.areEqual(1, results.size());
    Assert.areEqual(acc.Id, results[0].Id);
  }

  @IsTest
  static void mocksAggregateResults() {
    AggregateRecord aggRecord = new AggregateRecord();
    aggRecord.put('total', 100);
    RepoFactoryMock.AggregateResults.put(Opportunity.SObjectType, new List<AggregateRecord>{ aggRecord });
    
    RepoFactoryMock.FacadeMock facade = new RepoFactoryMock.FacadeMock();
    IAggregateRepository repo = facade.getRepo(
      Opportunity.SObjectType,
      new List<Schema.SObjectField>{ Opportunity.Amount },
      new RepoFactoryMock()
    );
    
    List<AggregateRecord> results = repo.aggregate(Aggregation.sum(Opportunity.Amount, 'total'));
    
    Assert.areEqual(1, results.size());
    Assert.areEqual(100, results[0].get('total'));
  }

  @IsTest
  static void mocksHistoryResults() {
    FieldLevelHistory history = new FieldLevelHistory();
    history.setValues(new Map<String, Object>{ 'Field' => 'Amount', 'OldValue' => 100, 'NewValue' => 200 });
    RepoFactoryMock.HistoryResults.put(OpportunityFieldHistory.SObjectType, new List<FieldLevelHistory>{ history });
    
    RepoFactoryMock.FacadeMock facade = new RepoFactoryMock.FacadeMock();
    IHistoryRepository repo = facade.getRepo(
      OpportunityFieldHistory.SObjectType,
      new List<Schema.SObjectField>(),
      new RepoFactoryMock()
    );
    repo.setParentField(OpportunityFieldHistory.OpportunityId);
    
    List<FieldLevelHistory> results = repo.getAllHistory();
    
    Assert.areEqual(1, results.size());
    Assert.areEqual('Amount', results[0].get('Field'));
  }

  @IsTest
  static void handlesCursorMockFetch() {
    List<Account> accounts = new List<Account>{
      new Account(Id = TestingUtils.generateId(Account.SObjectType)),
      new Account(Id = TestingUtils.generateId(Account.SObjectType)),
      new Account(Id = TestingUtils.generateId(Account.SObjectType))
    };
    
    RepoFactoryMock.CursorMock cursor = new RepoFactoryMock.CursorMock(accounts);
    
    Assert.areEqual(3, cursor.getNumRecords());
    Assert.areEqual(2, cursor.fetch(1, 2).size());
  }
}
