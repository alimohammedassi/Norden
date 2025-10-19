# Cart and Checkout Flow Test Guide

## 🛒 **Testing the Complete Cart & Checkout Flow with Google Maps**

### **Step 1: Add Products to Cart**
1. **Open the app** → Home page loads with sample products
2. **Browse products** → You should see 6 sample products:
   - Vintage Gold Watch ($299.99)
   - Classic Leather Jacket ($599.99)
   - Luxury Silk Scarf ($149.99)
   - Vintage Denim Jeans ($199.99)
   - Elegant Pearl Necklace ($399.99)
   - Vintage Wool Coat ($449.99)
3. **Tap "Add to Cart"** on any product
4. **Verify cart icon** shows item count in header

### **Step 2: View Cart**
1. **Tap cart icon** in header
2. **Verify products** are displayed correctly
3. **Check quantities** and total prices
4. **Test quantity changes** (+ and - buttons)
5. **Test item removal** (trash icon)

### **Step 3: Proceed to Checkout**
1. **Tap "PROCEED TO CHECKOUT"** button
2. **Verify checkout page** loads correctly
3. **Check order summary** shows correct items and totals

### **Step 4: Test Address Selection with Google Maps**
1. **In checkout page** → Look for address section
2. **If no address saved** → Tap "ADD ADDRESS" button
3. **In address form** → Tap "Use Map to Select Location"
4. **Test Google Maps integration:**
   - ✅ Map should load without crashing
   - ✅ Current location button should work (gold button)
   - ✅ Tap anywhere on map to select location
   - ✅ "CONFIRM LOCATION" button should work
   - ✅ Address form should auto-fill with coordinates
5. **Fill remaining fields** (street, city, country, etc.)
6. **Save address** and return to checkout

### **Step 5: Complete Checkout**
1. **Verify selected address** appears in checkout
2. **Select payment method** (Credit/Debit Card or Cash on Delivery)
3. **Review order summary** one final time
4. **Tap "PLACE ORDER"** button
5. **Verify success message** and cart clears

### **Step 6: Test Address Management**
1. **Go to Profile** → Tap profile icon in header
2. **Tap "Addresses"** in profile menu
3. **Test address management:**
   - ✅ View saved addresses
   - ✅ Edit existing addresses
   - ✅ Add new addresses with map picker
   - ✅ Set default address
   - ✅ Delete addresses

## 🎯 **Expected Results**

### **✅ Cart Functionality**
- Products add/remove correctly
- Quantities update properly
- Total calculations are accurate
- Cart persists across navigation

### **✅ Google Maps Integration**
- Map loads without crashes
- Current location detection works
- Location selection works
- Address form auto-fills
- Confirm button works properly

### **✅ Checkout Process**
- Address selection works
- Payment method selection works
- Order summary is accurate
- Order placement succeeds
- Cart clears after successful order

### **✅ Address Management**
- Addresses save to Firestore
- Map picker works for new addresses
- Default address selection works
- Address editing works
- Address deletion works

## 🐛 **Common Issues & Solutions**

### **Map Not Loading**
- Check Google Maps API key in `AndroidManifest.xml`
- Verify NDK version is `27.0.12077973`
- Run `flutter clean && flutter pub get`

### **Current Location Not Working**
- Check location permissions in device settings
- Verify location services are enabled
- Check console for error messages

### **Products Not Showing**
- Verify sample products are loaded
- Check console for Firebase connection errors
- Ensure Firestore is enabled in Firebase Console

### **Cart Not Persisting**
- Check if user is logged in
- Verify Firebase Auth is working
- Check console for Firestore errors

## 📱 **Test on Different Scenarios**

1. **With Internet Connection** - Full functionality
2. **Without Internet** - Graceful fallbacks
3. **Different Screen Sizes** - Responsive design
4. **Different Orientations** - Layout adaptation
5. **Background/Foreground** - State persistence

## 🎉 **Success Criteria**

The test is successful when:
- ✅ All 6 sample products display on home page
- ✅ Cart functionality works perfectly
- ✅ Google Maps loads and functions properly
- ✅ Address selection works with map picker
- ✅ Checkout process completes successfully
- ✅ Address management works in profile
- ✅ No crashes or major errors occur

---

**Note:** This test guide covers the complete user journey from browsing products to completing checkout with the new Google Maps integration for address selection.
