order = Order.create(cost: 150_000, user_ip_address: '61.1.224.56')

order.items.create(name: "Apple", cost: 100_000)
order.items.create(name: "Banana", cost: 50_000)
