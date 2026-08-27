pub mod FpInFlix.Answers.Introduction.FirstExample {
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
        pub def charge(price: Float64): Unit \ IO =
            println("charging ${price}")
    }

    mod Cafe {
        use FpInFlix.Answers.Introduction.FirstExample.Coffee

        pub def buyCoffee(charge: Float64 -> Unit \ IO): Coffee \ IO =
            let coffee = Coffee.make();
            let Coffee.Coffee({price}) = coffee;
            charge(price);
            coffee
    }

    pub def example(): Unit \ IO =
        let cup = Cafe.buyCoffee(CreditCard.charge);
        println("a cup of ${cup}")
}
