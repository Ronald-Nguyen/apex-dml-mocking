public virtual class Factory {
  public final RepoFactory repoFactory = new RepoFactory();

  @TestVisible
  private static Factory factory;

  @SuppressWarnings('PMD.EmptyStatementBlock')
  protected Factory() {
  }

  public static Factory getFactory() {
    if (factory == null) {
      factory = new Factory();
    }
    return factory;
  }

  @TestVisible
  private Factory withMocks {
    get {
      this.repoFactory.setFacade(new RepoFactoryMock.FacadeMock());
      return this;
    }
  }
}