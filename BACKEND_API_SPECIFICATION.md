# 🔧 NORDEN Backend API Specification for .NET Team

## 📋 Overview
This document provides detailed specifications for the .NET backend API that will support the Norden Flutter e-commerce application. The Flutter app is currently using Firebase services and needs to be migrated to a custom .NET backend.

## 🏗️ Architecture Overview

### Current Flutter App Structure:
```
lib/
├── models/          # Data models
├── services/        # API service classes
├── screens/         # UI screens
└── widgets/         # Reusable UI components
```

### Required .NET Backend Structure:
```
Norden.API/
├── Controllers/     # API Controllers
├── Models/          # Data Models
├── Services/        # Business Logic
├── Data/            # Database Context
└── Middleware/      # Authentication, etc.
```

## 🗄️ Database Schema

### 1. Users Table
```sql
CREATE TABLE Users (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Email NVARCHAR(255) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    DisplayName NVARCHAR(100),
    PhotoURL NVARCHAR(500),
    PhoneNumber NVARCHAR(20),
    IsAdmin BIT DEFAULT 0,
    IsEmailVerified BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE(),
    IsActive BIT DEFAULT 1
);
```

### 2. Products Table
```sql
CREATE TABLE Products (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    Price DECIMAL(10,2) NOT NULL,
    OriginalPrice DECIMAL(10,2),
    Category NVARCHAR(100),
    Brand NVARCHAR(100),
    SKU NVARCHAR(100) UNIQUE,
    StockQuantity INT DEFAULT 0,
    Images NVARCHAR(MAX), -- JSON array of image URLs
    Colors NVARCHAR(MAX), -- JSON array of available colors
    Sizes NVARCHAR(MAX),  -- JSON array of available sizes
    IsNew BIT DEFAULT 0,
    IsFeatured BIT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE()
);
```

### 3. Reviews Table
```sql
CREATE TABLE Reviews (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ProductId UNIQUEIDENTIFIER NOT NULL,
    UserId UNIQUEIDENTIFIER NOT NULL,
    Rating INT NOT NULL CHECK (Rating >= 1 AND Rating <= 5),
    Title NVARCHAR(200),
    Comment NVARCHAR(MAX) NOT NULL,
    Images NVARCHAR(MAX), -- JSON array of image URLs
    IsVerified BIT DEFAULT 0,
    HelpfulCount INT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (ProductId) REFERENCES Products(Id),
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);
```

### 4. ReviewHelpful Table
```sql
CREATE TABLE ReviewHelpful (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ReviewId UNIQUEIDENTIFIER NOT NULL,
    UserId UNIQUEIDENTIFIER NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (ReviewId) REFERENCES Reviews(Id),
    FOREIGN KEY (UserId) REFERENCES Users(Id),
    UNIQUE(ReviewId, UserId)
);
```

### 5. CartItems Table
```sql
CREATE TABLE CartItems (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    ProductId UNIQUEIDENTIFIER NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    SelectedColor NVARCHAR(50),
    SelectedSize NVARCHAR(20),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (UserId) REFERENCES Users(Id),
    FOREIGN KEY (ProductId) REFERENCES Products(Id),
    UNIQUE(UserId, ProductId, SelectedColor, SelectedSize)
);
```

### 6. WishlistItems Table
```sql
CREATE TABLE WishlistItems (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    ProductId UNIQUEIDENTIFIER NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (UserId) REFERENCES Users(Id),
    FOREIGN KEY (ProductId) REFERENCES Products(Id),
    UNIQUE(UserId, ProductId)
);
```

### 7. Addresses Table
```sql
CREATE TABLE Addresses (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    Title NVARCHAR(100) NOT NULL,
    StreetAddress NVARCHAR(200) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    State NVARCHAR(100),
    Country NVARCHAR(100) NOT NULL,
    PostalCode NVARCHAR(20),
    Latitude DECIMAL(10, 8),
    Longitude DECIMAL(11, 8),
    IsDefault BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);
```

### 8. Orders Table
```sql
CREATE TABLE Orders (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    OrderNumber NVARCHAR(50) UNIQUE NOT NULL,
    Status NVARCHAR(50) NOT NULL, -- Pending, Confirmed, Shipped, Delivered, Cancelled
    PaymentMethod NVARCHAR(50) NOT NULL, -- CreditCard, CashOnDelivery
    PaymentStatus NVARCHAR(50) NOT NULL, -- Pending, Paid, Failed
    SubTotal DECIMAL(10,2) NOT NULL,
    ShippingCost DECIMAL(10,2) DEFAULT 0,
    TaxAmount DECIMAL(10,2) DEFAULT 0,
    TotalAmount DECIMAL(10,2) NOT NULL,
    ShippingAddress NVARCHAR(MAX) NOT NULL, -- JSON object
    Notes NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);
```

### 9. OrderItems Table
```sql
CREATE TABLE OrderItems (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    OrderId UNIQUEIDENTIFIER NOT NULL,
    ProductId UNIQUEIDENTIFIER NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    SelectedColor NVARCHAR(50),
    SelectedSize NVARCHAR(20),
    FOREIGN KEY (OrderId) REFERENCES Orders(Id),
    FOREIGN KEY (ProductId) REFERENCES Products(Id)
);
```

### 10. OrderTracking Table
```sql
CREATE TABLE OrderTracking (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    OrderId UNIQUEIDENTIFIER NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX),
    Location NVARCHAR(200),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (OrderId) REFERENCES Orders(Id)
);
```

## 🔐 Authentication API Endpoints

### POST /api/auth/register
```json
Request:
{
    "email": "user@example.com",
    "password": "password123",
    "displayName": "John Doe",
    "phoneNumber": "+1234567890"
}

Response:
{
    "success": true,
    "data": {
        "userId": "uuid",
        "email": "user@example.com",
        "displayName": "John Doe",
        "token": "jwt_token",
        "refreshToken": "refresh_token"
    }
}
```

### POST /api/auth/login
```json
Request:
{
    "email": "user@example.com",
    "password": "password123"
}

Response:
{
    "success": true,
    "data": {
        "userId": "uuid",
        "email": "user@example.com",
        "displayName": "John Doe",
        "photoURL": "https://...",
        "isAdmin": false,
        "token": "jwt_token",
        "refreshToken": "refresh_token"
    }
}
```

### POST /api/auth/refresh-token
```json
Request:
{
    "refreshToken": "refresh_token"
}

Response:
{
    "success": true,
    "data": {
        "token": "new_jwt_token",
        "refreshToken": "new_refresh_token"
    }
}
```

### POST /api/auth/forgot-password
```json
Request:
{
    "email": "user@example.com"
}

Response:
{
    "success": true,
    "message": "Password reset email sent"
}
```

## 📦 Products API Endpoints

### GET /api/products
Query Parameters:
- `page`: int (default: 1)
- `limit`: int (default: 20)
- `category`: string
- `brand`: string
- `minPrice`: decimal
- `maxPrice`: decimal
- `sortBy`: string (price, rating, date)
- `sortOrder`: string (asc, desc)
- `search`: string

Response:
```json
{
    "success": true,
    "data": {
        "products": [
            {
                "id": "uuid",
                "name": "Product Name",
                "description": "Product Description",
                "price": 99.99,
                "originalPrice": 129.99,
                "category": "Clothing",
                "brand": "Norden",
                "images": ["url1", "url2"],
                "colors": ["Red", "Blue", "Black"],
                "sizes": ["S", "M", "L", "XL"],
                "isNew": true,
                "isFeatured": false,
                "rating": {
                    "averageRating": 4.5,
                    "totalReviews": 23
                }
            }
        ],
        "pagination": {
            "currentPage": 1,
            "totalPages": 5,
            "totalItems": 100,
            "itemsPerPage": 20
        }
    }
}
```

### GET /api/products/{id}
Response:
```json
{
    "success": true,
    "data": {
        "id": "uuid",
        "name": "Product Name",
        "description": "Product Description",
        "price": 99.99,
        "originalPrice": 129.99,
        "category": "Clothing",
        "brand": "Norden",
        "sku": "PROD-001",
        "stockQuantity": 50,
        "images": ["url1", "url2"],
        "colors": ["Red", "Blue", "Black"],
        "sizes": ["S", "M", "L", "XL"],
        "isNew": true,
        "isFeatured": false,
        "rating": {
            "averageRating": 4.5,
            "totalReviews": 23,
            "ratingDistribution": {
                "5": 15,
                "4": 6,
                "3": 2,
                "2": 0,
                "1": 0
            }
        }
    }
}
```

## ⭐ Reviews API Endpoints

### GET /api/products/{productId}/reviews
Query Parameters:
- `page`: int (default: 1)
- `limit`: int (default: 10)
- `rating`: int (filter by rating)
- `sortBy`: string (date, helpful, rating)

Response:
```json
{
    "success": true,
    "data": {
        "reviews": [
            {
                "id": "uuid",
                "userId": "uuid",
                "userName": "John Doe",
                "userImageUrl": "https://...",
                "rating": 5,
                "title": "Great product!",
                "comment": "Love this product...",
                "images": ["url1", "url2"],
                "isVerified": true,
                "helpfulCount": 12,
                "createdAt": "2024-01-15T10:30:00Z"
            }
        ],
        "pagination": {
            "currentPage": 1,
            "totalPages": 3,
            "totalItems": 23,
            "itemsPerPage": 10
        }
    }
}
```

### POST /api/products/{productId}/reviews
Request:
```json
{
    "rating": 5,
    "title": "Great product!",
    "comment": "Love this product...",
    "images": ["base64_image1", "base64_image2"]
}
```

### PUT /api/reviews/{reviewId}
Request:
```json
{
    "rating": 4,
    "title": "Updated title",
    "comment": "Updated comment..."
}
```

### DELETE /api/reviews/{reviewId}
Response:
```json
{
    "success": true,
    "message": "Review deleted successfully"
}
```

### POST /api/reviews/{reviewId}/helpful
Response:
```json
{
    "success": true,
    "data": {
        "helpfulCount": 13
    }
}
```

## 🛒 Cart API Endpoints

### GET /api/cart
Response:
```json
{
    "success": true,
    "data": {
        "items": [
            {
                "id": "uuid",
                "product": {
                    "id": "uuid",
                    "name": "Product Name",
                    "price": 99.99,
                    "image": "url"
                },
                "quantity": 2,
                "selectedColor": "Red",
                "selectedSize": "L"
            }
        ],
        "subtotal": 199.98,
        "totalItems": 2
    }
}
```

### POST /api/cart/items
Request:
```json
{
    "productId": "uuid",
    "quantity": 2,
    "selectedColor": "Red",
    "selectedSize": "L"
}
```

### PUT /api/cart/items/{itemId}
Request:
```json
{
    "quantity": 3
}
```

### DELETE /api/cart/items/{itemId}
Response:
```json
{
    "success": true,
    "message": "Item removed from cart"
}
```

## ❤️ Wishlist API Endpoints

### GET /api/wishlist
Response:
```json
{
    "success": true,
    "data": {
        "items": [
            {
                "id": "uuid",
                "product": {
                    "id": "uuid",
                    "name": "Product Name",
                    "price": 99.99,
                    "image": "url"
                },
                "createdAt": "2024-01-15T10:30:00Z"
            }
        ]
    }
}
```

### POST /api/wishlist/items
Request:
```json
{
    "productId": "uuid"
}
```

### DELETE /api/wishlist/items/{productId}
Response:
```json
{
    "success": true,
    "message": "Item removed from wishlist"
}
```

## 📍 Addresses API Endpoints

### GET /api/addresses
Response:
```json
{
    "success": true,
    "data": [
        {
            "id": "uuid",
            "title": "Home",
            "streetAddress": "123 Main St",
            "city": "New York",
            "state": "NY",
            "country": "USA",
            "postalCode": "10001",
            "latitude": 40.7128,
            "longitude": -74.0060,
            "isDefault": true,
            "createdAt": "2024-01-15T10:30:00Z"
        }
    ]
}
```

### POST /api/addresses
Request:
```json
{
    "title": "Home",
    "streetAddress": "123 Main St",
    "city": "New York",
    "state": "NY",
    "country": "USA",
    "postalCode": "10001",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "isDefault": true
}
```

### PUT /api/addresses/{addressId}
### DELETE /api/addresses/{addressId}

## 🛍️ Orders API Endpoints

### POST /api/orders
Request:
```json
{
    "items": [
        {
            "productId": "uuid",
            "quantity": 2,
            "selectedColor": "Red",
            "selectedSize": "L"
        }
    ],
    "shippingAddress": {
        "title": "Home",
        "streetAddress": "123 Main St",
        "city": "New York",
        "state": "NY",
        "country": "USA",
        "postalCode": "10001",
        "latitude": 40.7128,
        "longitude": -74.0060
    },
    "paymentMethod": "CreditCard",
    "notes": "Please deliver during business hours"
}
```

Response:
```json
{
    "success": true,
    "data": {
        "orderId": "uuid",
        "orderNumber": "ORD-2024-001",
        "status": "Pending",
        "paymentStatus": "Pending",
        "totalAmount": 199.98,
        "createdAt": "2024-01-15T10:30:00Z"
    }
}
```

### GET /api/orders
Query Parameters:
- `page`: int (default: 1)
- `limit`: int (default: 10)
- `status`: string (filter by status)

Response:
```json
{
    "success": true,
    "data": {
        "orders": [
            {
                "id": "uuid",
                "orderNumber": "ORD-2024-001",
                "status": "Shipped",
                "paymentStatus": "Paid",
                "totalAmount": 199.98,
                "items": [
                    {
                        "product": {
                            "id": "uuid",
                            "name": "Product Name",
                            "image": "url"
                        },
                        "quantity": 2,
                        "unitPrice": 99.99,
                        "selectedColor": "Red",
                        "selectedSize": "L"
                    }
                ],
                "shippingAddress": {...},
                "createdAt": "2024-01-15T10:30:00Z"
            }
        ],
        "pagination": {...}
    }
}
```

### GET /api/orders/{orderId}
### GET /api/orders/{orderId}/tracking

## 🔍 Search API Endpoints

### GET /api/search
Query Parameters:
- `q`: string (search query)
- `category`: string
- `brand`: string
- `minPrice`: decimal
- `maxPrice`: decimal
- `rating`: int (minimum rating)
- `page`: int
- `limit`: int
- `sortBy`: string
- `sortOrder`: string

Response:
```json
{
    "success": true,
    "data": {
        "products": [...],
        "filters": {
            "categories": ["Clothing", "Accessories"],
            "brands": ["Norden", "Brand2"],
            "priceRange": {
                "min": 10.00,
                "max": 500.00
            },
            "ratings": [4, 5]
        },
        "pagination": {...}
    }
}
```

## 📊 Admin API Endpoints

### GET /api/admin/dashboard
Response:
```json
{
    "success": true,
    "data": {
        "overview": {
            "totalOrders": 150,
            "totalRevenue": 25000.00,
            "totalProducts": 45,
            "totalUsers": 320
        },
        "recentOrders": [...],
        "topProducts": [...],
        "salesChart": {
            "labels": ["Jan", "Feb", "Mar", "Apr", "May"],
            "data": [5000, 6000, 5500, 7000, 6500]
        }
    }
}
```

### GET /api/admin/products
### POST /api/admin/products
### PUT /api/admin/products/{id}
### DELETE /api/admin/products/{id}

### GET /api/admin/orders
### PUT /api/admin/orders/{id}/status

## 🔧 Technical Requirements

### 1. Framework & Technologies
- **.NET 8.0** or later
- **ASP.NET Core Web API**
- **Entity Framework Core** for ORM
- **SQL Server** or **PostgreSQL** for database
- **JWT** for authentication
- **AutoMapper** for object mapping
- **Swagger/OpenAPI** for API documentation

### 2. Security Requirements
- JWT-based authentication
- Password hashing with BCrypt
- CORS configuration for Flutter app
- Rate limiting for API endpoints
- Input validation and sanitization
- SQL injection prevention

### 3. Performance Requirements
- Response time < 200ms for simple queries
- Response time < 500ms for complex queries
- Support for pagination on all list endpoints
- Database indexing on frequently queried columns
- Caching for static data (categories, brands)

### 4. File Upload Requirements
- Support for image uploads (reviews, product images)
- Image compression and resizing
- Secure file storage (Azure Blob Storage or AWS S3)
- File type validation
- Size limits (max 5MB per image)

### 5. Error Handling
- Consistent error response format:
```json
{
    "success": false,
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Invalid input data",
        "details": {
            "field": "email",
            "message": "Email is required"
        }
    }
}
```

### 6. Logging & Monitoring
- Structured logging with Serilog
- Request/Response logging
- Error tracking
- Performance monitoring
- Health checks

## 📱 Flutter Integration Notes

### 1. HTTP Client Configuration
```dart
// Base URL configuration
const String BASE_URL = 'https://api.norden.com';

// Headers for authenticated requests
Map<String, String> getAuthHeaders() {
  return {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
```

### 2. Service Layer Structure
Each API endpoint should have a corresponding service method in Flutter:
```dart
class ProductService {
  Future<List<Product>> getProducts({int page = 1, int limit = 20}) async {
    // Implementation
  }
  
  Future<Product> getProduct(String id) async {
    // Implementation
  }
}
```

### 3. Error Handling
```dart
class ApiException implements Exception {
  final String message;
  final String? code;
  
  ApiException(this.message, [this.code]);
}
```

## 🚀 Deployment Requirements

### 1. Environment Configuration
- Development environment
- Staging environment  
- Production environment
- Environment-specific configuration files

### 2. Database Migration
- Entity Framework migrations
- Seed data for initial setup
- Backup and restore procedures

### 3. API Documentation
- Swagger/OpenAPI documentation
- Postman collection
- Integration examples

## 📋 Implementation Priority

### Phase 1 (Core Features) - Week 1-2
1. ✅ Authentication API (Register, Login, Refresh Token)
2. ✅ Products API (CRUD operations)
3. ✅ Basic search functionality
4. ✅ Cart API
5. ✅ Wishlist API

### Phase 2 (Enhanced Features) - Week 3-4
1. ✅ Reviews and Ratings API
2. ✅ Addresses API
3. ✅ Orders API
4. ✅ Order Tracking API
5. ✅ Advanced search with filters

### Phase 3 (Admin Features) - Week 5-6
1. ✅ Admin Dashboard API
2. ✅ Product Management API
3. ✅ Order Management API
4. ✅ Analytics API

### Phase 4 (Optimization) - Week 7-8
1. ✅ Performance optimization
2. ✅ Caching implementation
3. ✅ File upload optimization
4. ✅ Security hardening

## 📞 Contact & Support

For any questions or clarifications regarding this specification, please contact the Flutter development team.

**Flutter App Status**: ✅ Complete and ready for backend integration
**Current Firebase Usage**: Temporary - ready to migrate to .NET backend
**Testing Requirements**: All endpoints should be tested with Postman/Unit tests before Flutter integration

---

*This specification is a living document and will be updated as requirements evolve.*
