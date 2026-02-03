@IsTest
private class LazyFactoryTest {
  private static Integer loadCounter = 0;

  @IsTest
  static void properlyCachesLazyLoadedInstances() {
    ExtendedLazyFactory extendedExampleFactory = new ExtendedLazyFactory();

    Example firstExample = (Example) extendedExampleFactory.example;
    Example secondExample = (Example) extendedExampleFactory.example;

    Assert.areEqual(1, loadCounter);
    
    
    Assert.areEqual(firstExample, secondExample);
  }

  private class ExtendedLazyFactory extends LazyFactory {
    public Instance example {
      get {
        return this.load(Example.class);
      }
    }
  }

  private class Example implements LazyFactory.Instance {
    public Example() {
      loadCounter++;
    }
  }
}
