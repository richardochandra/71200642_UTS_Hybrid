import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Produk',
      home: ProductList(),
    );
  }
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Product> _products = [
    Product(name: 'Soto', weight: 0.5, price: 11000, image: 'assets/soto.png'),
    Product(name: 'Nasgor', weight: 1, price: 15000, image: 'assets/nasgor.png'),
    Product(name: 'Bipang', weight: 2, price: 100000, image: 'assets/bipang.png'),
    Product(name: 'Bakso', weight: 1.5, price: 17000, image: 'assets/bakso.png'),
    Product(name: 'Batagor', weight: 0.7, price: 10000, image: 'assets/batagor.png'),
    Product(name: 'Lotek', weight: 1, price: 8000, image: 'assets/lotek.png'),
    Product(name: 'Bakmi', weight: 0.9, price: 15000, image: 'assets/bakmi.png'),
    Product(name: 'Cilok', weight: 0.4, price: 5000, image: 'assets/cilok.png'),
    Product(name: 'Geprek', weight: 0.8, price: 11000, image: 'assets/geprek.png'),
    Product(name: 'Martabak', weight: 1, price: 32000, image: 'assets/martabak.png'),
    Product(name: 'Burjo', weight: 0.8, price: 7000, image: 'assets/burjo.png'),
    Product(name: 'ban', weight: 12, price: 450000, image: 'assets/ban.png'),


  ];
  List<Product> _cartItems = [];
  int _currentPage = 1;
  int _itemsPerPage = 9 ; // display 6 items per page

  // compute the total number of pages
  int get _totalPages =>
      (_products.length / _itemsPerPage).ceil();

  // compute the current page items
  List<Product> get _currentItems {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _products.sublist(startIndex, endIndex.clamp(0, _products.length));
  }

  // handle next page button
  void _nextPage() {
    setState(() {
      _currentPage = (_currentPage + 1).clamp(1, _totalPages);
    });
  }

  // handle prev page button
  void _prevPage() {
    setState(() {
      _currentPage = (_currentPage - 1).clamp(1, _totalPages);
    });
  }

  void _addToCart(Product product) {
    setState(() {
      bool found = false;
      for (var item in _cartItems) {
        if (item.name == product.name) {
          item.quantity += 1;
          found = true;
          break;
        }
      }
      if (!found) {
        _cartItems.add(product);
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text('${product.name} added to cart'),
      duration: Duration(seconds: 1),),
      );
    }
      );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TOKO-NYA DIA'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(10),
              crossAxisCount: 3,
              children: List.generate(_currentItems.length, (index) {
                final product = _currentItems[index];
                return GestureDetector(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          product.image,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(product.name),
                      Text('${product.weight} kg'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _addToCart(product),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _currentPage > 1 ? _prevPage : null,
                child: Icon(Icons.arrow_back),
              ),
              SizedBox(width: 10),
              Text('Page $_currentPage of $_totalPages'),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _currentPage < _totalPages ? _nextPage : null,
                child: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartPage(cartItems: _cartItems),
            ),
          );
        },
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}

class ShippingOption {
  final String name;
  final int pricePerKg;

  ShippingOption(this.name, this.pricePerKg);
}

class CartPage extends StatefulWidget {
  final List<Product> cartItems;
  const CartPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  ShippingOption? _selectedShippingOption;

  final List<ShippingOption> _shippingOptions = [
    ShippingOption('JNE', 10000),
    ShippingOption('J&T', 12000),
    ShippingOption('Pos Indonesia', 8000),
  ];

  void _incrementQuantity(Product product) {
    setState(() {
      product.quantity++;
    });
  }

  void _decrementQuantity(Product product) {
    setState(() {
      if (product.quantity>1) {
        product.quantity--;
      }
    });
  }

  void _deleteItem(Product product){
    setState(() {
      widget.cartItems.remove(product);
      if (product.quantity>1) {
        product.quantity = 1;
      }
    });
  }

  double _calculateSubtotal(Product product) {
    return product.price.toDouble() * product.quantity.toDouble();
  }

  double _calculateTotalPrice() {
    double total = 0;
    for (Product product in widget.cartItems) {
      total += product.price * product.quantity;
    }
    return total + _calculateShippingCost();
  }

  double _calculateTotalWeight() {
    double weight = 0;
    for (Product product in widget.cartItems) {
      weight += product.weight * product.quantity;
    }
    return weight;
  }

  double _calculateShippingCost() {
    double weight = _calculateTotalWeight();
    if (_selectedShippingOption == null) {
      return 0;
    } else {
      return _selectedShippingOption!.pricePerKg * weight;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TOKO-NYA DIA'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Image.asset(
                          widget.cartItems[index].image,
                          height: 100,
                          width: 100,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.cartItems[index].name),
                            SizedBox(height: 5),
                            Text('Berat: ${widget.cartItems[index].weight} kg'),
                            SizedBox(height: 5),
                            Text('Harga : @Rp ${widget.cartItems[index].price} '),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _decrementQuantity(
                                      widget.cartItems[index]),
                                  icon: Icon(Icons.remove),
                                ),
                                Text('${widget.cartItems[index].quantity}'),
                                IconButton(
                                  onPressed: () => _incrementQuantity(
                                      widget.cartItems[index]),
                                  icon: Icon(Icons.add),
                                ),
                                IconButton(onPressed: () => _deleteItem(widget.cartItems[index]),
                                    icon: Icon(Icons.delete))
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Rp ${_calculateSubtotal(widget.cartItems[index])}',
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(height: 1),
                ],
              ),
            ),
          );
        },
      ),


      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 200,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pilih Kurir:'),
                  DropdownButton<ShippingOption>(
                    value: _selectedShippingOption,
                    onChanged: (ShippingOption? newValue) {
                      setState(() {
                        _selectedShippingOption = newValue;
                      });
                    },
                    items: _shippingOptions
                        .map<DropdownMenuItem<ShippingOption>>(
                            (ShippingOption value) {
                          return DropdownMenuItem<ShippingOption>(
                            value: value,
                            child: Text(value.name),
                          );
                        }).toList(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Berat Total:'),
                  Text('${_calculateTotalWeight()} kg'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0.0,25.0),
                    child: Text('Biaya Pengiriman:'),
                  ),
                  Text('Rp ${_calculateShippingCost()}'),
                ],
              ),
              Divider(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Total:',
                      style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),

                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Text(
                      'Rp ${_calculateTotalPrice()}',
                      style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final double weight;
  final int price;
  final String image;
  int quantity ;

  Product(
      {required this.name,
      required this.weight,
      required this.price,
      required this.image})
      : quantity = 1;
}

