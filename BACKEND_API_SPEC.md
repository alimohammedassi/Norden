# Norden Luxury E-Commerce Backend API Specification

## Overview

This document specifies the REST API endpoints required for the Norden luxury e-commerce mobile application. The backend should be built using **C# .NET** with **MySQL database**.

**Current Status:** The app currently uses Firebase (Firestore, Firebase Auth, Firebase Storage) for development. This specification will guide the migration to a custom backend.

---

## Table of Contents

1. [Authentication](#authentication)
2. [Products API](#products-api)
3. [Cart API](#cart-api)
4. [Wishlist API](#wishlist-api)
5. [Orders API](#orders-api)
6. [User Profile API](#user-profile-api)
7. [Addresses API](#addresses-api)
8. [Payment Methods API](#payment-methods-api)
9. [Admin API](#admin-api)
10. [Analytics API](#analytics-api)
11. [Data Models](#data-models)

---

## Base URL

```
Production: https://api.norden.com/v1
Development: https://dev-api.norden.com/v1
```

---

## Authentication

All authenticated endpoints require a **Bearer token** in the Authorization header:

```
Authorization: Bearer <JWT_TOKEN>
```

### Auth Endpoints

#### 1. Register User
```http
POST /auth/register
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "displayName": "John Doe",
  "phoneNumber": "+201234567890" // optional
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "userId": "uuid-123",
    "email": "user@example.com",
    "displayName": "John Doe",
    "token": "jwt-token-here",
    "refreshToken": "refresh-token-here"
  }
}
```

#### 2. Login
```http
POST /auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "userId": "uuid-123",
    "email": "user@example.com",
    "displayName": "John Doe",
    "isAdmin": false,
    "token": "jwt-token-here",
    "refreshToken": "refresh-token-here"
  }
}
```

#### 3. Google Sign-In
```http
POST /auth/google
```

**Request Body:**
```json
{
  "idToken": "google-id-token"
}
```

**Response:** Same as login

#### 4. Guest Login
```http
POST /auth/guest
```

**Response:**
```json
{
  "success": true,
  "data": {
    "userId": "guest-uuid",
    "isGuest": true,
    "token": "jwt-token-here"
  }
}
```

#### 5. Forgot Password
```http
POST /auth/forgot-password
```

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password reset email sent"
}
```

#### 6. Logout
```http
POST /auth/logout
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## Products API

### 1. Get All Products
```http
GET /products
```

**Query Parameters:**
- `category` (optional): Filter by category (Coats, Blazers, Dress Shirts, Trousers, Accessories)
- `isFeatured` (optional): true/false
- `isNew` (optional): true/false
- `limit` (optional): Number of items (default: 50)
- `offset` (optional): Pagination offset (default: 0)

**Response:**
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "product-uuid",
        "name": "Luxury Blazer",
        "description": "Premium wool blazer with elegant tailoring",
        "price": 999.99,
        "category": "Blazers",
        "images": [
          "https://storage.norden.com/products/img1.jpg",
          "https://storage.norden.com/products/img2.jpg"
        ],
        "colors": ["Navy", "Black", "Charcoal"],
        "sizes": ["S", "M", "L", "XL", "XXL"],
        "stock": 50,
        "isNew": true,
        "isFeatured": false,
        "createdAt": "2025-01-15T10:30:00Z",
        "updatedAt": "2025-01-15T10:30:00Z"
      }
    ],
    "total": 150,
    "limit": 50,
    "offset": 0
  }
}
```

### 2. Get Product by ID
```http
GET /products/{productId}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "product-uuid",
    "name": "Luxury Blazer",
    "description": "Premium wool blazer...",
    "price": 999.99,
    "category": "Blazers",
    "images": ["url1", "url2"],
    "colors": ["Navy", "Black"],
    "sizes": ["S", "M", "L", "XL", "XXL"],
    "stock": 50,
    "isNew": true,
    "isFeatured": false,
    "createdAt": "2025-01-15T10:30:00Z",
    "updatedAt": "2025-01-15T10:30:00Z"
  }
}
```

### 3. Search Products
```http
GET /products/search?q={searchTerm}
```

**Query Parameters:**
- `q`: Search term
- `category` (optional): Filter by category

**Response:** Same as Get All Products

---

## Cart API

### 1. Get User Cart
```http
GET /cart
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "cart-item-uuid",
        "productId": "product-uuid",
        "productName": "Luxury Blazer",
        "productImage": "https://storage.norden.com/products/img1.jpg",
        "price": 999.99,
        "quantity": 2,
        "selectedColor": "Navy",
        "selectedSize": "L",
        "addedAt": "2025-01-15T10:30:00Z"
      }
    ],
    "subtotal": 1999.98,
    "tax": 0.00,
    "shipping": 0.00,
    "total": 1999.98
  }
}
```

### 2. Add Item to Cart
```http
POST /cart/items
```

**Headers:** Authorization Bearer Token

**Request Body:**
```json
{
  "productId": "product-uuid",
  "quantity": 1,
  "selectedColor": "Navy",
  "selectedSize": "L"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Item added to cart",
  "data": {
    "cartItemId": "cart-item-uuid"
  }
}
```

### 3. Update Cart Item
```http
PUT /cart/items/{cartItemId}
```

**Headers:** Authorization Bearer Token

**Request Body:**
```json
{
  "quantity": 3
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cart item updated"
}
```

### 4. Remove Cart Item
```http
DELETE /cart/items/{cartItemId}
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "message": "Item removed from cart"
}
```

### 5. Clear Cart
```http
DELETE /cart
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "message": "Cart cleared"
}
```

---

## Wishlist API

### 1. Get User Wishlist
```http
GET /wishlist
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "product-uuid",
        "name": "Luxury Blazer",
        "price": 999.99,
        "image": "https://storage.norden.com/products/img1.jpg",
        "addedAt": "2025-01-15T10:30:00Z"
      }
    ]
  }
}
```

### 2. Add to Wishlist
```http
POST /wishlist/items
```

**Headers:** Authorization Bearer Token

**Request Body:**
```json
{
  "productId": "product-uuid"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Product added to wishlist"
}
```

### 3. Remove from Wishlist
```http
DELETE /wishlist/items/{productId}
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "message": "Product removed from wishlist"
}
```

### 4. Check if Product in Wishlist
```http
GET /wishlist/check/{productId}
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "data": {
    "inWishlist": true
  }
}
```

---

## Orders API

### 1. Create Order
```http
POST /orders
```

**Headers:** Authorization Bearer Token

**Request Body:**
```json
{
  "shippingAddressId": "address-uuid",
  "paymentMethod": "card", // or "cash_on_delivery"
  "items": [
    {
      "productId": "product-uuid",
      "quantity": 2,
      "selectedColor": "Navy",
      "selectedSize": "L",
      "price": 999.99
    }
  ],
  "subtotal": 1999.98,
  "tax": 0.00,
  "shipping": 0.00,
  "total": 1999.98
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "orderId": "order-uuid",
    "orderNumber": "ORD-20250115-001",
    "status": "pending",
    "createdAt": "2025-01-15T10:30:00Z"
  }
}
```

### 2. Get User Orders
```http
GET /orders
```

**Headers:** Authorization Bearer Token

**Query Parameters:**
- `status` (optional): pending, processing, shipped, delivered, cancelled
- `limit` (optional): Default 20
- `offset` (optional): Default 0

**Response:**
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": "order-uuid",
        "orderNumber": "ORD-20250115-001",
        "status": "pending",
        "items": [...],
        "total": 1999.98,
        "shippingAddress": {...},
        "createdAt": "2025-01-15T10:30:00Z",
        "updatedAt": "2025-01-15T10:30:00Z"
      }
    ],
    "total": 25,
    "limit": 20,
    "offset": 0
  }
}
```

### 3. Get Order by ID
```http
GET /orders/{orderId}
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "order-uuid",
    "orderNumber": "ORD-20250115-001",
    "status": "pending",
    "items": [
      {
        "productId": "product-uuid",
        "productName": "Luxury Blazer",
        "productImage": "https://...",
        "quantity": 2,
        "selectedColor": "Navy",
        "selectedSize": "L",
        "price": 999.99,
        "subtotal": 1999.98
      }
    ],
    "subtotal": 1999.98,
    "tax": 0.00,
    "shipping": 0.00,
    "total": 1999.98,
    "paymentMethod": "card",
    "shippingAddress": {
      "label": "Home",
      "name": "John Doe",
      "phone": "+201234567890",
      "street": "123 Main St",
      "city": "Cairo",
      "country": "Egypt"
    },
    "createdAt": "2025-01-15T10:30:00Z",
    "updatedAt": "2025-01-15T10:30:00Z"
  }
}
```

### 4. Cancel Order
```http
POST /orders/{orderId}/cancel
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "message": "Order cancelled successfully"
}
```

---

## User Profile API

### 1. Get User Profile
```http
GET /users/profile
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "data": {
    "userId": "uuid-123",
    "email": "user@example.com",
    "displayName": "John Doe",
    "phoneNumber": "+201234567890",
    "photoURL": "https://storage.norden.com/avatars/user.jpg",
    "isGuest": false,
    "createdAt": "2025-01-01T00:00:00Z"
  }
}
```

### 2. Update User Profile
```http
PUT /users/profile
```

**Headers:** Authorization Bearer Token

**Request Body:**
```json
{
  "displayName": "John Updated",
  "phoneNumber": "+201234567890"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully"
}
```

### 3. Upload Profile Photo
```http
POST /users/profile/photo
```

**Headers:** 
- Authorization Bearer Token
- Content-Type: multipart/form-data

**Request Body:**
- Form field: `photo` (file)

**Response:**
```json
{
  "success": true,
  "data": {
    "photoURL": "https://storage.norden.com/avatars/user-123.jpg"
  }
}
```

---

## Addresses API

### 1. Get User Addresses
```http
GET /addresses
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "data": {
    "addresses": [
      {
        "id": "address-uuid",
        "label": "Home",
        "name": "John Doe",
        "phone": "+201234567890",
        "street": "123 Main St",
        "city": "Cairo",
        "country": "Egypt",
        "isDefault": true,
        "createdAt": "2025-01-15T10:30:00Z"
      }
    ]
  }
}
```

### 2. Add Address
```http
POST /addresses
```

**Headers:** Authorization Bearer Token

**Request Body:**
```json
{
  "label": "Home",
  "name": "John Doe",
  "phone": "+201234567890",
  "street": "123 Main St",
  "city": "Cairo",
  "country": "Egypt",
  "isDefault": false
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "addressId": "address-uuid"
  }
}
```

### 3. Update Address
```http
PUT /addresses/{addressId}
```

**Headers:** Authorization Bearer Token

**Request Body:** Same as Add Address

**Response:**
```json
{
  "success": true,
  "message": "Address updated successfully"
}
```

### 4. Delete Address
```http
DELETE /addresses/{addressId}
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "message": "Address deleted successfully"
}
```

### 5. Set Default Address
```http
POST /addresses/{addressId}/set-default
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "message": "Default address updated"
}
```

---

## Payment Methods API

### 1. Get Payment Methods
```http
GET /payment-methods
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "data": {
    "paymentMethods": [
      {
        "id": "payment-method-uuid",
        "type": "card",
        "cardLast4": "1234",
        "cardBrand": "Visa",
        "expiryMonth": 12,
        "expiryYear": 2026,
        "isDefault": true,
        "createdAt": "2025-01-15T10:30:00Z"
      }
    ]
  }
}
```

### 2. Add Payment Method
```http
POST /payment-methods
```

**Headers:** Authorization Bearer Token

**Request Body:**
```json
{
  "type": "card",
  "cardNumber": "4111111111111111",
  "cardholderName": "John Doe",
  "expiryMonth": 12,
  "expiryYear": 2026,
  "cvv": "123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "paymentMethodId": "payment-method-uuid"
  }
}
```

### 3. Delete Payment Method
```http
DELETE /payment-methods/{paymentMethodId}
```

**Headers:** Authorization Bearer Token

**Response:**
```json
{
  "success": true,
  "message": "Payment method deleted"
}
```

---

## Admin API

**Note:** All admin endpoints require an admin user token.

### Products Management

#### 1. Create Product (Admin)
```http
POST /admin/products
```

**Headers:** 
- Authorization Bearer Token (Admin)
- Content-Type: multipart/form-data

**Request Body:**
- `name`: string
- `description`: string
- `price`: number
- `category`: string
- `colors`: array of strings (JSON)
- `sizes`: array of strings (JSON)
- `stock`: number
- `isNew`: boolean
- `isFeatured`: boolean
- `images`: array of files

**Response:**
```json
{
  "success": true,
  "data": {
    "productId": "product-uuid",
    "imageUrls": [
      "https://storage.norden.com/products/img1.jpg",
      "https://storage.norden.com/products/img2.jpg"
    ]
  }
}
```

#### 2. Update Product (Admin)
```http
PUT /admin/products/{productId}
```

**Headers:** Authorization Bearer Token (Admin)

**Request Body:** Same as Create Product (all fields optional)

**Response:**
```json
{
  "success": true,
  "message": "Product updated successfully"
}
```

#### 3. Delete Product (Admin)
```http
DELETE /admin/products/{productId}
```

**Headers:** Authorization Bearer Token (Admin)

**Response:**
```json
{
  "success": true,
  "message": "Product deleted successfully"
}
```

### Orders Management

#### 4. Get All Orders (Admin)
```http
GET /admin/orders
```

**Headers:** Authorization Bearer Token (Admin)

**Query Parameters:**
- `status` (optional): Filter by status
- `startDate` (optional): Filter by date range
- `endDate` (optional): Filter by date range
- `limit`: Default 50
- `offset`: Default 0

**Response:**
```json
{
  "success": true,
  "data": {
    "orders": [...],
    "total": 500,
    "limit": 50,
    "offset": 0
  }
}
```

#### 5. Update Order Status (Admin)
```http
PUT /admin/orders/{orderId}/status
```

**Headers:** Authorization Bearer Token (Admin)

**Request Body:**
```json
{
  "status": "shipped" // pending, processing, shipped, delivered, cancelled
}
```

**Response:**
```json
{
  "success": true,
  "message": "Order status updated"
}
```

---

## Analytics API

**Note:** Admin only

### 1. Get Dashboard Stats
```http
GET /admin/analytics/dashboard
```

**Headers:** Authorization Bearer Token (Admin)

**Query Parameters:**
- `startDate` (optional): Default last 30 days
- `endDate` (optional): Default today

**Response:**
```json
{
  "success": true,
  "data": {
    "totalRevenue": 125000.00,
    "totalOrders": 450,
    "totalCustomers": 320,
    "totalProducts": 85,
    "revenueChange": "+15.3%", // compared to previous period
    "ordersChange": "+8.7%",
    "customersChange": "+12.1%",
    "topProducts": [
      {
        "productId": "product-uuid",
        "productName": "Luxury Blazer",
        "totalSales": 15000.00,
        "unitsSold": 15
      }
    ],
    "recentOrders": [...],
    "salesByCategory": {
      "Blazers": 45000.00,
      "Coats": 35000.00,
      "Dress Shirts": 25000.00,
      "Trousers": 15000.00,
      "Accessories": 5000.00
    }
  }
}
```

### 2. Get Sales Report
```http
GET /admin/analytics/sales
```

**Headers:** Authorization Bearer Token (Admin)

**Query Parameters:**
- `startDate`: Required
- `endDate`: Required
- `groupBy`: day, week, month (default: day)

**Response:**
```json
{
  "success": true,
  "data": {
    "salesData": [
      {
        "date": "2025-01-15",
        "revenue": 5000.00,
        "orders": 25
      }
    ],
    "totalRevenue": 125000.00,
    "totalOrders": 450,
    "averageOrderValue": 277.78
  }
}
```

---

## Data Models

### User
```typescript
{
  id: string (UUID)
  email: string (unique)
  passwordHash: string
  displayName: string
  phoneNumber: string (optional)
  photoURL: string (optional)
  isGuest: boolean (default: false)
  isAdmin: boolean (default: false)
  createdAt: datetime
  updatedAt: datetime
}
```

### Product
```typescript
{
  id: string (UUID)
  name: string
  description: text
  price: decimal(10,2)
  category: enum('Coats', 'Blazers', 'Dress Shirts', 'Trousers', 'Accessories')
  images: json (array of image URLs)
  colors: json (array of color names)
  sizes: json (array of size names)
  stock: integer
  isNew: boolean (default: false)
  isFeatured: boolean (default: false)
  createdAt: datetime
  updatedAt: datetime
}
```

### Cart
```typescript
{
  id: string (UUID)
  userId: string (foreign key)
  createdAt: datetime
  updatedAt: datetime
}
```

### CartItem
```typescript
{
  id: string (UUID)
  cartId: string (foreign key)
  productId: string (foreign key)
  quantity: integer
  selectedColor: string
  selectedSize: string
  price: decimal(10,2) // snapshot of price at time of adding
  addedAt: datetime
}
```

### Wishlist
```typescript
{
  id: string (UUID)
  userId: string (foreign key)
  productId: string (foreign key)
  addedAt: datetime
}
```

### Order
```typescript
{
  id: string (UUID)
  orderNumber: string (unique, auto-generated)
  userId: string (foreign key)
  status: enum('pending', 'processing', 'shipped', 'delivered', 'cancelled')
  subtotal: decimal(10,2)
  tax: decimal(10,2)
  shipping: decimal(10,2)
  total: decimal(10,2)
  paymentMethod: enum('card', 'cash_on_delivery')
  shippingAddressId: string (foreign key)
  createdAt: datetime
  updatedAt: datetime
}
```

### OrderItem
```typescript
{
  id: string (UUID)
  orderId: string (foreign key)
  productId: string (foreign key)
  productName: string // snapshot
  productImage: string // snapshot
  quantity: integer
  selectedColor: string
  selectedSize: string
  price: decimal(10,2) // snapshot
  subtotal: decimal(10,2)
}
```

### Address
```typescript
{
  id: string (UUID)
  userId: string (foreign key)
  label: string ('Home', 'Work', etc.)
  name: string
  phone: string
  street: string
  city: string
  country: string
  isDefault: boolean (default: false)
  createdAt: datetime
  updatedAt: datetime
}
```

### PaymentMethod
```typescript
{
  id: string (UUID)
  userId: string (foreign key)
  type: enum('card')
  cardLast4: string
  cardBrand: string ('Visa', 'Mastercard', etc.)
  expiryMonth: integer
  expiryYear: integer
  isDefault: boolean (default: false)
  createdAt: datetime
}
```

---

## Error Handling

All endpoints should return consistent error responses:

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {} // optional additional details
  }
}
```

### Common Error Codes
- `UNAUTHORIZED`: 401 - Invalid or missing token
- `FORBIDDEN`: 403 - User doesn't have permission
- `NOT_FOUND`: 404 - Resource not found
- `VALIDATION_ERROR`: 400 - Invalid request data
- `DUPLICATE_EMAIL`: 409 - Email already exists
- `INVALID_CREDENTIALS`: 401 - Wrong email/password
- `INSUFFICIENT_STOCK`: 400 - Product out of stock
- `SERVER_ERROR`: 500 - Internal server error

---

## File Upload

### Image Upload Requirements
- **Allowed formats:** JPEG, PNG, WebP
- **Max file size:** 5MB per image
- **Max images per product:** 10
- **Image processing:** 
  - Generate thumbnails: 300x300, 600x600, 1200x1200
  - Original quality for product details
  - WebP format for optimization

### Storage Structure
```
/products/{productId}/
  - original/image_0.jpg
  - original/image_1.jpg
  - thumbnails/300x300/image_0.webp
  - thumbnails/600x600/image_0.webp
  
/avatars/
  - {userId}.jpg
```

---

## Security Requirements

1. **Password Hashing:** Use bcrypt with salt rounds ≥ 10
2. **JWT Tokens:** 
   - Access token expiry: 15 minutes
   - Refresh token expiry: 7 days
3. **HTTPS Only:** All API endpoints must use HTTPS
4. **Rate Limiting:** 
   - Authentication endpoints: 5 requests/minute
   - Regular endpoints: 100 requests/minute
   - Admin endpoints: 200 requests/minute
5. **Input Validation:** Validate and sanitize all user inputs
6. **SQL Injection Prevention:** Use parameterized queries
7. **CORS:** Configure appropriate CORS headers

---

## Pagination

All list endpoints support pagination:

**Query Parameters:**
- `limit`: Number of items (max: 100, default: 20)
- `offset`: Starting position (default: 0)

**Response:**
```json
{
  "success": true,
  "data": {
    "items": [...],
    "total": 500,
    "limit": 20,
    "offset": 0,
    "hasMore": true
  }
}
```

---

## WebSockets (Optional - Future Enhancement)

For real-time features:

### Order Status Updates
```
ws://api.norden.com/ws/orders/{orderId}
```

### Admin Notifications
```
ws://api.norden.com/ws/admin/notifications
```

---

## Testing Requirements

1. **Unit Tests:** 80% code coverage minimum
2. **Integration Tests:** All API endpoints
3. **Load Testing:** Support 1000 concurrent users
4. **Security Testing:** OWASP Top 10 vulnerabilities

---

## API Versioning

- Current version: `v1`
- Version in URL: `/v1/products`
- Breaking changes require new version: `v2`

---

## Contact

For questions or clarifications, contact:
- **Developer:** Ali Abou Ali
- **Email:** aliabouali2005@gmail.com

---

## License

© 2025 Norden Luxury E-Commerce. All rights reserved.

