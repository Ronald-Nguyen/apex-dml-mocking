@IsTest
private class AggregationTest {
  @IsTest
  static void shouldCorrectlyFormatSum() {
    String expectedAlias = 'myAlias';
    Aggregation agg = Aggregation.sum(Opportunity.Amount, expectedAlias);
    Assert.areEqual('SUM(Amount) myAlias', agg.toString());
    Assert.areEqual(expectedAlias, agg.getAlias());
  }

  @IsTest
  static void shouldCorrectlyFormatCountDistinct() {
    String expectedAlias = 'myAlias';
    Aggregation agg = Aggregation.countDistinct(Opportunity.StageName, expectedAlias);
    Assert.areEqual('COUNT_DISTINCT(StageName) myAlias', agg.toString());
    Assert.areEqual(expectedAlias, agg.getAlias());
  }

  @IsTest
  static void shouldCorrectlyFormatCount() {
    String expectedAlias = 'totalCount';
    Aggregation agg = Aggregation.count(Opportunity.Id, expectedAlias);
    Assert.areEqual('COUNT(Id) totalCount', agg.toString());
    Assert.areEqual(expectedAlias, agg.getAlias());
  }

  @IsTest
  static void shouldCorrectlyFormatAverage() {
    String expectedAlias = 'avgAmount';
    Aggregation agg = Aggregation.average(Opportunity.Amount, expectedAlias);
    Assert.areEqual('AVG(Amount) avgAmount', agg.toString());
    Assert.areEqual(expectedAlias, agg.getAlias());
  }

  @IsTest
  static void shouldCorrectlyFormatMin() {
    String expectedAlias = 'minAmount';
    Aggregation agg = Aggregation.min(Opportunity.Amount, expectedAlias);
    Assert.areEqual('MIN(Amount) minAmount', agg.toString());
    Assert.areEqual(expectedAlias, agg.getAlias());
  }

  @IsTest
  static void shouldCorrectlyFormatMax() {
    String expectedAlias = 'maxAmount';
    Aggregation agg = Aggregation.max(Opportunity.Amount, expectedAlias);
    Assert.areEqual('MAX(Amount) maxAmount', agg.toString());
    Assert.areEqual(expectedAlias, agg.getAlias());
  }

  @IsTest
  static void shouldHandleAliasRetrieval() {
    Aggregation sumAgg = Aggregation.sum(Opportunity.Amount, 'total');
    Aggregation countAgg = Aggregation.count(Opportunity.Id, 'num');
    
    Assert.areEqual('total', sumAgg.getAlias());
    Assert.areEqual('num', countAgg.getAlias());
  }

  @IsTest
  static void shouldFormatDifferentFieldTypes() {
    Aggregation dateSum = Aggregation.sum(Opportunity.CloseDate, 'dateSum');
    Aggregation nameCount = Aggregation.count(Opportunity.Name, 'nameCount');
    
    Assert.isNotNull(dateSum.toString());
    Assert.isNotNull(nameCount.toString());
  }

  @IsTest
  static void shouldHandleCountId() {
    Aggregation countId = Aggregation.count(Opportunity.Id, 'idCount');
    Assert.areEqual('COUNT(Id) idCount', countId.toString());
  }

  @IsTest
  static void shouldHandleAggregationEquality() {
    Aggregation agg1 = Aggregation.sum(Opportunity.Amount, 'total');
    Aggregation agg2 = Aggregation.sum(Opportunity.Amount, 'total');
    
    Assert.areEqual(agg1.toString(), agg2.toString());
  }
}
