pub mod FpInFlix.Answers.Introduction.SecondExample {
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

    pub eff Payment {
        def charge(cc: CreditCard, amount: Float64): Unit
    }

    mod Cafe {
        use FpInFlix.Answers.Introduction.SecondExample.{Coffee, CreditCard, Payment}

        pub def buyCoffee(cc: CreditCard): Coffee \ Payment =
            let coffee = Coffee.make();
            let Coffee.Coffee({price}) = coffee;
            Payment.charge(cc, price);
            coffee
    }

    pub def example(): Unit \ IO =
        let cup = run {
            Cafe.buyCoffee(CreditCard.CreditCard("A"))
        } with handler Payment {
            def charge(cc, amount, resume) = {
                println("charging ${amount} to ${cc}");
                resume()
            }
        };
        println("a cup of ${cup}")
}
