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
  static void loadsMultipleDifferentInstances() {
    loadCounter = 0;
    ExtendedLazyFactory factory = new ExtendedLazyFactory();
    
    Example example = (Example) factory.example;
    AnotherExample another = (AnotherExample) factory.anotherExample;
    
    Assert.areEqual(1, loadCounter);
    Assert.isNotNull(example);
    Assert.isNotNull(another);
  }

  @IsTest
  static void handlesNullLoad() {
    ExtendedLazyFactory factory = new ExtendedLazyFactory();
    
    LazyFactory.Instance instance = factory.load(null);
    
    Assert.areEqual(null, instance);
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

  @IsTest
  static void handlesMultipleInstanceTypes() {
    loadCounter = 0;
    ExtendedLazyFactory factory = new ExtendedLazyFactory();
    
    Example example = (Example) factory.example;
    AnotherExample another = (AnotherExample) factory.anotherExample;
    Example exampleAgain = (Example) factory.example;
    
    Assert.areEqual(1, loadCounter);
    Assert.areEqual(example, exampleAgain);
  }

  @IsTest
  static void instanceIsInitializedOnlyOnce() {
    loadCounter = 0;
    ExtendedLazyFactory factory = new ExtendedLazyFactory();
    
    Boolean isNull = factory.example == null;
    Assert.areEqual(false, isNull);
    Assert.areEqual(1, loadCounter);
  }

  private class ExtendedLazyFactory extends LazyFactory {
    public Instance example {
      get {
        return this.load(Example.class);
      }
    }

    public Instance anotherExample {
      get {
        return this.load(AnotherExample.class);
      }
    }
  }

  private class Example implements LazyFactory.Instance {
    public Example() {
      loadCounter++;
    }
  }

  private class AnotherExample implements LazyFactory.Instance {
    public AnotherExample() {
    }
  }
}
