function passWord() {
    var testV = 1;
    var pass1 = prompt('Please Enter Your Password', ' ');
    var password = "Óaô»YĎÒ^âo";

    while (testV < 3) {
        if (!pass1)
            history.go(-1);
        if (pass1 == unEncrypt(password)) {
            alert('You Got it Right!');
            window.open('for_lab_members.html');
            break;
        }
        testV += 1;
        var pass1 =
            prompt('Access Denied - Password Incorrect, Please Try Again.', 'Password');
    }
    if (pass1.toLowerCase() != "password" & testV == 3)
        history.go(-1);
    return " ";
}

function unEncrypt(theText) {
    output = new String;
    Temp = new Array();
    Temp2 = new Array();
    TextSize = theText.length;
    for (i = 0; i < TextSize; i++) {
        Temp[i] = theText.charCodeAt(i);
        Temp2[i] = theText.charCodeAt(i + 1);
    }
    for (i = 0; i < TextSize; i = i + 2) {
        output += String.fromCharCode(Temp[i] - Temp2[i]);
    }
    return output;
}