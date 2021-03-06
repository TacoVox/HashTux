/**
 * Removes illegal characters (intended for cleaning the search term entered by the user)
 * other than normal "word" caracters (including western such as åäö, ü), _, - and numbers.
 * @param str
 * @returns	The string, now containing only reasonable characters
 */
function strip_illegal_characters(str) {
	var pass1 = str.replace("/^[A-Za-z0-9_- \u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF]/gi", "");
	
	// Trim surrounding whitespace 
	var pass2 = pass1.trim();
	
	// Also make sure there's no # character
	return pass2.replace("#", "");
}


/**
 * Check if there are any characters A-Z, 0-9. Used for selecting only trending terms
 * from twitter that have some western characters. A VERY rough filter but should be
 * fine for 99 out of 100 terms.
 */
function contains_legal_characters(str) {
	return /[a-zA-Z]/.test(str);
}


/**
 * Functions for showing and hiding the commercial use box
 */
function showCommercialUseInfo() {
    $('#commercial_use').fadeIn(500);
    $('#commercial_panel').click(function(e) {
        e.stopPropagation();
    });
}

function hideCommercialUseInfo() {
    $('#commercial_use').fadeOut(500);
}
