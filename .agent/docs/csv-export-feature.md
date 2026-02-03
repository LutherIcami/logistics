# CSV Export Feature - Documentation

## 🎯 Overview

Export filtered orders to CSV format for reporting, record-keeping, and analysis. This feature allows admins to download a spreadsheet with all completed order details based on active filters.

---

## ✨ Feature Details

### **What Gets Exported**

The CSV file includes **14 columns** with comprehensive order data:

| Column | Description | Example |
|--------|-------------|---------|
| Order ID | Unique order identifier | ORD-12345678 |
| Customer | Customer name | ABC Corporation |
| Pickup Location | Origin address | Nairobi Warehouse |
| Delivery Location | Destination address | Mombasa Port |
| Cargo Type | Type of goods | Electronics |
| Cargo Weight (kg) | Weight in kilograms | 50.5 |
| Distance (km) | Route distance | 450.2 |
| Total Cost (KES) | Order amount | 15000.00 |
| Delivery Date | Completion date | 28/1/2026 |
| Tracking Number | Shipment tracking ID | TRK-98765 |
| Driver | Assigned driver name | John Doe |
| Vehicle | Vehicle registration | KAA 123X |
| Status | Order status | Delivered |
| Invoiced | Has invoice? | Yes / No |

---

## 🎨 User Interface

### **Export Button Location**
- **App Bar** (top right)
- **Icon**: Download icon (⬇️)
- **Tooltip**: "Export to CSV"
- **State**: Disabled when no orders to export (grey), enabled when orders available (normal)

### **Visual Feedback**

**Success:**
```
✅ Exported 25 orders to Downloads
[OK]
```
- Green snackbar
- Shows count of exported orders
- 4-second duration

**Empty List:**
```
⚠️ No orders to export
```
- Orange snackbar

**Error:**
```
❌ Export failed: [error message]
```
- Red snackbar

---

## 📂 File Details

### **Filename Format**
```
completed_orders_[timestamp].csv
```

**Example:**
```
completed_orders_1738593425678.csv
```

### **File Location**
- **Android**: `/storage/emulated/0/Download/`
- **iOS/Desktop**: System Downloads folder

---

## 🔧 How to Use

### **Basic Export (All Completed Orders)**
1. Navigate to **Finance → Invoices → "+" → "From Order"**
2. Wait for orders to load
3. Click **Download icon** (⬇️) in app bar
4. Wait for confirmation message
5. Open **Downloads** folder to find CSV

### **Filtered Export (Specific Orders)**

**Export This Week's Orders:**
1. Click **"Date Range"** chip
2. Select **last 7 days**
3. See filtered count (e.g., "5 of 45 orders")
4. Click **Download icon** (⬇️)
5. Get CSV with only those 5 orders

**Export Un-invoiced Orders:**
1. Keep **"Hiding Invoiced"** toggle ON (default)
2. See only orders without invoices
3. Click **Download icon** (⬇️)
4. Get CSV of pending orders

**Export Customer-Specific Orders:**
1. Type customer name in search: "ABC Corp"
2. See filtered results
3. Click **Download icon** (⬇️)
4. Get CSV for that customer only

---

## 📊 Use Cases

### **Use Case 1: Month-End Reporting**
**Goal:** Export all deliveries from last month for accounting

**Steps:**
1. Click "Date Range"
2. Select first and last day of previous month
3. Toggle "Hiding Invoiced" **OFF** (show all)
4. Click download icon
5. Get complete month's data

**Output:** CSV with all orders from that month, marked as invoiced or not

---

### **Use Case 2: Customer Billing Review**
**Goal:** Get all orders for a specific customer to create summary invoice

**Steps:**
1. Search: "XYZ Trading"
2. See all their orders
3. Click download icon
4. Open CSV in Excel/Sheets

**Benefit:** Have complete customer history for billing discussion

---

### **Use Case 3: Un-invoiced Orders Report**
**Goal:** Weekly report of orders that still need invoicing

**Steps:**
1. Set date range to "This Week"
2. Keep "Hide Invoiced" ON
3. Click download icon
4. Send CSV to finance team

**Benefit:** Track invoicing completion rate

---

### **Use Case 4: Data Analysis**
**Goal:** Analyze delivery patterns, popular routes, average cargo weight

**Steps:**
1. Export all orders (no filters)
2. Open CSV in Excel/Google Sheets
3. Create pivot tables, charts
4. Analyze trends

**Columns Useful For:**
- Route analysis (pickup → delivery)
- Weight distribution (cargo weight)
- Revenue analysis (total cost)
- Driver performance (driver column)

---

## 🎓 CSV Power Tips

### **Opening in Excel**
1. Open Excel
2. File → Import → CSV
3. Select the downloaded file
4. Choose "Comma" as delimiter
5. Import

### **Opening in Google Sheets**
1. Open Google Sheets
2. File → Import
3. Upload → Select file from Downloads
4. Import

### **Filtering After Export**
Once in Excel/Sheets:
- Use **AutoFilter** on headers
- Sort by any column
- Create pivot tables
- Add formulas (e.g., SUM of Total Cost)

---

## 🔒 Data Privacy

### **What's Included**
- ✅ Order details (routes, cargo, dates)
- ✅ Customer names (for your records)
- ✅ Driver and vehicle info
- ✅ Financial data (costs)

### **What's NOT Included**
- ❌ Customer contact info (phone, email)
- ❌ Driver personal details
- ❌ Order IDs for completed invoices (just "Yes/No" flag)

### **Security Notes**
- CSV files are stored **locally** on device
- **Not uploaded** to cloud automatically
- **Delete** old exports to save space
- **Be careful** when sharing (contains financial data)

---

## 📈 Export Statistics

### **File Size Estimates**
- 10 orders: ~2 KB
- 100 orders: ~15 KB
- 1,000 orders: ~150 KB

Very lightweight! Easy to email or upload.

### **Export Speed**
- 10-50 orders: **Instant** (< 1 second)
- 100-500 orders: **Fast** (1-2 seconds)
- 1000+ orders: **Quick** (2-5 seconds)

---

## 🛠️ Troubleshooting

### **Problem: "No orders to export"**
**Cause:** Filters are too restrictive or no completed orders

**Solution:**
- Clear filters (date range, search)
- Toggle "Show All" to include invoiced orders
- Check if any orders are completed

### **Problem: "Export failed"**
**Cause:** Permission issue or storage full

**Solution:**
1. Check storage space (need a few KB free)
2. Grant storage permission to app (if prompted)
3. Try again
4. Contact support if persists

### **Problem: Can't find the file**
**Cause:** Downloaded but can't locate

**Solution:**
- Check **Downloads** folder (file manager)
- Look for `completed_orders_*.csv`
- Sort by "Date Modified" (newest first)
- File name has timestamp for uniqueness

---

## 💡 Pro Tips for Admins

1. **Export regularly** - Weekly snapshots for records
2. **Name your exports** - Rename to meaningful names like "Jan_2026_Orders.csv"
3. **Backup important exports** - Upload to Google Drive or OneDrive
4. **Use filters strategically** - Export only what you need for specific reports
5. **Compare exports** - Month-over-month growth, customer trends
6. **Share with stakeholders** - Easy format for management reports

---

## 🔮 Future Enhancements

Potential improvements:
- **Custom column selection** - Choose which columns to include
- **PDF export** - Formatted report instead of CSV
- **Email directly** - Send CSV to recipients from app
- **Scheduled exports** - Auto-export weekly/monthly
- **Cloud sync** - Auto-upload to Google Drive/Dropbox
- **Chart generation** - Visual reports with graphs

---

## 📋 Technical Details

### **Format**
- **File Type**: CSV (Comma-Separated Values)
- **Encoding**: UTF-8
- **Delimiter**: Comma (,)
- **Line Endings**: CRLF (\\r\\n)

### **Compatibility**
- ✅ Microsoft Excel (all versions)
- ✅ Google Sheets
- ✅ LibreOffice Calc
- ✅ Numbers (Mac)
- ✅ Any text editor

### **Dependencies**
- `csv` package (v6.0.0) - CSV formatting
- `path_provider` package (v2.1.5) - File system access

---

## 📁 Example CSV Output

```csv
Order ID,Customer,Pickup Location,Delivery Location,Cargo Type,Cargo Weight (kg),Distance (km),Total Cost (KES),Delivery Date,Tracking Number,Driver,Vehicle,Status,Invoiced
ORD-12345,ABC Corp,Nairobi,Mombasa,Electronics,50.5,450.2,15000.00,28/1/2026,TRK-98765,John Doe,KAA 123X,Delivered,Yes
ORD-67890,XYZ Traders,Kisumu,Nakuru,Apparel,30.0,200.1,10000.00,29/1/2026,TRK-54321,Jane Smith,KAB 456Y,Delivered,No
```

When opened in Excel, this displays as a neat table with sortable columns!

---

**Implementation Date:** 2026-02-03  
**Status:** ✅ Complete and Ready for Use  
**Feature:** CSV Export for Filtered Orders
