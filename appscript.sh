// ==========================================
// 0. EIGENES MENÜ FÜR GOOGLE SHEETS
// ==========================================
function onOpen() {
  var ui = SpreadsheetApp.getUi();
  ui.createMenu('🚀 Star Citizen')
      .addItem('🔄 Datenbank aus API aktualisieren', 'updateDatabaseFromAPI')
      .addToUi();
}

// ==========================================
// 1. API DATEN ABRUFEN (1:1 OHNE FILTER)
// ==========================================
function fetchApiData() {
  var url = "https://test.sc-verse.dev/api/v1/components";
  
  try {
    var response = UrlFetchApp.fetch(url);
    var json = JSON.parse(response.getContentText());
    
    // Fallback, falls die API die Daten direkt als Array oder in einem "data"-Objekt liefert
    var components = json.data ? json.data : json; 
    var dbData = [];
    
    for (var i = 0; i < components.length; i++) {
      var comp = components[i];
      
      // Nutzt strikt die Original-Namen aus der API
      var type = comp.type; 
      var className = comp.class ? comp.class : "Civilian"; 
      var grade = comp.grade ? comp.grade : "C";
      var size = comp.size ? comp.size : 1;
      
      dbData.push([
        comp.name,
        type,
        className,
        grade,
        size
      ]);
    }
    return dbData;
  } catch (e) {
    SpreadsheetApp.getUi().alert("Fehler beim Abrufen der API: " + e.message);
    return null;
  }
}

// ==========================================
// 2. FUNKTION FÜR DEN MENÜ-BUTTON (Manuelles Update)
// ==========================================
function updateDatabaseFromAPI() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var dbSheet = ss.getSheetByName("Datenbank");
  
  if (!dbSheet) {
    SpreadsheetApp.getUi().alert("Bitte führe zuerst das Setup aus!");
    return;
  }
  
  var dbData = fetchApiData();
  
  if (dbData && dbData.length > 0) {
    dbSheet.clear();
    dbSheet.getRange(1, 1, dbData.length, 5).setValues(dbData);
    SpreadsheetApp.getUi().alert("✅ Datenbank erfolgreich aktualisiert! " + dbData.length + " Module aus der API geladen.");
  }
}

// ==========================================
// 3. DAS INITIALE SETUP
// ==========================================
function setupStarCitizenInventory() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  
  // A: MASTER-DATENBANK ERSTELLEN UND AUS API FÜLLEN
  var dbSheet = ss.getSheetByName("Datenbank");
  if (!dbSheet) { dbSheet = ss.insertSheet("Datenbank"); }
  dbSheet.clear();
  
  var dbData = fetchApiData();
  if (!dbData || dbData.length === 0) {
    dbData = [["Fehler beim API Abruf", "Cooler", "Civilian", "C", 1]]; 
  }
  
  dbSheet.getRange(1, 1, dbData.length, 5).setValues(dbData);
  dbSheet.hideSheet(); 

  // B: LEERES INVENTAR-BLATT AUFBAUEN
  var sheet = ss.getSheetByName("Inventar");
  if (!sheet) { sheet = ss.insertSheet("Inventar"); }
  ss.setActiveSheet(sheet);
  sheet.clear();
  
  var headers = ["Anzahl", "Name", "Typ", "Klasse", "Grade", "Size", "Info-Link"];
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
  sheet.getRange(1, 1, 1, headers.length).setFontWeight("bold").setBackground("#4285f4").setFontColor("white");
  
  var numRows = 999; 

  // C: FESTE SPALTENBREITEN & DYNAMISCHE DROPDOWNS
  sheet.setColumnWidth(1, 80);  
  sheet.setColumnWidth(2, 220);  
  sheet.setColumnWidth(3, 160);  
  sheet.setColumnWidth(4, 120); 
  sheet.setColumnWidth(5, 80);  
  sheet.setColumnWidth(6, 80);  
  sheet.setColumnWidth(7, 130); 
  
  // DYNAMISCHE LISTEN AUS DER API GENERIEREN
  // Dadurch werden neue Typen wie "Radar" oder "WeaponMissile" sofort berücksichtigt
  var allNames = [...new Set(dbData.map(function(row) { return row[0]; }))].sort();
  var allTypes = [...new Set(dbData.map(function(row) { return row[1]; }))].sort();
  var allClasses = [...new Set(dbData.map(function(row) { return row[2]; }))].sort();
  var allGrades = [...new Set(dbData.map(function(row) { return row[3]; }))].sort();
  var allSizes = [...new Set(dbData.map(function(row) { return String(row[4]); }))].sort();

  var ruleName = SpreadsheetApp.newDataValidation().requireValueInList(allNames, true).build();
  sheet.getRange(2, 2, numRows, 1).setDataValidation(ruleName); 
  
  var ruleTyp = SpreadsheetApp.newDataValidation().requireValueInList(allTypes, true).build();
  sheet.getRange(2, 3, numRows, 1).setDataValidation(ruleTyp); 
  
  var ruleKlasse = SpreadsheetApp.newDataValidation().requireValueInList(allClasses, true).build();
  sheet.getRange(2, 4, numRows, 1).setDataValidation(ruleKlasse); 
  
  var ruleGrade = SpreadsheetApp.newDataValidation().requireValueInList(allGrades, true).build();
  sheet.getRange(2, 5, numRows, 1).setDataValidation(ruleGrade); 
  
  var ruleSize = SpreadsheetApp.newDataValidation().requireValueInList(allSizes, true).build();
  sheet.getRange(2, 6, numRows, 1).setDataValidation(ruleSize); 
  
  // D: FORMATIERUNGSREGELN
  var rules = sheet.getConditionalFormatRules();
  var rangeKlasse = sheet.getRange("D2:D1000");
  var rangeGrade = sheet.getRange("E2:E1000");
  
  rules.push(SpreadsheetApp.newConditionalFormatRule().whenTextEqualTo("Military").setBackground("#f4c7c3").setRanges([rangeKlasse]).build());
  rules.push(SpreadsheetApp.newConditionalFormatRule().whenTextEqualTo("Stealth").setBackground("#cfd8dc").setRanges([rangeKlasse]).build());
  rules.push(SpreadsheetApp.newConditionalFormatRule().whenTextEqualTo("Competition").setBackground("#e1bee7").setRanges([rangeKlasse]).build());
  rules.push(SpreadsheetApp.newConditionalFormatRule().whenTextEqualTo("Civilian").setBackground("#bbdefb").setRanges([rangeKlasse]).build());
  rules.push(SpreadsheetApp.newConditionalFormatRule().whenTextEqualTo("Industrial").setBackground("#ffe0b2").setRanges([rangeKlasse]).build()); 
  
  rules.push(SpreadsheetApp.newConditionalFormatRule().whenTextEqualTo("A").setBackground("#b7e1cd").setRanges([rangeGrade]).build());
  rules.push(SpreadsheetApp.newConditionalFormatRule().whenTextEqualTo("B").setBackground("#fce8b2").setRanges([rangeGrade]).build());
  rules.push(SpreadsheetApp.newConditionalFormatRule().whenTextEqualTo("C").setBackground("#f6c244").setRanges([rangeGrade]).build());
  rules.push(SpreadsheetApp.newConditionalFormatRule().whenTextEqualTo("D").setBackground("#e06666").setRanges([rangeGrade]).build());
  sheet.setConditionalFormatRules(rules);
  
  sheet.setFrozenRows(1);
  sheet.getRange("A2:A1000").setHorizontalAlignment("center");
  sheet.getRange("E2:G1000").setHorizontalAlignment("center");
  
  onOpen(); 
}

// ==========================================
// 4. ON-EDIT LOGIK (Auto-Löschen, Multi-Filter, Auto-Fill)
// ==========================================
function onEdit(e) {
  if (!e) return; 
  var sheet = e.source.getActiveSheet();
  var row = e.range.getRow();
  var col = e.range.getColumn();
  
  if (sheet.getName() !== "Inventar" || row <= 1) return;

  // AUTO-LÖSCHEN
  if (e.range.getNumRows() === 1 && e.range.getNumColumns() === 1) {
    if (col === 1 && e.value === "0") {
      sheet.deleteRow(row);
      return; 
    }
    if (col === 2 && !e.value) {
      sheet.deleteRow(row);
      return; 
    }
  }

  // MULTI-FILTERING 
  if (col >= 3 && col <= 6) {
    var dbSheet = e.source.getSheetByName("Datenbank");
    var dbData = dbSheet.getDataRange().getValues();
    
    var filters = sheet.getRange(row, 3, 1, 4).getValues()[0];
    var tFilter = filters[0]; 
    var kFilter = filters[1]; 
    var gFilter = filters[2]; 
    var sFilter = filters[3]; 
    
    var gefundeneNamen = [];
    
    for (var i = 0; i < dbData.length; i++) {
      var dbName = dbData[i][0];
      var dbTyp = dbData[i][1];
      var dbKlasse = dbData[i][2];
      var dbGrade = dbData[i][3];
      var dbSize = dbData[i][4];
      
      var match = true;
      if (tFilter && dbTyp !== tFilter) match = false;
      if (kFilter && dbKlasse !== kFilter) match = false;
      if (gFilter && dbGrade !== gFilter) match = false;
      if (sFilter && dbSize.toString() !== sFilter.toString()) match = false;
      
      if (match && dbName) { gefundeneNamen.push(dbName); }
    }
    
    var nameZelle = sheet.getRange(row, 2);
    if (gefundeneNamen.length > 0) {
      var ruleName = SpreadsheetApp.newDataValidation().requireValueInList(gefundeneNamen, true).build();
      nameZelle.setDataValidation(ruleName);
    } else {
      nameZelle.clearDataValidations();
    }
  }
  
  // AUTO-FILL & AUTO-MERGE 
  if (col === 2 && e.value) {
    var selectedName = e.value;
    
    var dbSheet = e.source.getSheetByName("Datenbank");
    var dbData = dbSheet.getDataRange().getValues();
    var rowDataToFill = null;
    
    for (var i = 0; i < dbData.length; i++) {
      if (dbData[i][0] === selectedName) {
        rowDataToFill = dbData[i]; 
        break;
      }
    }
    
    if (rowDataToFill) {
      sheet.getRange(row, 3, 1, 4).setValues([[rowDataToFill[1], rowDataToFill[2], rowDataToFill[3], rowDataToFill[4]]]);
    }
    
    SpreadsheetApp.flush();
    runAutoMergeAndSort(sheet);
  }
}

// ==========================================
// 5. SORTIER-, ZUSAMMENFÜGUNGS- UND LINK-FUNKTION
// ==========================================
function runAutoMergeAndSort(sheet) {
  var lastRow = sheet.getLastRow();
  if (lastRow <= 1) return;
  
  var range = sheet.getRange(2, 1, lastRow - 1, 6);
  var data = range.getValues();
  
  var uniqueItems = {};
  var rowsToDelete = [];
  
  for (var i = 0; i < data.length; i++) {
    var anzahl = data[i][0] === "" ? 1 : Number(data[i][0]); 
    var name = data[i][1];                
    var typ = data[i][2];                 
    var klasse = data[i][3];              
    var grade = data[i][4];               
    var size = data[i][5];                
    
    if (!name) continue;
    
    var key = name + "|" + typ + "|" + klasse + "|" + grade + "|" + size;
    
    if (uniqueItems[key] !== undefined) {
      var originalIndex = uniqueItems[key];
      data[originalIndex][0] = Number(data[originalIndex][0] === "" ? 1 : data[originalIndex][0]) + anzahl;
      rowsToDelete.push(i + 2); 
    } else {
      data[i][0] = anzahl; 
      uniqueItems[key] = i;
    }
  }
  
  range.setValues(data);
  
  for (var j = rowsToDelete.length - 1; j >= 0; j--) {
    sheet.deleteRow(rowsToDelete[j]);
  }
  
  var newLastRow = sheet.getLastRow();
  if (newLastRow > 1) {
    var finalRange = sheet.getRange(2, 1, newLastRow - 1, 7);
    finalRange.sort([
      {column: 3, ascending: true},  
      {column: 4, ascending: false}, 
      {column: 5, ascending: true},  
      {column: 6, ascending: true}   
    ]);
    
    var nameRange = sheet.getRange(2, 2, newLastRow - 1, 1);
    var nameData = nameRange.getValues();
    var linkRange = sheet.getRange(2, 7, newLastRow - 1, 1);
    
    var richTexts = [];
    for (var k = 0; k < nameData.length; k++) {
      var modName = nameData[k][0];
      if (modName) {
        var url = "https://starcitizen.tools/" + String(modName).replace(/ /g, "_");
        var rt = SpreadsheetApp.newRichTextValue().setText("🌐 Wiki").setLinkUrl(url).build();
        richTexts.push([rt]);
      } else {
        richTexts.push([SpreadsheetApp.newRichTextValue().setText("").build()]);
      }
    }
    linkRange.setRichTextValues(richTexts);
  }
}