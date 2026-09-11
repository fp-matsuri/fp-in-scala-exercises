pub mod FpInFlix.Answers.Introduction.ThirdExample {
    mod Coffee {
        pub enum Coffee({price = Float64})

        instance ToString[Coffee] {
            pub def toString(coffee: Coffee): String =
                let Coffee({price}) = coffee;
                "Coffee({price = ${price}})"
        }

        pub def make(): Coffee =
            Coffee({price = 2.0})
    }

    mod CreditCard {
        pub enum CreditCard(String) with Eq, ToString
    }

    mod Charge {
        use FpInFlix.Answers.Introduction.ThirdExample.CreditCard

        pub enum Charge({creditCard = CreditCard, amount = Float64})

        instance ToString[Charge] {
            pub def toString(charge: Charge): String =
                let Charge({creditCard, amount}) = charge;
                "Charge({creditCard = ${creditCard}, amount = ${amount}})"
        }

        pub def combine(a: Charge, b: Charge): Result[String, Charge] =
            let Charge({creditCard = cardA, amount = amountA}) = a;
            let Charge({creditCard = cardB, amount = amountB}) = b;
            if (cardA == cardB) Ok(Charge({creditCard = cardA, amount = amountA + amountB}))
            else Err("Can't combine charges to different cards: cardA=${cardA}, cardB=${cardB}")

        pub def coalesce(charges: List[Charge]): Result[String, List[Charge]] =
            charges
                |> List.groupBy(match Charge({creditCard | _}) -> creditCard)
                |> Traversable.traverse(group -> Foldable.foldLeftM(combine, Nel.head(group), Nel.tail(group)))
    }

    mod Cafe {
        use FpInFlix.Answers.Introduction.ThirdExample.{Charge, Coffee, CreditCard}

        pub def buyCoffee(cc: CreditCard): (Coffee, Charge) =
            let coffee = Coffee.make();
            let Coffee.Coffee({price}) = coffee;
            let charge = Charge.Charge({creditCard = cc, amount = price});
            (coffee, charge)

        pub def buyCoffees(cc: CreditCard, n: Int32): Result[String, (List[Coffee], Charge)] =
            let (coffees, charges) = buyCoffee(cc) |> List.repeat(n) |> List.unzip;
            charges
                |> Foldable.foldLeftM(Charge.combine, Charge.Charge({creditCard = cc, amount = 0.0}))
                |> Functor.map(charge -> (coffees, charge))
    }

    pub def example_combine(): Unit \ IO =
        let resultOk = Charge.combine(
            Charge.Charge({creditCard = CreditCard.CreditCard("A"), amount = 1.0}),
            Charge.Charge({creditCard = CreditCard.CreditCard("A"), amount = 2.0})
        );
        println("Result of combining charges with the same card: ${resultOk}");
        let resultErr = Charge.combine(
            Charge.Charge({creditCard = CreditCard.CreditCard("A"), amount = 1.0}),
            Charge.Charge({creditCard = CreditCard.CreditCard("B"), amount = 2.0})
        );
        println("Result of combining charges with different cards: ${resultErr}")

    pub def example_coalesce(): Unit \ IO =
        let result = Charge.coalesce(List#{
            Charge.Charge({creditCard = CreditCard.CreditCard("A"), amount = 1.0}),
            Charge.Charge({creditCard = CreditCard.CreditCard("B"), amount = 2.0}),
            Charge.Charge({creditCard = CreditCard.CreditCard("A"), amount = 3.0})
        });
        println("Result of coalescing charges: ${result}")

    pub def example_buyCoffee(): Unit \ IO =
        let result = Cafe.buyCoffee(CreditCard.CreditCard("A"));
        println("Result of buying a coffee: ${result}")

    pub def example_buyCoffees(): Unit \ IO =
        let result = Cafe.buyCoffees(CreditCard.CreditCard("A"), 3);
        println("Result of buying 3 coffees: ${result}")
}
