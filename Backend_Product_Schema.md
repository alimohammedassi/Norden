# Product JSON Schema for Backend

This document specifies the exact JSON structure and data types the front-end application (NORDEN) expects when fetching products from the backend API.

## Expected JSON Object

When the backend returns a single product or a list of products, each product object MUST follow this structure to be correctly parsed by the frontend `Product.fromJson()` model without causing null errors.

```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "price": 299.99,
  "category": "string",
  "images": [
    "string",
    "string"
  ],
  "colors": [
    "string",
    "string"
  ],
  "sizes": [
    "string",
    "string"
  ],
  "isNew": true,
  "isFeatured": false,
  "stock": 15,
  "rating": 4.8,
  "reviewCount": 128,
  "season": "string",
  "createdAt": "2026-03-16T10:00:00.000Z",
  "updatedAt": "2026-03-16T12:00:00.000Z"
}
```

## Field Definitions & Rules

| Field | Type | Required | Description | Default (if null) |
| :--- | :--- | :--- | :--- | :--- |
| **`id`** | `String` | Yes | The unique identifier of the product. | `""` |
| **`name`** | `String` | Yes | The display name of the product. | `""` |
| **`description`** | `String` | Yes | A detailed description of the product. | `""` |
| **`price`** | `Double` | Yes | The price of the product. | `0.0` |
| **`category`** | `String` | Yes | Product category (e.g., 'Blazers', 'Coats', 'Suits'). | `""` |
| **`images`** | `Array<String>` | Yes | Array of image URLs (valid HTTP/HTTPS links prefered). | `[]` |
| **`colors`** | `Array<String>` | Yes | Array of available color names or hex codes. | `[]` |
| **`sizes`** | `Array<String>` | Yes | Array of available sizes (e.g., "S", "M", "L", "XL"). | `[]` |
| **`isNew`** | `Boolean` | No | Flag indicating if this is a new arrival. | `false` |
| **`isFeatured`** | `Boolean` | No | Flag indicating if this should show in featured sections. | `false` |
| **`stock`** | `Int` | No | The current inventory count. | `0` |
| **`rating`** | `Double` | No | Average product rating out of 5. | `4.8` |
| **`reviewCount`**| `Int` | No | Total number of reviews. | `0` |
| **`season`** | `String` | No | The season tag: `"winter"`, `"summer"`, or `"all"`. | `"all"` |
| **`createdAt`**| `String` | No | ISO-8601 formatted Datetime string. | `Current DateTime` |
| **`updatedAt`**| `String` | No | ISO-8601 formatted Datetime string. | `Current DateTime` |

## Important Notes for the Backend Developer:
1. **Arrays and Lists:** The `images`, `colors`, and `sizes` fields MUST return as Arrays `[]` even if they are empty. Returning `null` instead of an array might cause parsing issues if not handled directly.
2. **Numbers:** The `price` and `rating` fields will be parsed to `double` in Dart. They can be sent as integers (e.g., `200`) or floats (`200.5`), but never as Strings (`"200"`).
3. **Dates:** `createdAt` and `updatedAt` MUST ideally be valid `ISO-8601` strings. If they are sent as null, the frontend will fallback to the exact local time the object was parsed.
4. **Boolean Flags:** `isNew` and `isFeatured` control UI badges and sections. Ensure these are explicitly evaluated on the backend.
