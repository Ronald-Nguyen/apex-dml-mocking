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
}
