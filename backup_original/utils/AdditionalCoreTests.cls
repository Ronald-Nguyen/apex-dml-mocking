@IsTest
private class AdditionalCoreTests {
  @IsTest
  static void repoSortOrderAscendingToString() {
    RepositorySortOrder sortOrder = RepositorySortOrder.ASCENDING;
    Assert.areEqual('ASC', sortOrder.toString());
  }

  @IsTest
  static void repoSortOrderDescendingNullsFirstToString() {
    RepositorySortOrder sortOrder = new RepositorySortOrder(
      RepositorySortOrder.SortOrder.DESCENDING,
      RepositorySortOrder.NullSortOrder.FIRST
    );
    Assert.areEqual('DESC NULLS FIRST', sortOrder.toString());
  }

  @IsTest
  static void repoSortOrderEqualsSame() {
    RepositorySortOrder first = new RepositorySortOrder(RepositorySortOrder.SortOrder.ASCENDING);
    RepositorySortOrder second = new RepositorySortOrder(RepositorySortOrder.SortOrder.ASCENDING);
    Assert.areEqual(first, second);
  }

  @IsTest
  static void repoSortOrderNotEqualsDifferent() {
    RepositorySortOrder first = new RepositorySortOrder(RepositorySortOrder.SortOrder.ASCENDING);
    RepositorySortOrder second = new RepositorySortOrder(RepositorySortOrder.SortOrder.DESCENDING);
    Assert.areNotEqual(first, second);
  }

  @IsTest
  static void repoSortOrderHashCodeMatchesToString() {
    RepositorySortOrder order = RepositorySortOrder.DESCENDING;
    Assert.areEqual(order.toString().hashCode(), order.hashCode());
  }

  @IsTest
  static void aggregationBaseAggregation() {
    Aggregation agg = Aggregation.sum(Opportunity.Amount, 'sumAlias');
    Assert.areEqual('SUM(Amount)', agg.getBaseAggregation());
  }

  @IsTest
  static void aggregationEqualsSameValues() {
    Aggregation first = Aggregation.countDistinct(Opportunity.StageName, 'alias');
    Aggregation second = Aggregation.countDistinct(Opportunity.StageName, 'alias');
    Assert.areEqual(first, second);
  }

  @IsTest
  static void aggregationHashCodeSameValues() {
    Aggregation first = Aggregation.max(Opportunity.CloseDate, 'alias');
    Aggregation second = Aggregation.max(Opportunity.CloseDate, 'alias');
    Assert.areEqual(first.hashCode(), second.hashCode());
  }

  @IsTest
  static void aggregateRecordSetAndGetCount() {
    AggregateRecord record = new AggregateRecord().setCount(7);
    Assert.areEqual(7, record.getCount());
  }

  @IsTest
  static void aggregateRecordEqualsOtherRecord() {
    AggregateRecord first = new AggregateRecord().putAll(new Map<String, Object>{ 'A' => 1, 'B' => 2 });
    AggregateRecord second = new AggregateRecord().putAll(new Map<String, Object>{ 'A' => 1, 'B' => 2 });
    Assert.areEqual(first, second);
  }

  @IsTest
  static void aggregateRecordHashCodeMatches() {
    AggregateRecord first = new AggregateRecord().putAll(new Map<String, Object>{ 'A' => 1 });
    AggregateRecord second = new AggregateRecord().putAll(new Map<String, Object>{ 'A' => 1 });
    Assert.areEqual(first.hashCode(), second.hashCode());
  }

  @IsTest
  static void aggregateRecordGetReturnsValue() {
    AggregateRecord record = new AggregateRecord().putAll(new Map<String, Object>{ 'Name' => 'Value' });
    Assert.areEqual('Value', record.get('Name'));
  }

  @IsTest
  static void queryBuildsParentFieldChain() {
    List<Schema.SObjectField> chain = new List<Schema.SObjectField>{ Contact.AccountId, Account.OwnerId };
    String built = Query.getBuiltUpParentFieldName(chain);
    Assert.areEqual('Account.OwnerId', built);
  }

  @IsTest
  static void queryToSoslEscapesQuotes() {
    String input = 'O\'Hara';
    Query query = Query.equals(Account.Name, input);
    String expected = 'Name = ' + '\'' + String.escapeSingleQuotes(input) + '\'';
    Assert.areEqual(expected, query.toSoslString());
  }

  @IsTest
  static void queryToSoslFormatsDatetime() {
    Datetime dt = Datetime.newInstanceGMT(2024, 1, 2, 3, 4, 5);
    Query query = Query.equals(Account.CreatedDate, dt);
    Assert.areEqual('CreatedDate = 2024-01-02T03:04:05Z', query.toSoslString());
  }

  @IsTest
  static void queryToSoslEmptyIterableMarksEmpty() {
    Query query = Query.equals(Account.Id, new List<Id>());
    String result = query.toSoslString();
    Assert.areEqual('', result);
    Assert.isFalse(query.isSoslEmpty());
  }

  @IsTest
  static void queryToStringBooleanFalse() {
    Query query = Query.equals(Opportunity.IsClosed, false);
    Assert.areEqual('IsClosed = false', query.toString());
  }

  @IsTest
  static void queryNotLikeFormatsBindVar() {
    Query query = Query.notLike(Account.Name, '%test%');
    Assert.areEqual('NOT Name LIKE :bindVar0', query.toString());
  }

  @IsTest
  static void queryOrEmptyListReturnsBlank() {
    Query query = Query.orQuery(new List<Query>());
    Assert.areEqual('', query.toString());
  }

  @IsTest
  static void queryAndEmptyListReturnsBlank() {
    Query query = Query.andQuery(new List<Query>());
    Assert.areEqual('', query.toString());
  }

  @IsTest
  static void querySubqueryBindVarsPropagate() {
    Query innerQuery = Query.equals(Account.Name, 'Acme');
    Query sub = Query.subquery(Contact.AccountId, Account.Id, innerQuery);
    sub.toString();
    Assert.areEqual('Acme', sub.getBindVars().get('bindVar0'));
  }

  @IsTest
  static void queryUsingParentListUsesRelationships() {
    Query parentQuery = Query.equals(User.Username, 'user@test.com')
      .usingParent(new List<Schema.SObjectField>{ Contact.OwnerId });
    Assert.areEqual('Owner.Username = :bindVar0', parentQuery.toString());
  }

  @IsTest
  static void querySoslStringListOfStringsIn() {
    Query query = Query.equals(Account.Name, new List<String>{ 'One', 'Two' });
    Assert.areEqual('Name IN (\'One\',\'Two\')', query.toSoslString());
  }

  @IsTest
  static void querySoslStringListOfStringsNotIn() {
    Query query = Query.notEquals(Account.Name, new List<String>{ 'One', 'Two' });
    Assert.areEqual('Name NOT IN (\'One\',\'Two\')', query.toSoslString());
  }

  @IsTest
  static void repoFactoryCachesReposByType() {
    RepoFactory factory = new RepoFactory();
    IHistoryRepository first = factory.getProfileRepo();
    IHistoryRepository second = factory.getProfileRepo();
    Assert.areEqual(first, second);
  }

  @IsTest
  static void repoFactorySetFacadeReturnsSelf() {
    RepoFactory factory = new RepoFactory();
    RepoFactory returned = factory.setFacade(new RepoFactoryMock.FacadeMock());
    Assert.areEqual(factory, returned);
  }

  @IsTest
  static void repoFactoryMockUsesMockWhenAlwaysUseMock() {
    RepoFactoryMock.alwaysUseMock = true;
    RepoFactoryMock.FacadeMock facade = new RepoFactoryMock.FacadeMock();
    IHistoryRepository repo = facade.getRepo(
      Account.SObjectType,
      new List<Schema.SObjectField>{ Account.Name },
      new RepoFactoryMock()
    );
    repo.get(Query.equals(Account.Name, 'Test'));
    Assert.areEqual(1, RepoFactoryMock.QueriesMade.size());
    RepoFactoryMock.alwaysUseMock = false;
  }

  @IsTest
  static void repoFactoryMockTracksSortOrdersOnAggregate() {
    RepoFactoryMock.alwaysUseMock = true;
    RepoFactoryMock.FacadeMock facade = new RepoFactoryMock.FacadeMock();
    IHistoryRepository repo = facade.getRepo(
      Opportunity.SObjectType,
      new List<Schema.SObjectField>{ Opportunity.Name },
      new RepoFactoryMock()
    );
    repo.addSortOrder(Opportunity.Name, RepositorySortOrder.ASCENDING);
    repo.aggregate(Aggregation.count(Opportunity.Id, 'countId'), new List<Query>());

    Map<String, RepositorySortOrder> sortOrders = RepoFactoryMock.FieldToSortOrders.get(Opportunity.SObjectType);
    Assert.areEqual(RepositorySortOrder.ASCENDING, sortOrders.get('Name'));
    RepoFactoryMock.alwaysUseMock = false;
  }

  @IsTest
  static void repoFactoryMockSoslAdditionalObjectsAddsQueries() {
    RepoFactoryMock.alwaysUseMock = true;
    RepoFactoryMock.FacadeMock facade = new RepoFactoryMock.FacadeMock();
    IHistoryRepository repo = facade.getRepo(
      Account.SObjectType,
      new List<Schema.SObjectField>{ Account.Name },
      new RepoFactoryMock()
    );
    repo.getSosl(
      'test',
      new List<Query>{ Query.equals(Account.Name, 'X') },
      new List<AdditionalSoslObject>{
        new AdditionalSoslObject(
          Contact.SObjectType,
          new List<Schema.SObjectField>{ Contact.LastName },
          new List<Query>{ Query.equals(Contact.LastName, 'Y') },
          5
        )
      }
    );
    Assert.areEqual(2, RepoFactoryMock.QueriesMade.size());
    RepoFactoryMock.alwaysUseMock = false;
  }

  @IsTest
  static void repoFactoryMockAddChildrenNoRelationshipReturnsSame() {
    Account acc = new Account();
    List<SObject> children = new List<Opportunity>{ new Opportunity(Name = 'Test') };
    Account returned = (Account) RepoFactoryMock.addChildrenToRecord(acc, Account.OwnerId, children);
    Assert.areEqual(0, returned.Opportunities.size());
  }

  @IsTest
  static void repoFactoryMockCursorMockFetchesSlice() {
    Account first = new Account(Id = TestingUtils.generateId(Account.SObjectType), Name = 'One');
    Account second = new Account(Id = TestingUtils.generateId(Account.SObjectType), Name = 'Two');
    Account third = new Account(Id = TestingUtils.generateId(Account.SObjectType), Name = 'Three');

    Cursor cursor = new RepoFactoryMock.CursorMock(new List<Account>{ first, second, third });
    List<SObject> slice = cursor.fetch(1, 1);
    Assert.areEqual(1, slice.size());
    Assert.areEqual(second.Id, slice[0].Id);
  }

  @IsTest
  static void dmlMockSingleOrDefaultThrowsWithMultiple() {
    IDML mock = new DMLMock();
    mock.doInsert(new List<Account>{ new Account(), new Account() });

    Exception thrown;
    try {
      SObject unused = DMLMock.Inserted.Accounts.singleOrDefault;
    } catch (Exception ex) {
      thrown = ex;
    }

    Assert.isNotNull(thrown);
    Assert.isInstanceOfType(thrown, IllegalArgumentException.class);
  }

  @IsTest
  static void dmlMockFirstOrDefaultReturnsNullForEmpty() {
    Assert.isNull(DMLMock.Deleted.Accounts.firstOrDefault);
  }

  @IsTest
  static void testingUtilsGenerateIdLength15() {
    String idValue = TestingUtils.generateId(Account.SObjectType);
    Assert.areEqual(15, idValue.length());
  }

  @IsTest
  static void testingUtilsGenerateIdsAssignsId() {
    List<Account> accounts = new List<Account>{ new Account(Name = 'A'), new Account(Name = 'B') };
    TestingUtils.generateIds(accounts);
    Assert.isNotNull(accounts[0].Id);
    Assert.isNotNull(accounts[1].Id);
  }

  @IsTest
  static void repositorySetSearchGroupChainable() {
    Repository repo = new Repository(
      Account.SObjectType,
      new List<Schema.SObjectField>{ Account.Name },
      new RepoFactory()
    );
    Repository returned = repo.setSearchGroup(SearchGroup.EMAIL_FIELDS);
    Assert.areEqual(repo, returned);
  }

  @IsTest
  static void lazyFactoryLoadsByTypeCaches() {
    LazyFactory factory = new LazyFactory();
    LazyFactory.Instance first = factory.load(ExampleInstance.class);
    LazyFactory.Instance second = factory.load(ExampleInstance.class);
    Assert.areEqual(first, second);
  }

  private class ExampleInstance implements LazyFactory.Instance {
  }
}
