// serves as an abstract base class for home page app and testing app
var QualificationTest = Class.create();
Object.extend(QualificationTest.prototype, { 

  //static finals
  max_num_choices : 5,
  correct_color : 'rgb(150, 255, 150)',
  incorrect_color : 'rgb(255, 150, 150)',
  unknown_correctness_color : 'rgb(255, 255, 255)',  
  //ivars
  num_questions : null,
  worker_id : null,
  encrypted_hit_id : null,
  mturk_worker_id : null,
  mturk_assignment_id : null,
  
  initialize : function(num_questions, worker_id, encrypted_hit_id, mturk_worker_id, mturk_assignment_id){
    this.num_questions = num_questions;
    this.worker_id = worker_id;
    this.encrypted_hit_id = encrypted_hit_id;
    this.mturk_worker_id = mturk_worker_id;
    this.mturk_assignment_id = mturk_assignment_id;
  },  

  QuestionAnswered : function(question_num, choice, correct){
    //loop over all choices, ensure they are blank
    for (var i = 0; i < this.max_num_choices; i++){
      try {
        $('q_' + question_num + '_' + i).style.backgroundColor = this.unknown_correctness_color;
      } catch (e){}
    }
    
    //mark the user's selection as either positive or negative
    if (correct){
      $('q_' + question_num + '_' + choice).style.backgroundColor = this.correct_color;
    }
    else {
      $('q_' + question_num + '_' + choice).style.backgroundColor = this.incorrect_color;
    }
    
    //now tally up the correct choices and reveal the submit button if all are correct. WARNING: no security
    var num_correct = 0;
    for (var n = 0; n < this.num_questions; n++){
      for (var j = 0; j < this.max_num_choices; j++){
        try {
          if ($('q_' + n + '_' + j).style.backgroundColor == this.correct_color){
            num_correct++;
          }
        } catch (e){}
      }
    }
    
    if (num_correct == this.num_questions){
      $('qualify_worker_button').disabled = false;
    }
    else {
      $('qualify_worker_button').disabled = true;
    }
  },
    
  QualifyWorker : function(){
    //blank out the button, add a spinner
    $('qualify_worker_button').disabled = true;
    $('qualify_worker_button_submit_spinner').update(spinnerHTMLforspanssmall);
    //make the ajax request
    var that = this;
    var r = new Ajax.Request(
      '/training/add_qualified_worker',
      {
        method: 'post',
        //make sure to add all the data:
        parameters: 'worker_id=' + that.worker_id,
        onComplete: function(response){
          document.location = '/training/index?hit_id=' + that.encrypted_hit_id + '&workerId=' + that.mturk_worker_id + '&assignmentId=' + that.mturk_assignment_id;
        }
      }
    );
  }
});
