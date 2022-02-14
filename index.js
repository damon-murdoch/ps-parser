// convert(void): Void
// Checks the input and output
// fields and converts the input
// data object to the inverse type
// depending on what data is provided.
function convert()
{
  // Get the input text area
  let ta_input = document.getElementById('_input');

  // Get the output text area
  let ta_output = document.getElementById('_output');

  // Get the content from the input
  let content_in = ta_input.value;

  try
  {
    // Parse the json from the input content
    let json = JSON.parse(content_in);

    // Get the content from the json
    let content = parseJson(json);

    // Write the output to the output field
    ta_output.value = content;
  }
  catch // Not a json object
  {
    // Get the space number input element
    let in_spaces = document.getElementById('_spaces');

    // Get the number of spaces
    let spaces = parseInt(in_spaces.value);

    // Convert input to json
    let json = parseSets(content_in);

    // Write the json to the output field
    ta_output.value = JSON.stringify(json, null, spaces);
  }
}