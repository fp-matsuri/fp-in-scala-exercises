mod FpInFlix.Exercises.ErrorHandling.TestEither {
    use Assert.assertEq
    // 解答例
    // use FpInFlix.Answers.ErrorHandling.Either.{Either, Left, Right}
    use FpInFlix.Exercises.ErrorHandling.Either.{Either, Left, Right}

    @Test
    def testMap(): Unit \ Assert =
        assertEq(expected = Right(21), Either.map(n -> n / 2, (Right(42): Either[String, Int32])));
        assertEq(expected = Left("error"), Either.map(n -> n / 2, Left("error")))

    @Test
    def testFlatMap(): Unit \ Assert =
        def f(n) =
            if (n `Int32.modulo` 2 == 0) Right(n / 2)
            else Left("An odd number");
        assertEq(expected = Right(21), Either.flatMap(f, Right(42)));
        assertEq(expected = Left("An odd number"), Either.flatMap(f, Right(43)));
        assertEq(expected = Left("error"), Either.flatMap(f, Left("error")))

    @Test
    def testOrElse(): Unit \ Assert =
        assertEq(expected = Right(42), Either.orElse((Right(42): Either[String, Int32]), Right(42)));
        assertEq(expected = Right(42), Either.orElse(Left("error"), Right(42)));
        assertEq(expected = Right(42), Either.orElse(Right(42), Left("error")));
        assertEq(
            expected = Left("error"),
            Either.orElse((Left("error"): Either[String, Int32]), Left("another error"))
        )

    mod Name {
        // 解答例
        // use FpInFlix.Answers.ErrorHandling.Either.{Either, Left, Right}
        use FpInFlix.Exercises.ErrorHandling.Either.{Either, Left, Right}

        enum Name(String) with Eq, ToString

        pub def make(name: String): Either[String, Name] =
            if (String.isEmpty(name)) Left("Name is empty.")
            else Right(Name(name))
    }

    mod Age {
        // 解答例
        // use FpInFlix.Answers.ErrorHandling.Either.{Either, Left, Right}
        use FpInFlix.Exercises.ErrorHandling.Either.{Either, Left, Right}

        enum Age(Int32) with Eq, ToString

        pub def make(age: Int32): Either[String, Age] =
            if (age < 0) Left("Age is out of range.")
            else Right(Age(age))
    }

    mod Person {
        // 解答例
        // use FpInFlix.Answers.ErrorHandling.Either.{Either, Left, Right}
        use FpInFlix.Exercises.ErrorHandling.Either.{Either, Left, Right}
        use FpInFlix.Exercises.ErrorHandling.TestEither.{Age, Name}

        enum Person(Name, Age) with Eq, ToString

        pub def make(name: String, age: Int32): Either[String, Person] =
            Either.map2(Person, Name.make(name), Age.make(age))
    }

    @Test
    def testMap2(): Unit \ Assert =
        assertEq(expected = Right(Person(Name("Alice"), Age(20))), Person.make("Alice", 20));
        assertEq(expected = Left("Name is empty."), Person.make("", 20));
        assertEq(expected = Left("Age is out of range."), Person.make("Alice", -1));
        assertEq(expected = Left("Name is empty."), Person.make("", -1))

    @Test
    def testTraverse(): Unit \ Assert =
        assertEq(
            expected = Right(List#{Age(0), Age(10), Age(20)}),
            Either.traverse(Age.make, List#{0, 10, 20})
        );
        assertEq(expected = Left("Age is out of range."), Either.traverse(Age.make, List#{0, -1, 20}));
        assertEq(expected = Right(Nil), Either.traverse(Age.make, Nil))

    @Test
    def testSequence(): Unit \ Assert =
        assertEq(
            expected = Right(List#{Age(0), Age(10), Age(20)}),
            List#{0, 10, 20} |> List.map(Age.make) |> Either.sequence
        );
        assertEq(
            expected = Left("Age is out of range."),
            List#{0, -1, 20} |> List.map(Age.make) |> Either.sequence
        );
        assertEq(expected = Right(Nil), Either.sequence((Nil: List[Either[String, Age]])))
}
