# NORDEN – Maison de Luxe: Complete Backend API Specification

> **Base URL:** `http://<server>:5129/api`  
> All endpoints require `Content-Type: application/json`.  
> Protected endpoints require `Authorization: Bearer <access_token>`.

---

## Authentication

### POST /auth/register

Create a new user account.

**Request body:**

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "phone": "+1234567890"
}
```

**Response `201`:**

```json
{
  "user": { "id": "uuid", "name": "John Doe", "email": "john@example.com" },
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token"
}
```

---

### POST /auth/login

Log in with email + password.

**Request body:**

```json
{
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

**Response `200`:**

```json
{
  "user": { "id": "uuid", "name": "John Doe", "email": "john@example.com" },
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token"
}
```

---

### POST /auth/google

Verify a Google ID token and issue JWT.

**Request body:**

```json
{ "idToken": "google_id_token" }
```

**Response `200`:** Same as login.

---

### POST /auth/refresh

Refresh access token.

**Request body:**

```json
{ "refreshToken": "refresh_token" }
```

**Response `200`:**

```json
{ "accessToken": "new_jwt_token", "refreshToken": "new_refresh_token" }
```

---

### POST /auth/logout _(protected)_

Invalidate refresh token.

**Response `204`:** No body.

---

## Products

### GET /products

Get paginated product list.

**Query params:**
| Param | Type | Description |
|-------|------|-------------|
| `category` | string | Filter by category slug |
| `season` | string | `winter`, `summer`, or `all` |
| `isFeatured` | boolean | Show featured only |
| `isNew` | boolean | Show new arrivals only |
| `search` | string | Full-text search |
| `minPrice` | number | Minimum price |
| `maxPrice` | number | Maximum price |
| `limit` | int | Page size (default: 20) |
| `offset` | int | Pagination offset (default: 0) |

**Response `200`:**

```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Double-breasted Blazer",
      "description": "...",
      "price": 299.99,
      "category": "Blazers",
      "season": "winter",
      "rating": 4.9,
      "reviewCount": 128,
      "images": ["https://cdn.norden.com/products/img1.jpg"],
      "colors": ["Black", "Navy"],
      "sizes": ["S", "M", "L", "XL"],
      "isNew": true,
      "isFeatured": true,
      "stock": 15,
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-15T00:00:00Z"
    }
  ],
  "total": 100,
  "limit": 20,
  "offset": 0
}
```

---

### GET /products/:id

Get single product by ID.

**Response `200`:** Single product object (same structure as above).

---

## Categories

### GET /categories

Get all categories, optionally filtered by season.

**Query params:**
| Param | Type | Description |
|-------|------|-------------|
| `season` | string | `winter`, `summer`, or omit for all |

**Response `200`:**

```json
{
  "data": [
    {
      "id": "blazers",
      "name": "Blazers",
      "slug": "blazers",
      "season": "winter",
      "icon": "local_mall"
    },
    { "id": "coats", "name": "Coats", "slug": "coats", "season": "winter" },
    { "id": "suits", "name": "Suits", "slug": "suits", "season": "all" },
    {
      "id": "dress-shirts",
      "name": "Dress Shirts",
      "slug": "dress-shirts",
      "season": "all"
    },
    {
      "id": "trousers",
      "name": "Trousers",
      "slug": "trousers",
      "season": "all"
    },
    {
      "id": "accessories",
      "name": "Accessories",
      "slug": "accessories",
      "season": "all"
    }
  ]
}
```

---

## Seasons

### GET /seasons

Get all seasons.

**Response `200`:**

```json
{
  "data": [
    {
      "id": "winter",
      "name": "Winter Collection",
      "slug": "winter",
      "description": "...",
      "bannerImageUrl": "https://..."
    },
    {
      "id": "summer",
      "name": "Summer Collection",
      "slug": "summer",
      "description": "...",
      "bannerImageUrl": "https://..."
    }
  ]
}
```

---

## Wishlist _(all routes protected)_

### GET /wishlist

Get current user's wishlist.

**Response `200`:**

```json
{
  "data": [
    {
      "id": "uuid",
      "productId": "product_uuid",
      "productName": "Double-breasted Blazer",
      "price": 299.99,
      "imageUrl": "https://cdn.norden.com/products/img1.jpg",
      "category": "Blazers",
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T00:00:00Z"
    }
  ]
}
```

### POST /wishlist

Add product to wishlist.

**Request body:** `{ "productId": "uuid" }`

**Response `201`:** The created wishlist item.

### DELETE /wishlist/:productId

Remove product from wishlist.

**Response `204`:** No body.

---

## Cart _(all routes protected)_

### GET /cart

Get current user's cart.

**Response `200`:**

```json
{
  "data": {
    "items": [
      {
        "id": "cart_item_uuid",
        "productId": "product_uuid",
        "productName": "Double-breasted Blazer",
        "price": 299.99,
        "quantity": 2,
        "imageUrl": "https://cdn.norden.com/img1.jpg",
        "selectedColor": "Black",
        "selectedSize": "M"
      }
    ],
    "itemCount": 2,
    "subtotal": 599.98
  }
}
```

### POST /cart

Add item to cart.

**Request body:**

```json
{
  "productId": "uuid",
  "quantity": 1,
  "selectedColor": "Black",
  "selectedSize": "M"
}
```

**Response `201`:** Updated cart.

### PUT /cart/:itemId

Update item quantity.

**Request body:** `{ "quantity": 3 }`

**Response `200`:** Updated cart.

### DELETE /cart/:itemId

Remove item from cart.

**Response `204`:** No body.

### DELETE /cart

Clear entire cart.

**Response `204`:** No body.

---

## Orders _(all routes protected)_

### GET /orders

Get order history for current user.

**Response `200`:**

```json
{
  "data": [
    {
      "id": "order_uuid",
      "status": "pending",
      "totalAmount": 699.98,
      "items": [
        {
          "productId": "uuid",
          "productName": "...",
          "quantity": 2,
          "price": 299.99
        }
      ],
      "address": { "street": "...", "city": "...", "country": "..." },
      "paymentMethod": "card",
      "createdAt": "2025-02-01T00:00:00Z"
    }
  ]
}
```

### POST /orders

Place a new order.

**Request body:**

```json
{
  "addressId": "address_uuid",
  "paymentMethod": "card",
  "cardToken": "stripe_token_or_null",
  "promoCode": "WINTER25"
}
```

**Response `201`:**

```json
{
  "id": "order_uuid",
  "status": "confirmed",
  "orderNumber": "ND-20250201-0042",
  "totalAmount": 699.98,
  "estimatedDelivery": "2025-02-08"
}
```

### GET /orders/:id

Get single order details.

**Response `200`:** Full order object.

---

## Addresses _(all routes protected)_

### GET /addresses

Get all saved addresses for current user.

### POST /addresses

Save a new address.

**Request body:**

```json
{
  "label": "Home",
  "name": "John Doe",
  "street": "123 Luxury Ave",
  "city": "Paris",
  "state": "Île-de-France",
  "country": "France",
  "postalCode": "75001",
  "phone": "+33123456789",
  "isDefault": true
}
```

### PUT /addresses/:id

Update address.

### DELETE /addresses/:id

Delete address.

---

## Reviews _(all routes protected)_

### GET /reviews/product/:productId

Get reviews for a product.

**Response `200`:**

```json
{
  "data": [
    {
      "id": "uuid",
      "userId": "uuid",
      "userName": "John D.",
      "rating": 5,
      "comment": "...",
      "createdAt": "..."
    }
  ],
  "averageRating": 4.9,
  "totalReviews": 128
}
```

### POST /reviews

Submit a review.

**Request body:**

```json
{
  "productId": "uuid",
  "rating": 5,
  "comment": "Exceptional quality and fit."
}
```

**Response `201`:** Created review.

---

## Profile _(all routes protected)_

### GET /profile

Get current user's profile.

**Response `200`:**

```json
{
  "id": "uuid",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "avatarUrl": "https://cdn.norden.com/avatars/uuid.jpg"
}
```

### PUT /profile

Update profile.

**Request body:** Any subset of `{ "name", "phone", "avatarUrl" }`.

### PUT /profile/password

Change password.

**Request body:**

```json
{ "currentPassword": "old", "newPassword": "new" }
```

---

## Error Responses

All endpoints return a consistent error format:

```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Access token is missing or invalid.",
    "statusCode": 401
  }
}
```

| Status | Code               | Meaning                  |
| ------ | ------------------ | ------------------------ |
| 400    | `VALIDATION_ERROR` | Invalid request body     |
| 401    | `UNAUTHORIZED`     | Missing or expired token |
| 403    | `FORBIDDEN`        | Not allowed              |
| 404    | `NOT_FOUND`        | Resource not found       |
| 409    | `CONFLICT`         | Duplicate resource       |
| 500    | `INTERNAL_ERROR`   | Server error             |
