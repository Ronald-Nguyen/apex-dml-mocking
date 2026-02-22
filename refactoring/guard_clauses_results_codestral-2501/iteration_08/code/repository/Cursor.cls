public virtual without sharing class Cursor {
  public static final Integer MAX_FETCH_SIZE {
    get {
      MAX_FETCH_SIZE = MAX_FETCH_SIZE ?? maxRecordsPerFetchCall;
      return MAX_FETCH_SIZE;
    }
    private set;
  }

  private static final Integer MAX_FETCHES_PER_TRANSACTION = Limits.getLimitFetchCallsOnApexCursor();

  @TestVisible
  private static Integer maxRecordsPerFetchCall = 2000;

  @TestVisible
  private static Integer localFetchesMade;

  private Integer cursorNumRecords;
  private Integer fetchesPerTransaction = MAX_FETCHES_PER_TRANSACTION;
  private final Database.Cursor cursor;

  public Cursor(String finalQuery, Map<String, Object> bindVars, System.AccessLevel accessLevel) {
    try {
      this.cursor = Database.getCursorWithBinds(finalQuery, bindVars, accessLevel);
    } catch (FatalCursorException e) {
      System.debug(
        System.LoggingLevel.WARN,
        'Error creating cursor. This can happen if there are no records returned by the query: ' + e.getMessage()
      );
    }
  }

  public Cursor setFetchesPerTransaction(Integer possibleFetchesPerTransaction) {

    // Guard Clause 1: Handle zero fetches per transaction
    if (possibleFetchesPerTransaction == 0) {
      return this;
    }

    // Guard Clause 2: Handle exceeding max fetches per transaction
    if (possibleFetchesPerTransaction > MAX_FETCHES_PER_TRANSACTION) {
      System.debug(
        System.LoggingLevel.DEBUG,
        'Fetches per transaction: ' +
          possibleFetchesPerTransaction +
          ' exceeded platform max fetches per transaction: ' +
          MAX_FETCHES_PER_TRANSACTION +
          ', defaulting to platform max'
      );
      possibleFetchesPerTransaction = MAX_FETCHES_PER_TRANSACTION;
    }

    // Happy Path: Set fetches per transaction
    this.fetchesPerTransaction = possibleFetchesPerTransaction;
    return this;
  }

  @SuppressWarnings('PMD.EmptyStatementBlock')
  protected Cursor() {
  }

  public virtual List<SObject> fetch(Integer start, Integer advanceBy) {
    // Guard Clause 1: Handle no records to fetch
    if (this.getNumRecords() == 0) {
      System.debug(System.LoggingLevel.DEBUG, 'Bypassing fetch call, no records to fetch');
      return new List<SObject>();
    }

    localFetchesMade = localFetchesMade ?? 0;
    Integer localStart = start;
    List<SObject> results = new List<SObject>();

    // Main loop with guard clauses
    while (true) {
      // Guard Clause 2: Check if we've reached the maximum fetches per transaction
      if (localFetchesMade >= this.fetchesPerTransaction) {
        break;
      }

      // Guard Clause 3: Check if we've fetched all records
      if (results.size() >= this.getNumRecords()) {
        break;
      }

      // Guard Clause 4: Check if we've reached the end of the requested range
      if (localStart >= start + advanceBy) {
        break;
      }

      // Happy Path: Perform the fetch
      Integer actualAdvanceBy = this.getAdvanceBy(localStart, advanceBy);
      results.addAll(this.cursor?.fetch(localStart, actualAdvanceBy) ?? new List<SObject>());
      localStart += actualAdvanceBy;
      localFetchesMade++;
    }

    return results;
  }

  public virtual Integer getNumRecords() {
    this.cursorNumRecords = this.cursorNumRecords ?? this.cursor?.getNumRecords() ?? 0;
    return this.cursorNumRecords;
  }

  protected Integer getAdvanceBy(Integer start, Integer advanceBy) {
    Integer possibleFetchSize = Math.min(advanceBy, this.getNumRecords() - start);

    // Guard Clause 1: Handle exceeding max fetch size
    if (possibleFetchSize > maxRecordsPerFetchCall) {
      System.debug(
        System.LoggingLevel.DEBUG,
        'Fetch size: ' +
          possibleFetchSize +
          ' exceeded platform max fetch size of ' +
          maxRecordsPerFetchCall +
          ', defaulting to max fetch size'
      );
      possibleFetchSize = maxRecordsPerFetchCall;
    }

    // Guard Clause 2: Handle negative fetch size
    if (possibleFetchSize < 0) {
      possibleFetchSize = 0;
    }

    return possibleFetchSize;
  }
}