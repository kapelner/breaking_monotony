var SimmonsGeneral = {
  login : function(){
    //verify integrity and appropriateness of data
    var login = $('user_login_login').value;
    if (login === ''){
      alert('You must provide an email.');
      return false;			
    }
    else if (this.InvalidEmail(login)){
      alert('The email you provided is not valid.');
      return false;
    }
    var pw = $('user_password_login').value;
    if (pw.length < 3){
      alert('You must provide a password longer than three characters.');
      return false;			
    }
    return true;
  },
  
  signup : function(){
    //verify integrity and appropriateness of data
    var login = $('user_login_signup').value;
    if (login === ''){
      alert('You must provide an email.', {'type' : 'error'});
      return false;			
    }
    else if (this.InvalidEmail(login)){
      DsqdAdvAlert.okay_message('The email you provided is not valid.', {'type' : 'error'});
      return false;
    }
    var first_name = $('user_first_name_signup').value;
    if (first_name === ''){
      alert('You must provide a first name.');
      return false;			
    }
    var last_name = $('user_last_name_signup').value;
    if (last_name.length < 3){
      alert('You must provide a legal last name.');
      return false;			
    }
    if ($('user_institution_signup').value === ''){
      alert('You must provide an insitution.');
      return false;			
    }    
    if ($('user_application_signup').length < 20){
      alert('You must describe, in a few words, a bit about what you are going to use DistirbuteEyes for.');
      return false;
    }
    var pw = $('user_password_signup').value;
    if (pw.length < 3){
      alert('You must provide a password longer than three characters.');
      return false;
    } 
    return true;
  },
        
  InvalidEmail : function(email){
    return /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/.test(email) ? false : true;
  }
};
