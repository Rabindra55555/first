import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Product {
  final String name;
  final String category;
  final double price;
  final String image;

  Product({
    required this.name,
    required this.category,
    required this.price,
    required this.image,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Ecommerce',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Product> products = [
    Product(
      name: "iPhone 15",
      category: "Electronics",
      price: 999,
      image: "https://picsum.photos/300?1",
    ),
    Product(
      name: "Nike Shoes",
      category: "Fashion",
      price: 120,
      image: "https://picsum.photos/300?2",
    ),
    Product(
      name: "Headphones",
      category: "Electronics",
      price: 80,
      image: "https://picsum.photos/300?3",
    ),
  ];

  final List<Product> cart = [];

  String search = "";
  String selectedCategory = "All";

  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final imageController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    priceController.dispose();
    imageController.dispose();
    super.dispose();
  }

  List<String> get categories {
    final cats = products.map((e) => e.category).toSet().toList();
    return ["All", ...cats];
  }

  List<Product> get filteredProducts {
    return products.where((p) {
      final searchMatch =
          p.name.toLowerCase().contains(search.toLowerCase());

      final categoryMatch = selectedCategory == "All"
          ? true
          : p.category == selectedCategory;

      return searchMatch && categoryMatch;
    }).toList();
  }

  void addProduct() {
    final name = nameController.text.trim();
    final category = categoryController.text.trim();
    final price = double.tryParse(priceController.text.trim());

    if (name.isEmpty ||
        category.isEmpty ||
        price == null ||
        price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter valid product data"),
        ),
      );
      return;
    }

    setState(() {
      products.add(
        Product(
          name: name,
          category: category,
          price: price,
          image: imageController.text.trim().isEmpty
              ? "https://picsum.photos/300?random=${DateTime.now().millisecondsSinceEpoch}"
              : imageController.text.trim(),
        ),
      );
    });

    nameController.clear();
    categoryController.clear();
    priceController.clear();
    imageController.clear();

    Navigator.pop(context);
  }

  void showAddProductDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add Product",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Product Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Price",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(
                    labelText: "Image URL (optional)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: addProduct,
                    child: const Text("Add Product"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showCart() {
    double total = cart.fold(
      0,
      (sum, item) => sum + item.price,
    );

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * .7,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Shopping Cart",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(
                          child: Text("Cart is empty"),
                        )
                      : ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (_, index) {
                            final item = cart[index];

                            return Card(
                              child: ListTile(
                                title: Text(item.name),
                                subtitle: Text(item.category),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "\$${item.price.toStringAsFixed(2)}",
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          cart.removeAt(index);
                                        });

                                        Navigator.pop(context);
                                        showCart();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const Divider(),
                Text(
                  "Total: \$${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCartIcon() {
    return Stack(
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.shopping_cart),
        ),
        if (cart.isNotEmpty)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                cart.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget productCard(Product product) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              product.image,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Center(
                  child: Icon(Icons.image, size: 50),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  product.category,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${product.price}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        cart.add(product);
                      });

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            "${product.name} added to cart",
                          ),
                        ),
                      );
                    },
                    child: const Text("Add"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsToShow = filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mini Ecommerce"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: showCart,
            icon: buildCartIcon(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddProductDialog,
        icon: const Icon(Icons.add),
        label: const Text("Product"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search products...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((category) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected:
                        selectedCategory == category,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: productsToShow.isEmpty
                ? const Center(
                    child: Text(
                      "No products found",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: productsToShow.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: .62,
                    ),
                    itemBuilder: (_, index) {
                      return productCard(
                        productsToShow[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}