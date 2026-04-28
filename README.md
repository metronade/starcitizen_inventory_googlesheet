# 🚀 Star Citizen Inventory Manager (Google Sheets)

A fully automated Google Sheet for managing your Star Citizen component inventory. The script fetches the latest module data directly from the live API (SC-Verse) and offers smart features like auto-fill, dynamic filtering, and automatic sorting.

## ✨ Features

* **Live API Connection:** Fetches over 340+ components (Shields, Quantum Drives, Coolers, etc.) directly from the API.
* **Smart Auto-Fill:** Simply select the name of a module, and the script automatically fills in the *Type, Class, Grade*, and *Size* for you.
* **Multi-Filter:** If you select, for example, Size `3` and Class `Military` in an empty row, the name dropdown will only show you military size 3 modules.
* **Auto-Merge & Sorting:** If you add a module you already own, the quantity is automatically added up, and the list is neatly sorted.
* **Auto-Delete:** Set the quantity to `0` or delete the module's name, and the entire row will magically disappear.
* **Direct Wiki Links:** Automatically generates a clickable link to *starcitizen.tools* for every item in your inventory.

---

## 🛠️ Installation & Setup

1. Open a completely new, empty Google Sheet (just type `sheets.new` into your browser's address bar).
2. In the top menu, click on **Extensions** > **Apps Script**.
3. Delete all the existing text in the editor and paste the provided script code.
4. Save the script using the floppy disk icon (or press `Ctrl + S`).
5. In the top toolbar, select the function `setupStarCitizenInventory` from the dropdown and click **Run**.
6. *Important:* Google will ask for permissions the first time. Click on: *Review permissions -> Select your Google Account -> Advanced (at the bottom) -> Go to Untitled project (unsafe) -> Allow.*
7. Close the Apps Script tab. Your sheet is now fully set up and ready to go!

---

## 📖 User Guide

### ➕ Add New Modules (Quick Method)
In an empty row, simply click the dropdown field under **Name**. Select your module from the list. The system will auto-fill all the stats, assume a default quantity of "1", and instantly sort the item into your inventory.

### 🔍 Find Modules (Filter Method)
If you don't know the exact name of a module, use the filters! In an empty row, select the Type (e.g., `QuantumDrive`) and the Size (e.g., `2`). When you click the dropdown under **Name** now, it will only suggest Size 2 Quantum Drives from the database.

### 🗑️ Delete Modules
If you sell a module or lose it, you have two quick ways to remove it from your sheet:
* Click on the number under "Anzahl" (Quantity) and type a `0`.
* *Or:* Select the name of the module and press the `Delete` or `Backspace` key.
The row will delete itself automatically and clean up the list.

### 🔄 Update Database (New Patch)
When Star Citizen releases a new patch and new components are added to the game, you don't need to reinstall the script!
1. In the top Google Sheets menu, click the new custom button **🚀 Star Citizen**.
2. Select **🔄 Datenbank aus API aktualisieren** (Update database from API).
3. The script will quietly download the latest data in the background and update all your dropdown menus with the newest items.
