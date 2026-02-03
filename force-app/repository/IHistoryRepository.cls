public interface IHistoryRepository extends IAggregateRepository {
  
  
  List<FieldLevelHistory> getHistory(Query query);
  List<FieldLevelHistory> getHistory(List<Query> queries);
  List<FieldLevelHistory> getAllHistory();

  
  
  IHistoryRepository setParentField(Schema.SObjectField parentField);
}
