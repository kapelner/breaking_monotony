// serves as an abstract base class for home page app and testing app
var Training = Class.create();
Object.extend(Training.prototype, { 
  
  //constants
  colors : ["rgb(255, 255, 0)", "rgb(255, 0, 0)", "rgb(0, 0, 255)", "rgb(255, 0, 255)", "rgb(0, 128, 128)"],
  white : "rgb(255, 255, 255)",
  black : "rgb(0, 0, 0)",
  delete_radius : 10,  
  num_total_error_messages_for_points_being_too_close : 2,
  initial_magnification : 0.8,
  constant_min_radius_away_for_positive_points : 8, //based on initial_magnification
  
  //ivars
  phenotype_data : new Hash(), //name --> hash of points
  phenotype_colors : new Hash(),
  width : null,
  height : null,
  ctx : null,
  training_image : null,
  magnification : null,
  total_points : 0,
  total_positive_points : 0,
  num_error_messages_for_positive_points_being_too_close : 0,
  enc_identification_id : null,
  log : new Array(),
  logging_not_setup_yet : true,
  phen : null,
  
  initialize : function(enc_identification_id, phen){
    //standard population of object's ivars:
    this.enc_identification_id = enc_identification_id;
    this.phen = phen;
    //now display the image:
    this.magnification = this.initial_magnification; //set to initial constant
    this.mark_magnification();
    this.original_draw_image();
  },
  
  original_draw_image : function(){
    this.ctx = $("canvas").getContext("2d");
    $('original_training_image').onload = function(){
      this.reset_image();
    }.bind(this);    
  },
  
  max_magnification : 2.0,
  magnifiation_bump_interval : 0.2,
  bump_up_magnification : function(){
    //jet if we're over the limit
    if (this.magnification >= this.max_magnification){
      return;
    }
    //bump up the magnification and reset the image
    this.magnification += this.magnifiation_bump_interval;
    this.magnification = Math.round(this.magnification * 100) / 100;
    this.reset_image();
    this.mark_magnification();
    //log it:
    this.log_action('bump_up_magnification', this.magnification);
  },
  
  min_magnification : 0.8,
  bump_down_magnification : function(){
    //jet if we're under the limit
    if (this.magnification <= this.min_magnification){
      return;
    }
    //bump up the magnification and reset the image
    this.magnification -= this.magnifiation_bump_interval;
    this.magnification = Math.round(this.magnification * 100) / 100;
    this.reset_image();
    this.mark_magnification();
    //log it:
    this.log_action('bump_down_magnification', this.magnification);
  },

  mark_magnification : function(){
    $('magnification_level').update(this.magnification + (this.magnification % 1 == 0 ? '.0' : ''));
  },
  
  reset_image : function(){
    //get all convenience anchors
    var canvas = $("canvas");
    this.training_image = $('original_training_image');
    this.ctx = canvas.getContext("2d");
    //set many variables based on magnification
    this.width = canvas.width = this.training_image.width * this.magnification;
    this.height = canvas.height = this.training_image.height * this.magnification;
    this.ctx.drawImage(this.training_image, 0, 0, this.width, this.height);
    this.min_radius_away_for_positive_points = Math.round(this.constant_min_radius_away_for_positive_points * this.magnification * 100) / 100;
    //now draw image itself
    this.ctx.drawImage(this.training_image, 0, 0, this.width, this.height);
    //now we have to redraw all the points
    this.phenotype_data.each(function(pair){
      pair.value.each(function(pt){
        this.draw_star(pt.x * this.magnification, pt.y * this.magnification, this.phenotype_colors.get(pair.key));
      }.bind(this));
    }.bind(this));    
  },
  
  initialize_phenotype : function(name){
    this.phenotype_colors.set(name, this.colors[this.phenotype_colors.size() % this.colors.size()]);
    this.phenotype_data.set(name, new Array());
  },
  
  point : function(e){
   
   var x = e.layerX;
   var y = e.layerY;
   
   console.log("x: " + x + " y: " + y + " button: " + e.button + " which: " + e.which);
   if (e.button == 0){
     this.new_training_point(x, y);
   }
   else if (e.button == 2){
     this.delete_training_points_around(x, y);
   }
   //we got a point, so start logging:
   //start logging if not already done:
   if (this.logging_not_setup_yet){
     this.autolog();
     this.logging_not_setup_yet = false;
   }
  },

  new_training_point : function(x, y){
    //first get which phenotype we're working on
    var phenotype = this.current_phenotype();
    var array = this.phenotype_data.get(phenotype);
    //now ensure that points surrounding this point aren't too close
//    var point_valid = true;
    array.each(function(pt){
      //if the distance function is less than, show error message if necessary, then bail
      if (!pt.check_distance_greater_than(x, y, this.min_radius_away_for_positive_points, this.magnification)){
        if (this.num_error_messages_for_positive_points_being_too_close < this.num_total_error_messages_for_points_being_too_close){
          this.num_error_messages_for_positive_points_being_too_close++;
//          alert("Point was not registered because you may not make new points too close together.");
        }
//        point_valid = false;
      }
    }.bind(this));
//    if (point_valid){
      this.record_point(phenotype, x, y);    
//    }
    //log it:
    this.log_action('new_training_point', x / this.magnification + ',' + y / this.magnification);
  },
  
  record_point : function(phenotype, x, y){
    var data = this.phenotype_data.get(phenotype);
    //place it in array
    data.push(new XYPoint(x / this.magnification, y / this.magnification)); //save the data independent of magnification
    //draw a star there
    this.draw_star(x, y, this.phenotype_colors.get(phenotype));    
    //update the scoreboard
    this.update_scoreboard_goal_text_and_submit_button();
    //make sure evil button disappears
    if (this.total_positive_points + this.total_negative_points > 2){
        $('click_button_for_not_seeing_image').hide();
    }
  },
  
  draw_star : function(x, y, color){
//    console.log("draw_star x:" + x + " y:" + y);
    //round the points
    x = Math.round(x);
    y = Math.round(y);
    //draw the specific color as an outer shell star shape
    this.ctx.fillStyle = color;
    this.ctx.fillRect (x, y - 3, 1, 1);
    this.ctx.fillRect (x, y + 3, 1, 1);
    this.ctx.fillRect (x + 3, y, 1, 1);
    this.ctx.fillRect (x - 3, y, 1, 1);
    this.ctx.fillRect (x, y - 4, 1, 1);
    this.ctx.fillRect (x, y + 4, 1, 1);
    this.ctx.fillRect (x + 4, y, 1, 1);
    this.ctx.fillRect (x - 4, y, 1, 1); 
    this.ctx.fillRect (x - 1, y - 2, 1, 1);
    this.ctx.fillRect (x - 1, y + 2, 1, 1);
    this.ctx.fillRect (x + 1, y - 2, 1, 1);
    this.ctx.fillRect (x + 1, y + 2, 1, 1); 
    this.ctx.fillRect (x - 2, y - 1, 1, 1);
    this.ctx.fillRect (x - 2, y + 1, 1, 1);
    this.ctx.fillRect (x + 2, y - 1, 1, 1);
    this.ctx.fillRect (x + 2, y + 1, 1, 1);
    //now draw some white in the middle
    this.ctx.fillStyle = this.white;
    this.ctx.fillRect (x, y - 2, 1, 1);
    this.ctx.fillRect (x, y + 2, 1, 1);
    this.ctx.fillRect (x + 2, y, 1, 1);
    this.ctx.fillRect (x - 2, y, 1, 1);
    this.ctx.fillRect (x - 1, y - 1, 1, 1);
    this.ctx.fillRect (x - 1, y + 1, 1, 1);
    this.ctx.fillRect (x + 1, y - 1, 1, 1);
    this.ctx.fillRect (x + 1, y + 1, 1, 1);    
    //and a black cross in the center
    this.ctx.fillStyle = this.black;
    this.ctx.fillRect (x, y - 1, 1, 1);
    this.ctx.fillRect (x, y + 1, 1, 1);
    this.ctx.fillRect (x + 1, y, 1, 1);
    this.ctx.fillRect (x - 1, y, 1, 1);    
    this.ctx.fillRect (x, y, 1, 1);    
  },
  
  current_phenotype : function(){
    var phenotype = null;
    if ($('phenotype_form').phenotype.length == undefined){
      phenotype = $('phenotype_form').phenotype.id;
    }
    else {
      for (var i = 0; i < $('phenotype_form').phenotype.length; i++){
        if ($('phenotype_form').phenotype[i].checked == true){
          phenotype = $('phenotype_form').phenotype[i].id;
        }
      }
    }
    return phenotype.replace("phenotype_", "");    
  },

  delete_training_points_around : function(x, y){
    this.phenotype_data.each(function(pair){
      var phenotype = pair.key;
      var array = pair.value;      
      var new_array = new Array();
      //loop through data and find all points near it and excise them from the array
      array.each(function(pt){
        if (pt.check_distance_greater_than(x, y, this.delete_radius, this.magnification)){
          new_array.push(pt);
        }
      }.bind(this)); 
      //finally set the new array as the true array
      this.phenotype_data.set(phenotype, new_array);
    }.bind(this)); 
    
    this.reset_image();
    this.update_scoreboard_goal_text_and_submit_button();
    //log it:
    this.log_action('delete_training_points_around', x / this.magnification + ',' + y / this.magnification);
  },

  update_scoreboard_goal_text_and_submit_button : function(){
    
    this.total_points = 0;
    this.total_positive_points = 0;
    this.phenotype_data.each(function(pair){
      var phenotype = pair.key;
      var num = pair.value.size();
      $('counter_' + phenotype).update(num);
      this.total_positive_points += num;
      this.total_points += num;
    }.bind(this));  
    this.total_negative_points = this.total_points - this.total_positive_points;
    $('total_points').update(this.total_points);
    //$('total_positive_points').update(this.total_positive_points);
    //$('total_negative_points').update(this.total_negative_points);
    
    //now adjust the text color of the goal text
//    if (this.total_points < this.goal_total){
//      $('goal_total_points').style.color = 'red';
//    }
//    else {
//      $('goal_total_points').style.color = 'green';
//    }
//    if (this.total_positive_points < this.goal_positive){
//      $('goal_positive_points').style.color = 'red';
//    }
//    else if (this.goal_positive > 0){ //ensure it's a positive goal, if not, never make the damn text green
//      $('goal_positive_points').style.color = 'green';
//    }
//    if (this.total_negative_points < this.goal_negative){
//      $('goal_negative_points').style.color = 'red';
//    }
//    else {
//      $('goal_negative_points').style.color = 'green';
//    }
    //now adjust whether or not user can use the submit button
//    if (this.valid_for_submission()){
//      $('submit_button').disabled = false;
//    }
//    else {
//      $('submit_button').disabled = true;
//    }
  },

  log_action : function(name, data){
    var action = new Array();
    action.push(name);
    action.push(data);
    action.push(new Date().getTime());
    this.log.push(action);
  },

  log_dump : function(){
    var all_data = [];
    this.log.each(function(action){
      all_data.push(action.join(':'));
    });
    return all_data.join('|')
  },
  
  // phenotype_a:x_1,y_1;x_2,y_2|phenotype_b:x_1,y_1;x_2,y_2
  points_dump : function(){
    var all_data = [];
    this.phenotype_data.each(function(pair){
      var phenotype = pair.key;
      var array = pair.value;
      var data = [];
      data.push(phenotype + ":");
      //loop through data and print all points
      array.each(function(pt){
        data.push(pt.print());
      }.bind(this)); 
      //finally set the new array as the true array
      all_data.push(data.join(''));
    }.bind(this));
    return all_data.join('|')
  },
  
//  valid_for_submission : function(){
//    if (this.total_points < this.goal_total || this.total_positive_points < this.goal_positive || this.total_negative_points < this.goal_negative){
//      return false;
//    }
//    return true;
//  },

  confirm_submission_message : function(){
    var message = "Before submitting, please take a moment to check the following reminders and confirm:\n\n";
    //ensure uniqueness of phenotypes
    message += "*  Have you clicked once, and only once, on each of the " + this.phen + "?\n";
    message += "*  Have you scrolled to make sure that you found all " + this.phen + "?\n";
    message += "*  Have you clicked ONLY where there are " + this.phen + " and in no other places?\n";
    message += "\nIf you cannot answer *yes* to all the reminders above, do not submit your image.\n";
    message += "\nAre you sure you have fulfilled all these reminders? (If you are unsure, click \"Cancel\")";
    return confirm(message);
  },

  confirm_positive_points : function(){
    var c = true;
    var that = this;
    this.phenotype_data.each(function(pair){
      if (!c){
        return; //ditch for loop
      }
      var array = pair.value;      
      if (array.size() < 45){ //50% of the number of pts in the truth set
        c = confirm("These images have been pre-sorted. According to our initial classification, we estimated that are many more " + that.phen + " in the image than the number you have identified.\n\nAre you sure you marked all " + that.phen + "?\n\n(If not, click \"Cancel\")");
      }
    });
    if (!c){
      return false; //bad!
    }
    return true; //everything went okay
  },

//  confirm_scrolling : function(){
//    return confirm("Are you sure you clicked on all the tumors in the ENTIRE image by scrolling horizontally and vertically? You can also see the whole image by hovering your mouse over the thumbnail in the top right.\n\nIf not, your HIT will be AUTOMATICALLY rejected if you submit.\n\nClick cancel unless you are sure you trained the entire image by using the scrollbars.");
//  },
  
  submit_points_via_form : function(){
    this.log_action('submit_points_with_no_warnings', 0);
    //go through many checks to ensure quality of submission
//    if (!this.confirm_positive_points()){
//      return;
//    }
//    this.log_action('submit_after_message_1', 0);
//    if (!this.confirm_submission_message()){
//      return;
//    }
//    this.log_action('submit_after_message_2', 0);
    //ensure you cannot submit twice:
    $('submit_button').disabled = true;
    //first, spin the button so no double requests can go through
    $('submit_button').update(spinnerHTMLforspanssmall);
    //run the form submission
    $('ptsform_points').value = this.points_dump();
    $('ptsform_log').value = this.log_dump();
    $('ptsform_enc_identification_id').value = this.enc_identification_id;
    $('submit_identifiction_points_form').submit();
  },

  autologging_refresh_rate : 20000,
  autolog : function(){
    var that = this;
    that.submit_log_to_server();
    setTimeout(function(){
      that.autolog();
    }, this.autologging_refresh_rate);
  },

  submit_log_to_server : function(){
    var that = this;
    var r = new Ajax.Request(
      '/training/update_log',
      {
        method: 'post',
        //make sure to add all the data:
        parameters: 'enc_identification_id=' + that.enc_identification_id + '&log=' + that.log_dump(),
        onComplete: function(response){
          if (response.responseText.trim() != ""){
            alert('An error has occured in this HIT.')
          }
        }
      }
    );
  }
});



var XYPoint = Class.create();
Object.extend(XYPoint.prototype, {
  
  x : null,
  y : null,

  initialize : function(x, y){
    this.x = Math.round(x * 100) / 100; //two decimal places at most
    this.y = Math.round(y * 100) / 100; //two decimal places at most
//    console.log("record star x:" + this.x + " y:" + this.y);
  },
  
  print : function(){
    return this.x + "," + this.y + ";";
  },
  
  check_distance_greater_than : function(x, y, r, magnification){
    //check if the city-block distance is less:
    var check_x = this.x * magnification;
    var check_y = this.y * magnification;
    if (Math.abs(check_x - x) + Math.abs(check_y - y) < r){
      //still make sure it's less greater than the radius using pythagorean thm:
      if (Math.pow(Math.pow(check_x - x, 2) + Math.pow(check_y - y, 2), 0.5) < r){
        return false;
      }
    }
    return true;
  }  
});

function SelectPhenotype(name){
  var tds = $$('td.phenotype');
  for (var i = 0; i < tds.length; i++){
    tds[i].className = 'phenotype unselected_phenotype';
  }
  $('td_' + name).className = 'phenotype selected_phenotype';
}