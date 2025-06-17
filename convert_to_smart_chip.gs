// Convert google drive folder to smart chip to the next column
function convertToSmartChip() {
  // Get the active spreadsheet and sheet
  const sheet = SpreadsheetApp.getActiveSheet();
  const range = sheet.getActiveRange();
  
  // Check if a range is selected
  if (!range) {
    SpreadsheetApp.getUi().alert('Please select a cell or range of cells first.');
    return;
  }
  
  // Get the values from the selected range
  const values = range.getValues();
  const numRows = range.getNumRows();
  const numCols = range.getNumColumns();
  
  // Process each cell in the selection
  for (let row = 0; row < numRows; row++) {
    for (let col = 0; col < numCols; col++) {
      const cellValue = values[row][col];
      
      // Check if the cell contains a Google Drive folder link
      if (typeof cellValue === 'string' && isGoogleDriveFolderLink(cellValue)) {
        try {
          // Extract folder ID from the URL
          const folderId = extractFolderIdFromUrl(cellValue);
          
          if (folderId) {
            // Get the folder to verify it exists and get its name
            const folder = DriveApp.getFolderById(folderId);
            const folderName = folder.getName();
            
            // Create the smart chip using rich text
            const richText = SpreadsheetApp.newRichTextValue()
              .setText(folderName)
              .setLinkUrl(cellValue)
              .build();
            
            // Apply the rich text to the next column (one column to the right)
            const targetCell = sheet.getRange(range.getRow() + row, range.getColumn() + col + 1);
            targetCell.setRichTextValue(richText);
            
            console.log(`Created smart chip in next column (${range.getRow() + row}, ${range.getColumn() + col + 1}): ${folderName}`);
          }
        } catch (error) {
          console.error(`Error processing cell (${range.getRow() + row}, ${range.getColumn() + col + 1}):`, error);
          // Continue processing other cells even if one fails
        }
      }
    }
  }
  
  // Show completion message
  SpreadsheetApp.getUi().alert('Smart chips created in the next column!');
}

function isGoogleDriveFolderLink(url) {
  // Check if the URL is a Google Drive folder link
  const drivePatterns = [
    /^https:\/\/drive\.google\.com\/drive\/folders\/([a-zA-Z0-9-_]+)/,
    /^https:\/\/drive\.google\.com\/drive\/u\/\d+\/folders\/([a-zA-Z0-9-_]+)/,
    /^https:\/\/drive\.google\.com\/open\?id=([a-zA-Z0-9-_]+)/
  ];
  
  return drivePatterns.some(pattern => pattern.test(url));
}

function extractFolderIdFromUrl(url) {
  // Extract folder ID from various Google Drive URL formats
  const patterns = [
    /\/folders\/([a-zA-Z0-9-_]+)/,
    /[\?&]id=([a-zA-Z0-9-_]+)/
  ];
  
  for (const pattern of patterns) {
    const match = url.match(pattern);
    if (match) {
      return match[1];
    }
  }
  
  return null;
}

// Optional: Function to test if the script has necessary permissions
function testPermissions() {
  try {
    const sheet = SpreadsheetApp.getActiveSheet();
    const testFolder = DriveApp.getRootFolder();
    console.log('Permissions test passed');
    SpreadsheetApp.getUi().alert('Script permissions are properly configured!');
  } catch (error) {
    console.error('Permission error:', error);
    SpreadsheetApp.getUi().alert('Error: ' + error.toString());
  }
}
