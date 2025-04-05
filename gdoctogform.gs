/**
 * Imports questions from a Google Doc to a Google Form
 * Questions start with "**"
 * Answers start with "##" (first answer is correct by default)
 * If an answer starts with "#!", it overrides the default and becomes the correct answer
 */
function importQuestionsFromDocToForm() {
  // Replace with your actual document ID
  const docId = "1WBNi1JD-HDX0Y2-eVXjKSQN8OQCUUYgABRbc1QaTlyg";
  // Replace with your actual form ID, or create a new form
  const formId = "16QRO5t_xENLISRphGjwEsT3g-_Dd_CS7SG4FI676fV4"; 
  
  // Get the document and its content
  const doc = DocumentApp.openById(docId);
  const body = doc.getBody();
  const text = body.getText();
  
  // Create or open the form
  let form;
  try {
    form = FormApp.openById(formId);
  } catch (e) {
    // Create a new form if the ID doesn't exist
    form = FormApp.create("Questions Form");
    console.log("Created new form with ID: " + form.getId());
  }
  
  // Split the text by "**" to get all questions
  const sections = text.split("**");
  
  // Skip the first element as it's before the first "**"
  for (let i = 1; i < sections.length; i++) {
    const section = sections[i].trim();
    
    // Skip empty sections
    if (!section) continue;
    
    // Find where the question ends and answers begin
    const firstAnswerIndex = section.indexOf("##");
    
    // Skip if there are no answers
    if (firstAnswerIndex === -1) continue;
    
    // Extract the question text
    const questionText = section.substring(0, firstAnswerIndex).trim();
    
    // Skip if question is empty
    if (!questionText) continue;
    
    // Get the answers part
    const answersText = section.substring(firstAnswerIndex);
    
    // Split by "##" or "#!" to get all answers
    const answerParts = answersText.split(/(##|#!)/);
    
    // Filter out the separators and empty parts
    const answers = [];
    let correctAnswerIndex = 0; // Default: first answer is correct
    
    for (let j = 1; j < answerParts.length; j += 2) {
      const separator = answerParts[j];
      const answerText = (answerParts[j + 1] || "").trim();
      
      if (answerText) {
        answers.push(answerText);
        
        // If this answer starts with "#!", mark it as the correct one
        if (separator === "#!") {
          correctAnswerIndex = answers.length - 1;
        }
      }
    }
    
    // Skip if no valid answers
    if (answers.length === 0) continue;
    
    // Shuffle the answers and keep track of the correct answer
    const shuffledAnswers = [...answers];
    const originalCorrectAnswer = answers[correctAnswerIndex];
    
    // Fisher-Yates shuffle algorithm
    for (let i = shuffledAnswers.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffledAnswers[i], shuffledAnswers[j]] = [shuffledAnswers[j], shuffledAnswers[i]];
    }
    
    // Find the new index of the correct answer
    const newCorrectAnswerIndex = shuffledAnswers.indexOf(originalCorrectAnswer);
    
    // Create a multiple choice question
    const item = form.addMultipleChoiceItem();
    item.setTitle(questionText);
    
    // Add all answers using the shuffled array
    const choices = shuffledAnswers.map(answer => 
      item.createChoice(answer, shuffledAnswers.indexOf(answer) === newCorrectAnswerIndex)
    );
    item.setChoices(choices);

    //Set points for the question
    item.setPoints(1);
  }
  
  console.log("Import completed. Processed " + (sections.length - 1) + " question sections.");
}

/**
 * Creates a menu item to run the import function
 */
function onOpen() {
  const ui = DocumentApp.getUi();
  ui.createMenu('Import to Form')
    .addItem('Import Questions', 'importQuestionsFromDocToForm')
    .addToUi();
}