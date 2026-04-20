  class ProductModel {
    final int id;
    final String title;
    final String description;
    final double price;
    final String category;
    final String thumbnail;
    final List<String> images;

    ProductModel({
      required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.category,
      required this.thumbnail,
      required this.images,
    });

    factory ProductModel.fromJson(Map<String, dynamic> json) {
      return ProductModel(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(), 
        category: json['category'] as String,
        thumbnail: json['thumbnail'] as String,
        images: List<String>.from(json['images'] ?? []), 
      );
    }
    
    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'thumbnail': thumbnail,
        'images': images,
      };
    }
  }