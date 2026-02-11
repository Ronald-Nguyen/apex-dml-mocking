@IsTest
private class FieldLevelHistoryRepoTest {
  @IsTest
  static void itShouldContinueToActAsBaseRepo() {
    IHistoryRepository historyRepo = new FieldLevelHistoryRepoTest.ExampleRepoFactory().getOppFieldHistoryRepo();

    List<OpportunityFieldHistory> histories = historyRepo.get(
      Query.equals(OpportunityFieldHistory.OpportunityId, null)
    );

    Assert.areNotEqual(null, histories);
  }

  @IsTest
  static void itShouldContinueToActAsAggregateRepo() {
    Aggregation count = Aggregation.count(OpportunityFieldHistory.Id, 'countId');
    IAggregateRepository repo = new FieldLevelHistoryRepoTest.ExampleRepoFactory().getOppFieldHistoryRepo();
    repo.groupBy(OpportunityFieldHistory.OpportunityId);

    List<AggregateRecord> records = repo.aggregate(count);

    
    Assert.areEqual(true, records.isEmpty());
  }

  @IsTest
  static void itShouldQueryHistoryRecords() {
    IHistoryRepository historyRepo = new FieldLevelHistoryRepoTest.ExampleRepoFactory().getOppFieldHistoryRepo();

    List<FieldLevelHistory> histories = historyRepo.getAllHistory();
    
    
    Assert.areEqual(true, histories.isEmpty());
  }

  @IsTest
  static void itShouldAllowMockingOfHistoryRecords() {
    FieldLevelHistory mockRecord = new FieldLevelHistory();
    mockRecord.setValues(
      new Map<String, Object>{
        'CreatedDate' => System.now(),
        'Id' => TestingUtils.generateId(OpportunityFieldHistory.SObjectType),
        'Field' => 'Amount',
        'OldValue' => 0,
        'NewValue' => 1,
        'OpportunityId' => TestingUtils.generateId(Opportunity.SObjectType)
      }
    );
    RepoFactoryMock.HistoryResults.put(OpportunityFieldHistory.SObjectType, new List<FieldLevelHistory>{ mockRecord });

    IHistoryRepository historyRepo = new FieldLevelHistoryRepoTest.ExampleRepoFactory().getOppFieldHistoryRepo();

    List<FieldLevelHistory> histories = historyRepo.getAllHistory();
    Assert.areNotEqual(true, histories.isEmpty());
    Assert.areEqual(mockRecord, histories[0]);
  }

  private without sharing class ExampleRepoFactory extends RepoFactory {
    private ExampleRepoFactory() {
      this.facade = new RepoFactoryMock.FacadeMock();
    }

    public IAggregateRepository getOppRepo() {
      List<Schema.SObjectField> queryFields = new List<Schema.SObjectField>{
        Opportunity.IsWon,
        Opportunity.StageName
        
      };
      IAggregateRepository oppRepo = this.facade.getRepo(Opportunity.SObjectType, queryFields, this);
      oppRepo.addParentFields(
        new List<Schema.SObjectField>{ Opportunity.AccountId },
        new List<Schema.SObjectField>{ Account.Id }
      );
      return oppRepo;
    }

    public IHistoryRepository getOppFieldHistoryRepo() {
      return this.facade.getRepo(OpportunityFieldHistory.SObjectType, new List<Schema.SObjectField>(), this)
        .setParentField(OpportunityFieldHistory.OpportunityId);
    }
  }

  @IsTest
  static void itShouldGetHistoryByParentId() {
    Opportunity opp = new Opportunity(Name = 'Test', StageName = 'Prospecting', CloseDate = System.today());
    insert opp;
    
    IHistoryRepository historyRepo = new FieldLevelHistoryRepoTest.ExampleRepoFactory().getOppFieldHistoryRepo();
    List<FieldLevelHistory> histories = historyRepo.getHistoryByParentId(opp.Id);
    
    Assert.isNotNull(histories);
  }

  @IsTest
  static void itShouldGetHistoryByParentIds() {
    List<Opportunity> opps = new List<Opportunity>{
      new Opportunity(Name = 'Test1', StageName = 'Prospecting', CloseDate = System.today()),
      new Opportunity(Name = 'Test2', StageName = 'Prospecting', CloseDate = System.today())
    };
    insert opps;
    
    Set<Id> oppIds = new Set<Id>();
    for (Opportunity opp : opps) {
      oppIds.add(opp.Id);
    }
    
    IHistoryRepository historyRepo = new FieldLevelHistoryRepoTest.ExampleRepoFactory().getOppFieldHistoryRepo();
    List<FieldLevelHistory> histories = historyRepo.getHistoryByParentIds(oppIds);
    
    Assert.isNotNull(histories);
  }

  @IsTest
  static void itShouldGetHistoryForSpecificField() {
    Opportunity opp = new Opportunity(Name = 'Test', StageName = 'Prospecting', CloseDate = System.today(), Amount = 1000);
    insert opp;
    
    opp.Amount = 2000;
    update opp;
    
    IHistoryRepository historyRepo = new FieldLevelHistoryRepoTest.ExampleRepoFactory().getOppFieldHistoryRepo();
    List<FieldLevelHistory> histories = historyRepo.getHistoryByParentIdAndField(opp.Id, 'Amount');
    
    Assert.isNotNull(histories);
  }

  @IsTest
  static void itShouldHandleFieldLevelHistoryValues() {
    FieldLevelHistory history = new FieldLevelHistory();
    history.setValues(new Map<String, Object>{
      'Field' => 'Amount',
      'OldValue' => 100,
      'NewValue' => 200
    });
    
    Assert.areEqual('Amount', history.get('Field'));
    Assert.areEqual(100, history.get('OldValue'));
    Assert.areEqual(200, history.get('NewValue'));
  }

  @IsTest
  static void itShouldCreateFieldLevelHistoryWithConstructor() {
    Map<String, Object> values = new Map<String, Object>{
      'Id' => TestingUtils.generateId(OpportunityFieldHistory.SObjectType),
      'Field' => 'StageName',
      'OldValue' => 'Prospecting',
      'NewValue' => 'Qualification'
    };
    
    FieldLevelHistory history = new FieldLevelHistory(values);
    
    Assert.areEqual('StageName', history.get('Field'));
    Assert.areEqual('Prospecting', history.get('OldValue'));
    Assert.areEqual('Qualification', history.get('NewValue'));
  }

  @IsTest
  static void itShouldHandleEmptyHistoryResults() {
    IHistoryRepository historyRepo = new FieldLevelHistoryRepoTest.ExampleRepoFactory().getOppFieldHistoryRepo();
    Id fakeId = TestingUtils.generateId(Opportunity.SObjectType);
    
    List<FieldLevelHistory> histories = historyRepo.getHistoryByParentId(fakeId);
    
    Assert.isNotNull(histories);
  }

  @IsTest
  static void itShouldAllowQueryingWithDateRange() {
    IHistoryRepository historyRepo = new FieldLevelHistoryRepoTest.ExampleRepoFactory().getOppFieldHistoryRepo();
    DateTime startDate = DateTime.now().addDays(-7);
    DateTime endDate = DateTime.now();
    
    List<FieldLevelHistory> histories = historyRepo.get(
      new List<Query>{
        Query.greaterThanOrEqual(OpportunityFieldHistory.CreatedDate, startDate),
        Query.lessThanOrEqual(OpportunityFieldHistory.CreatedDate, endDate)
      }
    );
    
    Assert.isNotNull(histories);
  }
}
