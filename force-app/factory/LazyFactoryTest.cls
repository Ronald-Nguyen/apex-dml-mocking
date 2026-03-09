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

  @IsTest
  static void cachesAcrossMultipleCalls() {
    loadCounter = 0;
    ExtendedLazyFactory factory = new ExtendedLazyFactory();
    
    for (Integer i = 0; i < 5; i++) {
      Example example = (Example) factory.example;
    }
    
    Assert.areEqual(1, loadCounter);
  }

  @IsTest
  static void differentFactoriesHaveSeparateCaches() {
    loadCounter = 0;
    ExtendedLazyFactory factory1 = new ExtendedLazyFactory();
    ExtendedLazyFactory factory2 = new ExtendedLazyFactory();
    
    Example example1 = (Example) factory1.example;
    Example example2 = (Example) factory2.example;
    
    Assert.areEqual(2, loadCounter);
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
